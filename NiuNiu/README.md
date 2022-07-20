# Progetto: NiuNiu (Nyó Nyó)
## Descrizione del gioco
È un gioco di carte da 2 a 5 persone.

Si utilizza le carte da gioco francesi; ogni carta ha come valore il proprio valore numero; il fante, la regina e il re hanno valore 10.
Ogni giocatore ha 5 carte.
Lo scopo del gioco è quello di ottenere il punteggio più alto.

## Calcolo del punteggio
1. Si sceglie 3 carte su 5 la quale somma deve fare un multiplo di 10.
    Se non c’è una combinazione corretta, il punteggio del giocatore è pari al valore della carta più alta.
    Se si ha una combinazione, allora il giocatore ha fatto Niu e si passa al punto 2.
2. La somma delle due carte rimanenti modulo 10 è il punteggio del giocatore.
    Se il modulo ha valore 0, allora il giocatore ha fatto NiuNiu.

Ordine (crescente) del punteggio
- [1-10]
- Niu N [1-9]
- NiuNiu

### Spareggio
Il seme della carta ha la funzione di spareggio; l’ordine (crescente) è: picche, fiori, quadri e fiori.
In caso di parità senza Niu, si valuta il seme della carta più alta.
In caso di parità con Niu, si valuta: il valore della carta più alta delle 2 carte rimanenti, e poi il seme.
In caso di parità con NiuNiu, si valuta la somma più alta (si può fare 20 o 10), altrimenti la carta più alta, altrimenti il seme. 

## Interazione con l’utente
Sebbene sia un gioco banale (non è strettamente necessario che il giocatore interagisca durante il gioco), la popolarità del gioco deriva dal fatto è un gioco d’azzardo: i giocatori prima di mostrare il proprio punteggio fanno delle scommesse.

### Implementazione dell’interazione con l’utente:
- Ad inizio del gioco ogni giocatore ha x punti
- Per poter giocare ad un turno, bisogna puntare almeno y punti.
- Ad inizio turno, in un certo ordine i giocatori puntano dei punti; tutti i giocatori per poter giocare devono adeguarsi alla puntata più alta. Come nel poker, se si lascia il turno dopo aver fatto la puntata, si perdono i punti puntati. A differenza del poker, c’è solo un turno di puntata.
- Chi non fa nemmeno Niu, deve pagare una penale di z punti al vincitore.
- Chi vince il turno prende tutti i punti; se il vincitore ha fatto NiuNiu, gli altri giocatori devono dare k punti in più al vincitore.

Se un giocatore perde tutti i punti è fuori dalla partita.
Al termine dei turni fissati, vince chi ha più punti.

## Feature
- Le impostazioni del gioco dell’host può decidere x, y, z, k il numero di turni.
- Esistenza di alcune modalità di gioco: standard (valori lineari) e fast (aumento proporzionale dei parametri)
- Ogni giocatore può abbandonare la partita.
- Ogni giocatore può chiedere di terminare la partita con una votazione; se la votazione è superiore al 50% dei partecipanti, la partita termina.

## Implementazione

### Comunicazione
- Server
- Client

- Lobby

Il server conosce la lista dei client
Il client conosce il server

La lobby conosce tutti gli utenti nella stanza

Quando si crea una stanza, si definisce chi lo crea.

Stanze:
- server:
- searcher:
- client:

ServerGameVC    
