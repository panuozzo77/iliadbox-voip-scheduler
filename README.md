# iliadbox-voip-scheduler

Scopo
-----
Questa raccolta di script permette di autorizzare un'applicazione sulla tua Iliadbox (per ottenere un app_token),
ottenere un token di sessione e poi attivare/disattivare la linea telefonica (API locale).

Nota di sicurezza
------------------
- Non condividere né committare il tuo `app_token` o `session_token` in repository pubblici.
- Le richieste di autorizzazione iniziali devono avvenire via HTTPS; le chiamate successive alla API locale possono usare HTTP.

Passaggi principali (sintesi)
---------------------------
0) Trovare l'api_domain della tua Iliadbox (opzionale)
   - Esempio: curl http://192.168.1.254/api_version | jq -r '.api_domain'

1) Creare il file dei certificati `iliad-ca.pem`
   - Sulla interfaccia Web della Iliadbox vai in: Logo Iliad > Sviluppatore > HTTPS Access.
   - Copia in ordine i certificati root (ECC Root CA e RSA Root CA) e incollali in un file di testo chiamato `iliad-ca.pem`.
   - Un file di esempio `iliad-ca.pem` è incluso in questo repository (file di esempio, sostituire con i certificati reali).

2) Eseguire `autorizza_app.sh` per ottenere l'app_token
   - Questo script invia la richiesta di autorizzazione (HTTPS) e poi attende che tu approvi la richiesta usando il display della Iliadbox.
   - Quando lo stato diventa `granted` lo script mostra l'`app_token`. Copialo e Incollalo nello script `get_session_token_http.sh` nella variabile `APP_TOKEN`.

3) Usare `get_session_token_http.sh` per ottenere un `session_token`
   - Lo script calcola la password HMAC-SHA1 usando la challenge fornita dalla box e il tuo `app_token`, poi richiede la sessione.
   - Per sicurezza lo script non contiene più un token hard-coded: devi incollare il tuo `APP_TOKEN` manualmente.

4) Attivare / Disattivare la linea
   - `attiva_telefono_http.sh` -> abilita la linea telefonica
   - `disattiva_telefono_http.sh` -> disabilita la linea telefonica
   - Entrambi gli script usano lo script `get_session_token_http.sh` per ottenere il token di sessione.

Esempio di uso rapido
---------------------
- Autorizza l'app (HTTPS):
  - Assicurati che `iliad-ca.pem` contenga i certificati corretti.
  - Esegui: `./autorizza_app.sh` (approva la richiesta dal display della box)

- Imposta `APP_TOKEN` in `get_session_token_http.sh` (non committare il valore):
  - Apri il file e incolla `APP_TOKEN="il_tuo_app_token_ricevuto"`.

- Ottieni un token di sessione (il file restituirà solo il token):
  - `./get_session_token_http.sh`

- Usa gli script per abilitare/disabilitare la linea (esempio):
  - `./attiva_telefono_http.sh`
  - `./disattiva_telefono_http.sh`

File inclusi
-------------
- `autorizza_app.sh`  — avvia l'autorizzazione HTTPS e attende l'approvazione fisica sulla box.
- `get_session_token_http.sh` — ottiene un token di sessione usando l'`app_token`.
- `attiva_telefono_http.sh` — script per attivare la linea telefonica (usa il get_session script).
- `disattiva_telefono_http.sh` — script per disattivare la linea telefonica.
- `iliad-ca.pem` — file di esempio con certificati placeholder (sostituire con i certificati reali dalla box).

Note tecniche e consigli
-----------------------
- Lo script `autorizza_app.sh` usa `curl --cacert iliad-ca.pem --resolve` per bypassare DNS e validare HTTPS con il certificato fornito.
- Se lavori da una rete diversa o la box ha indirizzo IP differente, aggiorna `ILIADBOX_IP` negli script.
- Per debug, verifica le risposte HTTP salvando l'output completo di `curl` invece di usare opzione `-s`.

Se vuoi, posso anche:
- rimuovere o generalizzare i percorsi assoluti presenti negli script (es. percorso di `get_session_token_http.sh`).
- aggiungere un piccolo script di esempio per installare i certificati locali sul sistema.

Fine della documentazione.