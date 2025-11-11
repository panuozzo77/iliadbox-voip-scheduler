#!/bin/bash

# ==============================================================================
# SCRIPT PER ATTIVARE LA LINEA TELEFONICA DELLA ILIADBOX
# ==============================================================================

# Carica la configurazione centrale (config.sh nella stessa cartella dello script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/config.sh}"
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_FILE"
else
    echo "Errore: file di configurazione '$CONFIG_FILE' non trovato. Crea il file config.sh o controlla il percorso." >&2
    exit 1
fi

# --- Non modificare oltre questo punto ---
echo "Attivazione della linea telefonica in corso..."

if [ ! -f "$GET_TOKEN_SCRIPT" ]; then
    echo "Errore: Lo script get_session_token.sh non è stato trovato (GET_TOKEN_SCRIPT=$GET_TOKEN_SCRIPT). Controlla il percorso." >&2
    exit 1
fi

SESSION_TOKEN=$($GET_TOKEN_SCRIPT)

if [ "$SESSION_TOKEN" == "null" ] || [ -z "$SESSION_TOKEN" ]; then
  echo "Errore: impossibile ottenere il token di sessione." >&2
  exit 1
fi

API_ENDPOINT="$API_PHONE_SIP_ENDPOINT"
PAYLOAD='{"enabled": true}'

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
                -X POST \
                -H "X-Fbx-App-Auth: $SESSION_TOKEN" \
                -H "Content-Type: application/json" \
                -d "$PAYLOAD" \
                "$ILIADBOX_URL$API_ENDPOINT")

if [ "$RESPONSE" -eq 200 ]; then
    echo "Successo: La linea telefonica è stata attivata (HTTP 200 OK)."
else
    echo "Errore: Il server ha risposto con il codice HTTP $RESPONSE." >&2
fi
