#!/bin/bash

# ==============================================================================
# SCRIPT PER OTTENERE UN TOKEN DI SESSIONE DALLA ILIADBOX
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

# Verifica che l'APP_TOKEN sia stato impostato nel config
if [ -z "$APP_TOKEN" ]; then
  echo "Errore: APP_TOKEN non impostato in $CONFIG_FILE. Apri il file e incolla il tuo app_token." >&2
  exit 1
fi

# 1. Ottiene una "challenge" dalla box
CHALLENGE=$(curl -s "$ILIADBOX_URL/api/v8/login/" | jq -r '.result.challenge')

if [ -z "$CHALLENGE" ] || [ "$CHALLENGE" = "null" ]; then
  echo "Errore: Impossibile ottenere la challenge." >&2
  exit 1
fi

# 2. Calcola la password
PASSWORD=$(echo -n "$CHALLENGE" | openssl dgst -sha1 -hmac "$APP_TOKEN" | sed 's/^.* //')

# 3. Richiede un token di sessione
SESSION_TOKEN=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "{
        \"app_id\": \"$APP_ID\",
        \"password\": \"$PASSWORD\"
      }" \
  "$ILIADBOX_URL/api/v8/login/session/" | jq -r '.result.session_token')

# 4. Stampa il token di sessione
echo "$SESSION_TOKEN"
