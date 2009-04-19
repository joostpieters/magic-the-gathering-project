#!r6rs

(library
 (card)
 (export card
         card-action)
 (import (rnrs base (6))
         (magic double-linked-position-list)
         (magic object)
         (magic cards card-action))

 ; Code
 ; Class: card 
 (define (card name color cost game player picture . this-a)
   (define actions (position-list eq?))
   
   (define (get-name)
     name)
   (define (get-color)
     color)
   (define (get-cost)
     cost)
   (define (get-game)
     game)
   (define (get-player)
     player)
   (define (set-cost! new-cost)
     (set! cost new-cost))
   (define (can-play?)
     #f) ; you can never play this card.
   (define (draw)
     #f)
   (define (supports-type? type)
     (eq? type card))
   (define (get-type)
     card)
   (define (get-picture)
     picture)
   (define (get-actions)
     actions)
   (define (add-action! action)
     (actions 'add-after! action))
   (define (remove-action! action)
    (let ([pos (actions 'find action)])
	  (if pos
       (actions 'delete! action))))
   (define (perform-default-action)
     #f)
   
   (define (obj-card msg . args)
     (case msg
       ((get-name) (apply get-name args))
       ((get-color) (apply get-color args))
       ((get-cost) (apply get-cost args))
       ((get-game) (apply get-game args))
       ((get-player) (apply get-player args))
       ((set-cost!) (apply set-cost! args))
       ((can-play?) (apply can-play? args))
       ((draw) (apply draw args))
       ((supports-type?) (apply supports-type? args))
       ((get-type) (apply get-type args))
       ((get-picture) (apply get-picture args))
       ((get-actions) (apply get-actions args))
       ((add-action!) (apply add-action! args))
       ((remove-action!) (apply remove-action! args))
       ((perform-default-action) (apply perform-default-action args))
       (else (assertion-violation 'card "message not understood" msg))))
   
   (define this (extract-this obj-card this-a))
   
   obj-card)


 
 )