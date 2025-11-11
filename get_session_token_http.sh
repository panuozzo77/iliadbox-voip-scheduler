#!/bin/bash

# ==============================================================================
# SCRIPT PER OTTENERE UN TOKEN DI SESSIONE DALLA ILIADBOX
# ==============================================================================

# --- CONFIGURAZIONE ---
# Incolla qui l'app_token valido che hai ottenuto e autorizzato con lo stato "granted"
# Attenzione: NON committare il valore reale in un repository pubblico.
# Esempio: APP_TOKEN="REPLACE_WITH_YOUR_APP_TOKEN"
APP_TOKEN=""
# --- FINE CONFIGURAZIONE ---


# --- Non modificare oltre questo punto ---
APP_ID="it.iliad.phone.scheduler"
ILIADBOX_URL="http://192.168.1.254" # Usiamo HTTP per le richieste locali

# Verifica che l'APP_TOKEN sia stato impostato
if [ -z "$APP_TOKEN" ]; then
  echo "Errore: APP_TOKEN non impostato. Apri il file e incolla il tuo app_token nella variabile APP_TOKEN." >&2
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
