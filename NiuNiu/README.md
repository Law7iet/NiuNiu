# Laboratorio di Applicazioni Mobili
# Report Progetto NiuNiu (牛牛)

## Descrizione del gioco

Niu Niu è un gioco di carte da 2 a 6 persone.
Ogni giocatore ha 5 carte e lo scopo del gioco è quello di comporre il punteggio più alto.

Si utilizza le carte da gioco francesi.
Ogni carta ha come valore il proprio *valore numerico*; il fante, la regina e il re hanno valore 10.

Il *valore effettivo*, utilizzato nel caso dello spareggio, corrisponde al valore numerico della carta, mentre per il fante, la regina e il re, il loro valore effettivo è rispettivamente 11, 12 e 13.

Il gioco è diviso di round.
All'inizio del gioco ogni giocatore ha un punteggio.
In ogni round il giocatore, utilizzando il proprio punteggio fa delle puntate.
A fine round chi ottiene il punteggio più alto si prende tutti i punti.

### Calcolo del punteggio

Ogni giocatore, in base alla combinazione di carte ha un punteggio; il punteggio, in ordine crescente, è 1, 2, 3, 4, 5, 6, 7, 8, 9 e 0.
Questo punteggio può essere con Niu o senza Niu; il punteggio con Niu è più alto del punteggio senza Niu.

Per ottenere Niu bisogna trovare 3 carte la quale somma faccia un multiplo di 10; il punteggio sarà dato dalla somma delle due carte modulo 10.
Se il punteggio è 0, allora si ha il punteggio più alto ed è detto NiuNiu (牛牛).

Se non si ha Niu, allora il punteggio è il valore numerico della carta scelta dal giocatore modulo 10.

### Spareggio

In caso di spareggio, si valuta prima il valore effettivo di una carta e poi il seme della stessa carta col seguente ordine crescente:

- picche
- fiori
- quadri
- cuori

La carta da valutare è:

- L'unica carta scelta da giocatore, se è senza Niu (牛).
- La carta col valore effettivo e seme più grande fra le due carte rimanenti, in caso di Niu (牛).

In caso di NiuNiu (牛牛), si valuta prima chi ha fatto la somma più grande (si può fare 20 o 10), altrimenti si procede come per il caso con Niu (牛). 

### Fasi del gioco

0. Inizio sessione di gioco: tutti i giocatori hanno lo stesso punteggio.
1. Inizio partita e/o fase di bet: tutti i giocatori ricevono le carte ed effettuano una certa puntata utilizzando il proprio punteggio.
2. Fase di check: tutti i giocatori per poter continuare a giocare devono adeguarsi alla puntata più alta.
3. Fase di pick: tutti i giocatori scelgono le carte da giocare.
4. Fine partita o fase finale: si mostrano le carte e si stabilisce il vincitore che prende tutti i punti.

Nota bene: il giocatore può decidere di ritirarsi durante la partita ma perderà tutti i punti già utilzzati.

## Descrizione dell'applicazione

Ogni applicazione può:

- hostare
- joinare
- modificare le impostazioni

### Pairing
Il client visualizzerà la lista degli host disponibili.
L'host può decidere di rimuovere un giocatore nella propria lobby.

### Playing
Durante la partita l'host è un giocatore e giocherà come i client.
Se un giocatore termina i propri punti può rimanere a guardare la partita o uscire dalla lobby.

### Ending
Alla fine di ogni partita i giocatori possono decidere se uscire dalla lobby o continuare a giocare.

Nota bene:
In qualsiasi momento, se l'host decide di lasciare la lobby, la lobby verrà chiusa.

### Impostazioni di gioco
Ogni giocatore può modificare:

- il proprio nickname ed immagine.
- alcune impostazioni di gioco (punteggio iniziale, tempo di gioco, "penalità") che vengono utilizzate in gioco se è l'host

### Feature (?)

- Penalità
- Modificare il proprio nickname
- Le impostazioni del gioco li decide l’host.
- Ogni giocatore può chiedere di terminare la partita con una votazione; se la votazione è superiore al 50% dei partecipanti, la partita termina.
- Ogni giocatore ha un'avatar (immagine di profilo)
- Cambiare il numero di giocatori massimi.

## Implementazione

Comunicazione tramite MultipeerConnectivity

MVC

- Model
    - Game
        - Delaer
    - Communication
        - Client
        - Server
        - Message
- View (Main - storyboard)
- Controller
    - ...
