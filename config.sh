# Config centrale per gli script di iliadbox-voip-scheduler
# Modifica i valori qui per avere un unico punto di configurazione.

# Directory dello script (cartella del repository) - lasciare così nella maggior parte dei casi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Percorso allo script che restituisce il session token (assoluto o relativo a SCRIPT_DIR)
# Esempio: GET_TOKEN_SCRIPT="/home/utente/iliadbox/get_session_token_http.sh"
GET_TOKEN_SCRIPT="${GET_TOKEN_SCRIPT:-$SCRIPT_DIR/get_session_token_http.sh}"

# Indirizzo IP della Iliadbox nella rete locale
ILIADBOX_IP="${ILIADBOX_IP:-192.168.1.254}"
# Dominio API (usato dall'autorizzazione HTTPS con --resolve)
ILIADBOX_DOMAIN="${ILIADBOX_DOMAIN:-hn14dipb.ibxos.it}"
# URL base per le chiamate locali (usa HTTP per chiamate locali)
ILIADBOX_URL="${ILIADBOX_URL:-http://$ILIADBOX_IP}"

# Percorso al file dei certificati CA per le chiamate HTTPS verso la box
CA_CERT_PATH="${CA_CERT_PATH:-$SCRIPT_DIR/iliad-ca.pem}"

# Identificatori dell'app (possono essere lasciati così oppure modificati)
APP_ID="${APP_ID:-it.iliad.phone.scheduler}"
APP_NAME="${APP_NAME:-Pianificatore Telefono}"
APP_VERSION="${APP_VERSION:-1.0}"
DEVICE_NAME="${DEVICE_NAME:-VM Iliadbox}"

# App token ottenuto dall'autorizzazione (lascia vuoto fino a quando non lo hai ottenuto)
# Attenzione: NON committare il valore reale in un repository pubblico.
APP_TOKEN="${APP_TOKEN:-}"

# Endpoint API usati dagli script (modifica solo se necessario)
API_PHONE_SIP_ENDPOINT="/api/latest/phone/sip"

# Fine configurazione
