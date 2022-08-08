# Note

## TODO

## DOING

## CHECK

## DONE

- Settings
- Gestione fine match/fine partita
- startPickCard allow fold
- Nessun vincitore
- Esci dalla lobby se sei da solo
- Gestione dei clients che si disconnettono durante la partita (in GameVC e EndVC)
    - Host
        - il server rimuove da clientPeerIDs il peer disconnesso e chiama il dealer
        - il dealer segna il giocatore da rimuovere
        - a fine partita lo rimuove
    - Client
        - segna il giocatore disconnesso (blocca il suo bottone)
- Quando non interagisci diventi fold
- Quando l'host esce, l'host deve chiuedere l'advertising
- Femare il browsing e l'advertising dei device quando si inizia la partita (in LobbyVC)
- Quando l'host esce, la lobby si deve chiudere (viene notificato al guest)
- L'host non può kickare se stesso
- L'host notifica al guest se viene kickato 
- Il rank delle carte J, Q, K devono avere valore 10 (.value)
- Gestione del player che è anche host
- Implementare un limite di 6 giocatori in una lobby

## REMEMBER

default: blue
destructive: red
cancel: bold blue
