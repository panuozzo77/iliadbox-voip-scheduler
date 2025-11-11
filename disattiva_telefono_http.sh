#!/bin/bash

# ==============================================================================
# SCRIPT PER DISATTIVARE LA LINEA TELEFONICA DELLA ILIADBOX
# ==============================================================================

# --- CONFIGURAZIONE (MODIFICA QUESTO PERCORSO!) ---
# Inserisci il percorso ASSOLUTO dello script get_session_token.sh
# Esempio: GET_TOKEN_SCRIPT="/home/cristian/Documents/iliadbox/get_session_token.sh"
GET_TOKEN_SCRIPT="/home/cristian/Documents/iliadbox/get_session_token_http.sh"
# --- FINE CONFIGURAZIONE ---


# --- Non modificare oltre questo punto ---
echo "Disattivazione della linea telefonica in corso..."

if [ ! -f "$GET_TOKEN_SCRIPT" ]; then
    echo "Errore: Lo script get_session_token.sh non è stato trovato. Controlla il percorso." >&2
    exit 1
fi

SESSION_TOKEN=$($GET_TOKEN_SCRIPT)

if [ "$SESSION_TOKEN" == "null" ] || [ -z "$SESSION_TOKEN" ]; then
  echo "Errore: impossibile ottenere il token di sessione." >&2
  exit 1
fi

ILIADBOX_URL="http://192.168.1.254"
API_ENDPOINT="/api/latest/phone/sip"
PAYLOAD='{"enabled": false}'

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
                -X POST \
                -H "X-Fbx-App-Auth: $SESSION_TOKEN" \
                -H "Content-Type: application/json" \
                -d "$PAYLOAD" \
                "$ILIADBOX_URL$API_ENDPOINT")

if [ "$RESPONSE" -eq 200 ]; then
    echo "Successo: La linea telefonica è stata disattivata (HTTP 200 OK)."
else
    echo "Errore: Il server ha risposto con il codice HTTP $RESPONSE." >&2
fi
