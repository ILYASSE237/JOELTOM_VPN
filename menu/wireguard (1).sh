#!/bin/bash
# Deprecated wrapper for backward compatibility.
# Previously the file name contained spaces/parentheses; this wrapper
# forwards calls to the normalized menu/wireguard.sh.

NEW_SCRIPT="$(dirname "$0")/wireguard.sh"
if [ -x "$NEW_SCRIPT" ]; then
  exec "$NEW_SCRIPT" "$@"
fi

# Fallback: try calling the new path directly if script not in same dir
if [ -x "/usr/local/bin/menu/wireguard.sh" ]; then
  exec "/usr/local/bin/menu/wireguard.sh" "$@"
fi

# If not found, print an informative message
echo "Le script menu/wireguard.sh est introuvable. Veuillez vérifier l'installation."
exit 1
