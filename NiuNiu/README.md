# Progetto: NiuNiu (牛牛)

## Descrizione del gioco

È un gioco di carte da 2 a 6 persone.
Ogni giocatore ha 5 carte e lo scopo del gioco è quello di ottenere il punteggio più alto.

Si utilizza le carte da gioco francesi; ogni carta ha come valore il proprio valore numerico; il fante, la regina e il re hanno valore 10.
Il valore effettivo, utilizzato nel caso dello spareggio, corrisponde al valore numerico della carta, mentre per il fante, la regina e il re il loro valore effettivo è rispettivamente 11, 12 e 13.

## Calcolo del punteggio

1. Si sceglie 3 carte su 5 la quale somma deve fare un multiplo di 10.
    Se non c’è una combinazione corretta, il giocatore sceglie la carta (più alta) che rappresenta il suo punteggio.
    Se si ha una combinazione, allora il giocatore ha ottenuto Niu (牛) e si passa al punto 2.
2. La somma delle due carte rimanenti modulo 10 è il punteggio del giocatore.
    Se il modulo ha valore 0, allora il giocatore ha fatto NiuNiu (牛牛).

Il punteggio senza Niu (牛) è minore del punteggio con Niu (牛).
Il punteggio più alto è NiuNiu (牛牛).

Alcuni esempi:

- 10 > 1
- Niu1 > 10
- Niu10 > Niu1
- NiuNiu > Niu10

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

## Fasi del gioco

0. Inizio sessione di gioco: tutti i giocatori hanno un punteggio **stabilito** dall'host.
1. Inizio partita e/o fase di Bet: tutti i giocatori effettuano una certa puntata utilizzando il proprio punteggio.
2. Fase di check: tutti i giocatori per poter continuare a giocare devono adeguarsi alla puntata più alta.
3. Fase di pick: tutti i giocatori scelgono le carte da giocare.
4. Fine partita o fase finale: si mostrano le carte e si stabilisce il vincitore che prende tutti i punti. 

Nota bene: il giocatore può decidere di ritirarsi durante la partita ma perderà tutti i punti già utilzzati.

## Feature (?)
- Le impostazioni del gioco li decide l’host.
- Ogni giocatore può abbandonare la partita.
- Ogni giocatore può chiedere di terminare la partita con una votazione; se la votazione è superiore al 50% dei partecipanti, la partita termina.
