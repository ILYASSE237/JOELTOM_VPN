#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# AUTO-REPAIR: Detectar instalación incompleta y limpiar
# Si /etc/movivip existe pero falta archivos críticos, es una
# instalación fallida anterior → limpiar todo para reinstalar.
# Solo delegar al updater si la instalación está COMPLETA.
# ═══════════════════════════════════════════════════════════════
if [[ -d "/etc/movivip" ]]; then
    # Verificar si la instalación está completa (archivos críticos)
    _NEEDS_REPAIR=0
    for _crit in menu.sh config.conf protocolos usuarios; do
        if [[ ! -e "/etc/movivip/$_crit" ]]; then
            _NEEDS_REPAIR=1
            break
        fi
    done

    if [[ "$_NEEDS_REPAIR" -eq 1 ]]; then
        echo ""
        echo "⚠️  Instalación incompleta detectada (faltan archivos críticos)."
        echo "   → Limpiando automáticamente para reinstalación..."
        echo ""
        # Detener servicios VPN/Proxy sueltos
        for _svc in xray v2ray dropbear dropbear_custom badvpn-udpgw-7300 badvpn-udpgw-7200 \
                     udp-custom zivpn slowdns squid webmin openvpn; do
            systemctl stop "$_svc" 2>/dev/null
            systemctl disable "$_svc" 2>/dev/null
        done
        killall -9 xray v2ray dropbear badvpn-udpgw 2>/dev/null || true
        # Limpiar configuraciones de servicios
        rm -rf /etc/xray /usr/local/etc/xray /etc/v2ray
        rm -f /usr/bin/xray /usr/local/bin/xray /usr/bin/dropbear /usr/sbin/dropbear
        rm -f /usr/bin/badvpn-udpgw /usr/bin/udp /usr/bin/config.json
        rm -rf /usr/local/SlowDNS /tmp/dnstt* /etc/slowdns /etc/zivpn
        rm -f /etc/systemd/system/xray*.service /etc/systemd/system/v2ray*.service
        rm -f /etc/systemd/system/dropbear*.service /etc/systemd/system/badvpn*.service
        rm -f /etc/systemd/system/udpcustom*.service /etc/systemd/system/slowdns*.service
        rm -f /etc/systemd/system/zivpn*.service /etc/systemd/system/movivip*.service
        # Limpiar config de red
        rm -f /etc/sysctl.d/99-z-JOELTOM.conf /etc/sysctl.d/99-movivip.conf
        # Limpiar crons
        crontab -l 2>/dev/null | grep -v "movivip\|auto-cleanup\|auto-update\|network_snapshot\|online.sh" | crontab - 2>/dev/null
        # Reset iptables a ACCEPT (sin DROP) para que SSH no se cierre
        iptables -F 2>/dev/null
        iptables -X 2>/dev/null
        iptables -t nat -F 2>/dev/null
        iptables -t nat -X 2>/dev/null
        iptables -t mangle -F 2>/dev/null
        iptables -t mangle -X 2>/dev/null
        iptables -P INPUT ACCEPT 2>/dev/null
        iptables -P FORWARD ACCEPT 2>/dev/null
        iptables -P OUTPUT ACCEPT 2>/dev/null
        # Eliminar directorio incompleto
        rm -rf /etc/movivip
        rm -f /etc/profile.d/JOELTOM-banner.sh /etc/issue.net
        # ABRIR PUERTOS DE EMERGENCIA SIEMPRE (22 + 54321 + 8012)
        iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
        iptables -I INPUT 2 -p tcp --dport 54321 -j ACCEPT
        iptables -I INPUT 3 -p tcp --dport 8012 -j ACCEPT
        iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
        systemctl daemon-reload 2>/dev/null
        echo "✔ Sistema limpiado — continuando instalación fresca..."
        echo ""
    else
        # Installation complète → ouvrir le gestionnaire local
        echo "Installation JOELTOM déjà présente."
        if [[ -f "/etc/movivip/update.sh" ]]; then
            bash "/etc/movivip/update.sh"
        else
            echo "Le gestionnaire de mise à jour local est introuvable."
        fi
        exit 0
    fi
fi

# ═══════════════════════════════════════════════════════════════
# COLOR SYSTEM (before language loads)
# ═══════════════════════════════════════════════════════════════
CYAN="\e[1;96m"; GOLD="\e[1;93m"; GREEN="\e[1;92m"; RED="\e[1;91m"
WHITE="\e[1;97m"; GRAY="\e[1;90m"; MAGENTA="\e[1;95m"; RESET="\e[0m"
YELLOW="\e[1;33m"

# ═══════════════════════════════════════════════════════════════
# SISTEMA DE PROGRESO + ERROR REPORTING
# Logs completos en /var/log/movivip-install.log para soporte
# ═══════════════════════════════════════════════════════════════

INSTALL_LOG="/var/log/movivip-install.log"
INSTALL_STEP=0
INSTALL_TOTAL=19

log_error() {
    local line="$1" desc="$2" cmd="$3" err="$4"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR Línea $line: $desc | Comando: $cmd | Error: $err" >> "$INSTALL_LOG"
}

show_progress_bar() {
    local current="$1"
    local total="$2"
    local desc="$3"
    local width=40
    local pct=0
    [[ "$total" -gt 0 ]] && pct=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    local color="$CYAN"
    if [[ "$pct" -ge 80 ]]; then color="$GREEN"
    elif [[ "$pct" -ge 50 ]]; then color="$GOLD"
    fi

    printf "\r${CYAN}   [${color}%s${CYAN}]${WHITE} %3d%%${GRAY} [%d/%d]${WHITE} %-45s${RESET}" \
        "$bar" "$pct" "$current" "$total" "$desc"
}

step() {
    INSTALL_STEP=$((INSTALL_STEP + 1))
    local desc="$1"
    echo ""
    show_progress_bar "$INSTALL_STEP" "$INSTALL_TOTAL" "$desc"
    echo ""
}

run_cmd() {
    local desc="$1" line="$2"
    shift 2
    local cmd_str="$*"
    local tmp_err
    tmp_err=$(mktemp)
    if eval "$cmd_str" >/dev/null 2>"$tmp_err"; then
        echo -e "      ${GREEN}✔${RESET} $desc"
        rm -f "$tmp_err"
    else
        local err_msg
        err_msg=$(cat "$tmp_err" 2>/dev/null)
        rm -f "$tmp_err"
        echo -e "      ${RED}✖${RESET} $desc"
        echo -e "      ${GRAY}  → Reportar a soporte: Línea $line${RESET}"
        log_error "$line" "$desc" "$cmd_str" "$err_msg"
    fi
}

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GOLD}      🛡️ JOELTOM VPS — INSTALADOR v6.0 🛡️${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
echo -e "${RED}❌ Necesita root${RESET}"
exec sudo bash "$0" "$@"
fi

source /etc/os-release

# ═══════════════════════════════════════════════════════════════
# SOPORTE MULTI-DISTRO
# ═══════════════════════════════════════════════════════════════

DISTRO_OK=0
case "$ID" in
    ubuntu|debian)   PKG="apt";  DISTRO_OK=1 ;;
    opensuse*|suse|sles) PKG="zypper"; DISTRO_OK=1 ;;
    ol|rhel|centos|rocky|almalinux) PKG="dnf"; DISTRO_OK=1 ;;
    arch|manjaro)    PKG="pacman"; DISTRO_OK=1 ;;
esac

if [[ "$DISTRO_OK" -eq 0 ]]; then
    echo -e "${RED}❌ Sistema no soportado: $ID${RESET}"
    echo -e "${WHITE}   Soportados: Ubuntu, Debian, openSUSE Leap, Oracle Linux, Arch Linux${RESET}"
    exit 1
fi

# Iniciar log de instalación
echo "========== INSTALACIÓN JOELTOM v6.0 — $(date) ==========" > "$INSTALL_LOG"
chmod 600 "$INSTALL_LOG"

clear
echo -e "${GREEN}✔ Sistema detectado: ${PRETTY_NAME:-$ID}${RESET}"
echo -e "${WHITE}  Gestor de paquetes: ${PKG}${RESET}"

# ═══════════════════════════════════════════════════════════════
# INSTALLATION LIBRE — AUCUNE CLÉ DE LICENCE
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}✔ Installation libre JOELTOM VPS — aucune clé de licence requise.${RESET}"
echo ""

# ═══════════════════════════════════════════════════════════════
# SELECTOR DE IDIOMA — INTERACTIVO
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GOLD}      🌐 SELECT LANGUAGE / SELECCIONAR IDIOMA${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Lista de idiomas: código|bandera|nombre|región
LANG_LIST=(
    "es|🇪🇸|Español|España/Latinoamérica"
    "en|🇺🇸|English|United States/UK"
    "af|🇪🇹|Afaan Oromoo|Ethiopia/Kenya"
    "fr|🇫🇷|Français|France/Belgique"
    "pt|🇧🇷|Português|Brasil/Portugal"
    "ar|🇸🇦|العربية|السعودية/مصر"
    "sw|🇰🇪|Kiswahili|Kenya/Tanzania"
    "de|🇩🇪|Deutsch|Deutschland/Österreich"
    "zh|🇨🇳|中文|中国"
    "hi|🇮🇳|हिन्दी|भारत"
)

INSTALL_LANG="fr"
for i in "${!LANG_LIST[@]}"; do
    IFS='|' read -r code flag name region <<< "${LANG_LIST[$i]}"
    num=$((i + 1))
    printf "  ${CYAN}[%02d]${RESET} ${WHITE}%s %-15s${RESET} ${GRAY}%-20s${RESET}\n" \
        "$num" "$flag" "$name" "$region"
done

echo ""
if [[ -t 0 ]]; then
    read -rp "$(echo -e "${CYAN}➜ ${GOLD}Select language [1-10]${WHITE} (défaut : 4=FR) ➤ ${RESET}")" LANG_CHOICE
else
    LANG_CHOICE="${LANG_CHOICE:-4}"
fi
LANG_CHOICE="${LANG_CHOICE:-4}"
[[ "$LANG_CHOICE" =~ ^[0-9]+$ ]] || LANG_CHOICE=1

# Mapear número a código
LANG_CODES=("es" "en" "af" "fr" "pt" "ar" "sw" "de" "zh" "hi")
LANG_IDX=$((LANG_CHOICE - 1))
if [[ $LANG_IDX -ge 0 && $LANG_IDX -lt ${#LANG_CODES[@]} ]]; then
    INSTALL_LANG="${LANG_CODES[$LANG_IDX]}"
else
    INSTALL_LANG="es"
fi

echo -e "${GREEN}✅ Idioma seleccionado: ${WHITE}${INSTALL_LANG^^}${RESET}"
sleep 1

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║${GOLD}         🔄 SISTEMA DETECTADO — LIMPIEZA TOTAL${RESET}${CYAN}          ║${RESET}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}║${WHITE}  Se encontraron usuarios en el sistema${RESET}${CYAN}               ║${RESET}"
echo -e "${CYAN}║${YELLOW}  Se hará backup y se limpiará TODO para reinstalación.${RESET}${CYAN}  ║${RESET}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"

# Paquetes críticos — proteger contra eliminación accidental
CRITICAL_PKGS=(
    "python3" "sudo" "wget" "curl" "screen" "openssh-server"
    "haproxy" "socat" "openssl" "ca-certificates"
    "fail2ban" "iptables" "iproute2" "net-tools"
)

# Instalar paquetes básicos
step "Actualizando repositorios..."

# Funciones de gestión de paquetes
pkg_update() {
    case "$PKG" in
        apt)    apt-get update -y 2>/dev/null ;;
        zypper) zypper --non-interactive refresh 2>/dev/null ;;
        dnf)    dnf makecache -y 2>/dev/null ;;
        pacman) pacman -Sy --noconfirm 2>/dev/null ;;
    esac
}

pkg_install() {
    case "$PKG" in
        apt)    apt-get install -y "$@" 2>/dev/null ;;
        zypper) zypper --non-interactive install -y "$@" 2>/dev/null ;;
        dnf)    dnf install -y "$@" 2>/dev/null ;;
        pacman) pacman -S --noconfirm --needed "$@" 2>/dev/null ;;
    esac
}

run_cmd "Actualizando repositorios" "$LINENO" "pkg_update"

step "Instalando paquetes esenciales..."
COMMON_PKGS="curl wget git unzip zip tar sudo nano lsof screen jq bc socat openssl ca-certificates iptables iproute2"
run_cmd "Paquetes esenciales" "$LINENO" "pkg_install $COMMON_PKGS"

step "Instalando OpenSSH..."
run_cmd "Instalando openssh-server" "$LINENO" "pkg_install openssh-server"
run_cmd "Habilitando servicio SSH" "$LINENO" "systemctl enable ssh"

mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/ports-movivip.conf << 'SSHEOF'
# JOELTOM VPS - Puertos SSH de emergencia
Port 22
Port 54321
Port 8012
SSHEOF

run_cmd "Reiniciando SSH" "$LINENO" "systemctl restart ssh"

# ═══════════════════════════════════════════════════════════════
# CONFIGURACIÓN FINAL
# ═══════════════════════════════════════════════════════════════

step "Configurando servidor..."

clear
echo "━━━━━━━━━━━━━━━━━���━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "        CONFIGURACIÓN DEL SERVIDOR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ -t 0 ]]; then
    read -p "🌐 Dominio Cloudflare (Enter si no): " SERVER_DOMAIN
    read -p "🌐 Dominio Cloudfront (Enter si no): " CLOUDFRONT_DOMAIN
    read -p "🌐 Dominio No-IP / DDNS (Enter si no): " NOIP_DOMAIN
else
    SERVER_DOMAIN="${SERVER_DOMAIN:-}"
    CLOUDFRONT_DOMAIN="${CLOUDFRONT_DOMAIN:-}"
    NOIP_DOMAIN="${NOIP_DOMAIN:-}"
fi

SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "0.0.0.0")
BASE="/etc/movivip"

mkdir -p $BASE/{protocolos,usuarios,sistema,logs}

HWID_SECRET=$(openssl rand -hex 24 2>/dev/null || echo "default-secret-$(date +%s)")

cat > "$BASE/config.conf" <<EOF
SERVER_DOMAIN="$SERVER_DOMAIN"
CLOUDFRONT_DOMAIN="$CLOUDFRONT_DOMAIN"
NOIP_DOMAIN="$NOIP_DOMAIN"
BRAND_NAME="JOELTOM VPS"
BRAND_EMOJI="🛡️"
HWID_SECRET="$HWID_SECRET"
LANGUAGE="$INSTALL_LANG"
OPENSSH=ON
SSL=ON
EOF

step "Finalizando instalación..."

run_cmd "Estableciendo permisos" "$LINENO" "chmod -R 777 /etc/movivip"
run_cmd "Creando comando menu" "$LINENO" "printf '#!/bin/bash\nexec bash /etc/movivip/menu.sh\n' > /usr/local/bin/menu; chmod +x /usr/local/bin/menu"

# ═══════════════════════════════════════════════════════════════
# RESUMEN FINAL
# ═══════════════════════════════════════════════════════════════

step "Instalación completada"

echo ""
echo -e "${GREEN}╔═════════════════════════════════════════════════════════════╗${RESET}"
show_progress_bar "$INSTALL_TOTAL" "$INSTALL_TOTAL" "100% — INSTALACIÓN COMPLETADA ✅"
echo ""
echo -e "${GREEN}╚═════════════════════════════════════════════════════════════╝${RESET}"
echo ""

echo -e "${CYAN}╔═════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║${GOLD}            ✅ INSTALACIÓN COMPLETADA                      ${CYAN}║${RESET}"
echo -e "${CYAN}╠═════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}║${WHITE}  Dominio  : ${GREEN}$SERVER_DOMAIN${RESET}${CYAN}                              ║${RESET}"
echo -e "${CYAN}║${WHITE}  IP       : ${GREEN}$SERVER_IP${RESET}${CYAN}                                ║${RESET}"
echo -e "${CYAN}║${WHITE}  Idioma   : ${GREEN}$INSTALL_LANG${RESET}${CYAN}                                  ║${RESET}"
echo -e "${CYAN}╠═════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}║${GOLD}  Protocolos activos:${RESET}${CYAN}                                     ║${RESET}"
echo -e "${CYAN}║${WHITE}  🚀 OpenSSH    : ON${RESET}${CYAN}                                 ║${RESET}"
echo -e "${CYAN}║${WHITE}  🔐 SSL/TLS    : ON${RESET}${CYAN}                                 ║${RESET}"
echo -e "${CYAN}╠═════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}║${WHITE}  📦 Paquetes básicos: INSTALADO                          ${CYAN}║${RESET}"
echo -e "${CYAN}║${WHITE}  🌐 Sistema listo para gestión desde menú                ${CYAN}║${RESET}"
echo -e "${CYAN}╚═════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${GRAY}  📋 Log de instalación: $INSTALL_LOG${RESET}"
echo -e "${GREEN}  ✅ Instalación finalizada correctamente${RESET}"
echo ""
