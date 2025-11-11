#!/bin/bash

# ==============================================================================
# SCRIPT PER L'AUTORIZZAZIONE INIZIALE DI UNA NUOVA APPLICAZIONE SULLA ILIADBOX
# ==============================================================================

# --- Dati di configurazione dell'applicazione ---
APP_ID="it.iliad.phone.scheduler"
APP_NAME="Pianificatore Telefono"
APP_VERSION="1.0"
DEVICE_NAME="VM Iliadbox"
# ----------------------------------------------

# --- Dati di rete (non modificare) ---
ILIADBOX_DOMAIN="hn14dipb.ibxos.it"
ILIADBOX_IP="192.168.1.254"
CA_CERT_PATH="./iliad-ca.pem"
# ------------------------------------

# Controlla se il file del certificato esiste
if [ ! -f "$CA_CERT_PATH" ]; then
    echo -e "\033[0;31mErrore: File del certificato '$CA_CERT_PATH' non trovato.\033[0m"
    echo "Assicurati che sia nella stessa cartella dello script."
    exit 1
fi

echo "Passo 1: Richiesta di autorizzazione alla Iliadbox..."
echo "----------------------------------------------------"

# Esegue la richiesta di autorizzazione e cattura la risposta
RESPONSE=$(curl --cacert "$CA_CERT_PATH" \
                --resolve $ILIADBOX_DOMAIN:443:$ILIADBOX_IP \
                -s -X POST \
                -H "Content-Type: application/json" \
                -d "{
                      \"app_id\": \"$APP_ID\",
                      \"app_name\": \"$APP_NAME\",
                      \"app_version\": \"$APP_VERSION\",
                      \"device_name\": \"$DEVICE_NAME\"
                    }" \
                "https://$ILIADBOX_DOMAIN/api/v8/login/authorize/")

# Controlla se la richiesta è fallita
if [ $? -ne 0 ]; then
    echo -e "\033[0;31mErrore: La richiesta curl è fallita. Controlla la connessione di rete e che la Iliadbox sia raggiungibile.\033[0m"
    exit 1
fi

# Estrae l'app_token e il track_id dalla risposta JSON
SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
if [ "$SUCCESS" != "true" ]; then
    echo -e "\033[0;31mErrore: La richiesta di autorizzazione non è andata a buon fine.\033[0m"
    echo "Risposta del server: $RESPONSE"
    exit 1
fi

APP_TOKEN=$(echo "$RESPONSE" | jq -r '.result.app_token')
TRACK_ID=$(echo "$RESPONSE" | jq -r '.result.track_id')

echo "Richiesta inviata con successo."
echo "   -> Track ID: $TRACK_ID"
echo ""
echo "Passo 2: Attesa dell'approvazione fisica"
echo "------------------------------------------"
echo -e "\033[1;33mAZIONE RICHIESTA: Vai sul display della tua Iliadbox e approva la richiesta per '$APP_NAME'.\033[0m"
echo "Lo script controllerà lo stato ogni 2 secondi..."
echo ""

# Inizia a monitorare lo stato
while true; do
  STATUS_RESPONSE=$(curl --cacert "$CA_CERT_PATH" --resolve $ILIADBOX_DOMAIN:443:$ILIADBOX_IP -s "https://$ILIADBOX_DOMAIN/api/v8/login/authorize/$TRACK_ID")
  STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.result.status')
  
  echo "Stato attuale: $STATUS"
  
  if [ "$STATUS" = "granted" ]; then
    echo ""
    echo -e "\033[1;32m=========================================================\033[0m"
    echo -e "\033[1;32m           AUTORIZZAZIONE CONCESSA CON SUCCESSO!         \033[0m"
    echo -e "\033[1;32m=========================================================\033[0m"
    echo ""
    echo "Il tuo token applicazione (app_token) è:"
    echo ""
    echo -e "\033[1;37m$APP_TOKEN\033[0m"
    echo ""
    echo "Copia questo token e incollalo nella variabile 'APP_TOKEN' degli altri script."
    echo "Questa operazione non dovrà più essere ripetuta."
    break
  elif [ "$STATUS" != "pending" ]; then
    echo ""
    echo -e "\033[0;31m=========================================================\033[0m"
    echo -e "\033[0;31m              AUTORIZZAZIONE FALLITA!                  \033[0m"
    echo -e "\033[0;31m=========================================================\033[0m"
    echo "Lo stato finale è: '$STATUS'."
    echo "Possibili cause: richiesta scaduta (timeout) o rifiutata (denied)."
    echo "Per favore, esegui di nuovo questo script e approva la richiesta più velocemente."
    break
  fi
  
  sleep 2
done
