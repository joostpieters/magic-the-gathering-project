#!r6rs

(library
 (card-creature)
 (export card-creature)
 (import (rnrs base (6))
         (magic double-linked-position-list)
         (magic cards card-combat-damage)
         (magic cards card-tappable)
         (magic object)
         (magic cards card-action))

 ;Class: card-creature
 (define (card-creature name color cost game player power toughness picture attr-lst . this-a)
   (define health toughness)
   (define special-attribs (position-list eq? attr-lst))
   
   (define blocker #f)
   (define attacks #f)
   
   (define (is-blocked! by)
     (if attacks
         (set! blocker by)
         (assertion-violation 'card-creature.is-blocked! "this creature doesn't even attack!" this by)))
   
   (define (attacks!)
     (set! attacks #t))
   
   (define (deal-damage)
     (if attacks
         (if blocker
             (damage-creature)
             (damage-player (let* ([players (game 'get-players)]
                                   [pos (players 'first-position)]
                                   [anopponentpos (players 'next pos)]) ; need to do this better (have choice)
                              (players 'value anopponentpos))))))
   
   (define (damage-player player)
     (((game 'get-field) 'get-stack-zone) 'push! (card-virtual-direct-combat-damage this player)))
   
   (define (damage-creature)
     (set! health toughness)
     (blocker 'set-health! (blocker 'get-toughness))
     (let ([stack ((game 'get-field) 'get-stack-zone)])
       (stack 'push! (card-virtual-blocked-combat-damage this blocker))
       (stack 'push! (card-virtual-blocked-combat-damage blocker this))))

   (define (can-block? attacker)
     #t) ; special-attribs should be calculated here
   
   (define (turn-end)
     (set! blocker #f)
     (set! attacks #f)
     (super 'turn-end))
   
   
   (define (get-power)
     power)
   (define (set-power! val)
     (set! power val))
   (define (get-toughness)
     toughness)
   (define (set-toughness! val)
     (set! toughness val))
   (define (get-health)
     health)
   (define (set-health! val)
     (set! health val))
   
   
   (define (get-special-attributes)
     special-attribs)
   (define (has-special-attribute? attrib)
     (special-attribs 'find attrib))
   (define (add-special-attribute! attrib)
     (if (not (special-attribs 'find attrib))
         (special-attribs 'add-after! attrib)))
   (define (remove-special-attribute! attrib)
     (let ((pos (special-attribs 'find attrib)))
       (if pos
           (special-attribs 'delete! pos))))
   
   (define (supports-type? type)
     (or (eq? type card-creature) (super 'supports-type? type)))
   (define (get-type)
     card-creature)
   
   (define (obj-card-creature msg . args)
     (case msg
       ((deal-damage) (apply deal-damage args))
       ((can-block?) (apply can-block? args))
       ((turn-end) (apply turn-end args))
       ((get-power) (apply get-power args))
       ((set-power!) (apply set-power! args))
       ((get-toughness) (apply get-toughness args))
       ((set-toughness!) (apply set-toughness! args))
       ((get-health) (apply get-health args))
       ((set-health!) (apply set-health! args))
       ((is-blocked!) (apply is-blocked! args))
       ((attacks!) (apply attacks! args))
       ((get-special-attributes) (apply get-special-attributes args))
       ((has-special-attribute?) (apply has-special-attribute? args))
       ((add-special-attribute!) (apply add-special-attribute! args))
       ((remove-special-attribute!) (apply remove-special-attribute! args))
       ((supports-type?) (apply supports-type? args))
       ((get-type) (apply get-type args))
       (else (apply super msg args))))
   
   (define this (extract-this obj-card-creature this-a))
   (define super (card-tappable name color cost game player picture this))
   
   (super 'add-action! (card-action "Attack"
                                    (lambda ()
                                      (and (eq? ((game 'get-phases) 'get-current-type) 'combat-declare-attackers)
                                           (eq? player (game 'get-active-player))))
                                    (lambda ()
                                      (attacks!))))
   (super 'add-action! (card-action "Block"
                                    (lambda ()
                                      (and (eq? ((game 'get-phases) 'get-current-type) 'combat-declare-blockers)
                                           (not (eq? player (game 'get-active-player)))))
                                    (lambda ()
                                    ;  ((gui 'wait-for-target-card-selection) 'is-blocked! this)
                                      'ok)))
   
   obj-card-creature)

 )