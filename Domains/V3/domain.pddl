
(define (domain RCLLV3)
;includes ring costs


(:requirements :durative-actions :typing)

(:types
    robot - object

    workpiece - object

    base - workpiece
    ring - workpiece
    cap - workpiece

    mps - object
    mpsState - object
    ringCost - object

    baseStation - mps
    ringStation - mps
    capStation - mps
    deliveryStation - mps
)

(:constants 
    free - ringCost             ;this color of ring is free
    one - ringCost              ;this color of ring costs 1 base
    two - ringCost              ;this color of ring costs 2 bases
    three - ringCost            ;this color of ring costs 3 bases

    idle - mpsState                 ;station is free to be used
    processing - mpsState           ;station is currently processing an order
    outputReady - mpsState          ;station has finished processing and has the output ready to be picked up; cannot start a new order (but can receive new inputs)
    noCapCarrierOutput - mpsState   ;station has no cap carrier on its output slot

    paymentSlot1Free - mpsState
    paymentSlot2Free - mpsState
    paymentSlot3Free - mpsState
)

(:predicates 
    (on ?topWP - workpiece ?bottomWP - workpiece)          
    (storedAt ?wp - workpiece ?s - mps)   

    (ringCost ?r - ring ?cost - ringCost)

    (delivered ?wp - workpiece)
    (disposed ?base - base)

    (holds ?r - robot ?wp - workpiece)             
    (available ?r - robot)                         
    (gripFree ?r - robot)
        
    (stationState ?s - mps ?state - mpsState)      
    (stationInput ?s - mps ?wp - workpiece)        
    (stationOutput ?s - mps ?wp - workpiece)

    (ringstationPaymentSlot1 ?s - ringStation ?b - base)
    (ringstationPaymentSlot2 ?s - ringStation ?b - base)
    (ringstationPaymentSlot3 ?s - ringStation ?b - base)    
)

; Movement actions

(:durative-action getWorkpiece
    :parameters (?r - robot ?s - mps ?wp - workpiece)
    :duration (= ?duration 44)
    :condition (and 
        (at start (and 
            (stationState ?s outputReady)
            (stationOutput ?s ?wp)
            (available ?r)
            (gripFree ?r)
        ))
    )
    :effect (and 
        (at start (and 
            (not (stationState ?s outputReady))
            (not (available ?r))
            (not (gripFree ?r))
        ))
        (at end (and 
            (stationState ?s idle)
            (not (stationOutput ?s ?wp))
            (available ?r)
            (holds ?r ?wp)
        ))
    )
)

(:durative-action addWorkpiece
    :parameters (?r - robot ?s - mps ?wp - workpiece)
    :duration (= ?duration 47)                              
    :condition (and                         
        (at start (and                                      
            (available ?r)
            (holds ?r ?wp)                        
        ))
        (over all (and
            (stationState ?s idle)                          
        ))
    )
    :effect (and 
        (at start (and                                      
            (not (available ?r))
        ))
        (at end (and                                        
            (stationInput ?s ?wp)
            (available ?r)
            (not (holds ?r ?wp))
            (gripFree ?r)
        ))
    )
)

; For Ring Station

(:durative-action addPaymentToRingStationSlot1
    :parameters (?r - robot ?rs - ringStation ?b - base)
    :duration (= ?duration 47)                              
    :condition (and                         
        (at start (and                                      
            (available ?r)
            (holds ?r ?b)
            (stationState ?rs paymentSlot1Free)
        ))
    )
    :effect (and 
        (at start (and                                      
            (not (available ?r))
        ))
        (at end (and                                        
            (ringstationPaymentSlot1 ?rs ?b)
            (not (stationState ?rs paymentSlot1Free))
            (available ?r)
            (not (holds ?r ?b))
            (gripFree ?r)
        ))
    )
)
(:durative-action addPaymentToRingStationSlot2
    :parameters (?r - robot ?rs - ringStation ?b - base)
    :duration (= ?duration 47)                              
    :condition (and                         
        (at start (and                                      
            (available ?r)
            (holds ?r ?b)
            (stationState ?rs paymentSlot2Free)
        ))
    )
    :effect (and 
        (at start (and                                      
            (not (available ?r))
        ))
        (at end (and                                        
            (ringstationPaymentSlot2 ?rs ?b)
            (not (stationState ?rs paymentSlot2Free))
            (available ?r)
            (not (holds ?r ?b))
            (gripFree ?r)
        ))
    )
)
(:durative-action addPaymentToRingStationSlot3
    :parameters (?r - robot ?rs - ringStation ?b - base)
    :duration (= ?duration 47)                              
    :condition (and                         
        (at start (and                                      
            (available ?r)
            (holds ?r ?b)
            (stationState ?rs paymentSlot3Free)
        ))
    )
    :effect (and 
        (at start (and                                      
            (not (available ?r))
        ))
        (at end (and                                        
            (ringstationPaymentSlot3 ?rs ?b)
            (not (stationState ?rs paymentSlot3Free))
            (available ?r)
            (not (holds ?r ?b))
            (gripFree ?r)
        ))
    )
)

; Base Station

(:durative-action dispenseBase
    :parameters (?bs - baseStation ?base - Base)
    :duration (= ?duration 3.8)                               
    :condition (and 
        (at start (and 
            (stationState ?bs idle)
            (storedAt ?base ?bs)
        ))
    )
    :effect (and 
        (at start (and                                      
            (not (stationState ?bs idle))
            (stationState ?bs processing)
        ))
        (at end (and                                        
            (not (stationState ?bs processing))
            (stationState ?bs outputReady)
            (stationOutput ?bs ?base)
            (not (storedAt ?base ?bs))
        ))
    )
)

; Ring Station

(:durative-action addRingToBase
    :parameters (?rs - ringStation ?wp - base ?r - ring)
    :duration (= ?duration 21.5)                               
    :condition (and 
        (at start (and                                      
            (stationState ?rs idle)
            (stationInput ?rs ?wp)
            (storedAt ?r ?rs)
        ))
    )
    :effect (and 
        (at start (and                                       
            (not (stationState ?rs idle))
            (stationState ?rs processing)
        ))
        (at end (and                                         
            (not (stationState ?rs processing))
            (stationState ?rs outputReady)
            (stationOutput ?rs ?r)
            (not (stationInput ?rs ?wp))
            (not (storedAt ?r ?rs))
            (on ?r ?wp)
        ))
    )
)

(:durative-action addRingToRing
    :parameters (?rs - ringStation ?wp - ring ?r - ring)
    :duration (= ?duration 21.5)                               
    :condition (and 
        (at start (and                                      
            (stationState ?rs idle)
            (stationInput ?rs ?wp)
            (storedAt ?r ?rs)
        ))
    )
    :effect (and 
        (at start (and                                      
            (not (stationState ?rs idle))
            (stationState ?rs processing)
        ))
        (at end (and                                        
            (not (stationState ?rs processing))
            (stationState ?rs outputReady)
            (stationOutput ?rs ?r)
            (not (stationInput ?rs ?wp))
            (not (storedAt ?r ?rs))
            (on ?r ?wp)
        ))
    )
)

(:durative-action addCost1RingToBase
    :parameters (?rs - ringStation ?wp - base ?r - ring ?payment - base)
    :duration (= ?duration 21.5)                              
    :condition (and 
        (at start (and                                     
            (stationState ?rs idle)
            (stationInput ?rs ?wp)
            (ringstationPaymentSlot1 ?rs ?payment)
            (storedAt ?r ?rs)
            (ringCost ?r one)
        ))
    )
    :effect (and 
        (at start (and                                       
            (not (stationState ?rs idle))
            (stationState ?rs processing)
        ))
        (at end (and                                         
            (not (stationState ?rs processing))
            (stationState ?rs outputReady)
            (stationState ?rs paymentSlot1Free)
            (stationOutput ?rs ?r)
            (not (stationInput ?rs ?wp))
            (not (ringstationPaymentSlot1 ?rs ?payment))
            (not (storedAt ?r ?rs))
            (on ?r ?wp)
            (disposed ?payment)
        ))
    )
)

(:durative-action addCost1RingToRing
    :parameters (?rs - ringStation ?wp - ring ?r - ring ?payment - base)
    :duration (= ?duration 21.5)                              
    :condition (and 
        (at start (and                                      
            (stationState ?rs idle)
            (stationInput ?rs ?wp)
            (ringstationPaymentSlot1 ?rs ?payment)
            (storedAt ?r ?rs)
            (ringCost ?r one)
        ))
    )
    :effect (and 
        (at start (and                                       
            (not (stationState ?rs idle))
            (stationState ?rs processing)
        ))
        (at end (and                                         
            (not (stationState ?rs processing))
            (stationState ?rs outputReady)
            (stationState ?rs paymentSlot1Free)
            (stationOutput ?rs ?r)
            (not (stationInput ?rs ?wp))
            (not (ringstationPaymentSlot1 ?rs ?payment))
            (not (storedAt ?r ?rs))
            (on ?r ?wp)
            (disposed ?payment)
        ))
    )
)

(:durative-action addCost2RingToBase
    :parameters (?rs - ringStation ?wp - base ?r - ring ?payment1 - base ?payment2 - base)
    :duration (= ?duration 21.5)                               
    :condition (and 
        (at start (and                                       
            (stationState ?rs idle)
            (stationInput ?rs ?wp)
            (ringstationPaymentSlot1 ?rs ?payment1)
            (ringstationPaymentSlot2 ?rs ?payment2)
            (storedAt ?r ?rs)
            (ringCost ?r one)
        ))
    )
    :effect (and 
        (at start (and                                       
            (not (stationState ?rs idle))
            (stationState ?rs processing)
        ))
        (at end (and                                         
            (not (stationState ?rs processing))
            (stationState ?rs outputReady)
            (stationState ?rs paymentSlot1Free)
            (stationState ?rs paymentSlot2Free)
            (stationOutput ?rs ?r)
            (not (stationInput ?rs ?wp))
            (not (ringstationPaymentSlot1 ?rs ?payment1))
            (not (ringstationPaymentSlot2 ?rs ?payment2))
            (not (storedAt ?r ?rs))
            (on ?r ?wp)
            (disposed ?payment1)
            (disposed ?payment2)
        ))
    )
)
(:durative-action addCost2RingToRing
    :parameters (?rs - ringStation ?wp - ring ?r - ring ?payment1 - base ?payment2 - base)
    :duration (= ?duration 21.5)                              
    :condition (and 
        (at start (and                                       
            (stationState ?rs idle)
            (stationInput ?rs ?wp)
            (ringstationPaymentSlot1 ?rs ?payment1)
            (ringstationPaymentSlot2 ?rs ?payment2)
            (storedAt ?r ?rs)
            (ringCost ?r one)
        ))
    )
    :effect (and 
        (at start (and                                      
            (not (stationState ?rs idle))
            (stationState ?rs processing)
        ))
        (at end (and                                         
            (not (stationState ?rs processing))
            (stationState ?rs outputReady)
            (stationState ?rs paymentSlot1Free)
            (stationState ?rs paymentSlot2Free)
            (stationOutput ?rs ?r)
            (not (stationInput ?rs ?wp))
            (not (ringstationPaymentSlot1 ?rs ?payment1))
            (not (ringstationPaymentSlot2 ?rs ?payment2))
            (not (storedAt ?r ?rs))
            (on ?r ?wp)
            (disposed ?payment1)
            (disposed ?payment2)
        ))
    )
)

(:durative-action addCost3RingToBase
    :parameters (?rs - ringStation ?wp - base ?r - ring ?payment1 - base ?payment2 - base ?payment3 - base)
    :duration (= ?duration 21.5)                            
    :condition (and 
        (at start (and                                       
            (stationState ?rs idle)
            (stationInput ?rs ?wp)
            (ringstationPaymentSlot1 ?rs ?payment1)
            (ringstationPaymentSlot2 ?rs ?payment2)
            (ringstationPaymentSlot3 ?rs ?payment3)
            (storedAt ?r ?rs)
            (ringCost ?r one)
        ))
    )
    :effect (and 
        (at start (and                                       
            (not (stationState ?rs idle))
            (stationState ?rs processing)
        ))
        (at end (and                                
            (not (stationState ?rs processing))
            (stationState ?rs outputReady)
            (stationState ?rs paymentSlot1Free)
            (stationState ?rs paymentSlot2Free)
            (stationState ?rs paymentSlot3Free)
            (stationOutput ?rs ?r)
            (not (stationInput ?rs ?wp))
            (not (ringstationPaymentSlot1 ?rs ?payment1))
            (not (ringstationPaymentSlot2 ?rs ?payment2))
            (not (ringstationPaymentSlot2 ?rs ?payment3))
            (not (storedAt ?r ?rs))
            (on ?r ?wp)
            (disposed ?payment1)
            (disposed ?payment2)
            (disposed ?payment3)
        ))
    )
)
(:durative-action addCost3RingToRing
    :parameters (?rs - ringStation ?wp - ring ?r - ring ?payment1 - base ?payment2 - base ?payment3 - base)
    :duration (= ?duration 21.5)                               
    :condition (and 
        (at start (and                                       
            (stationState ?rs idle)
            (stationInput ?rs ?wp)
            (ringstationPaymentSlot1 ?rs ?payment1)
            (ringstationPaymentSlot2 ?rs ?payment2)
            (ringstationPaymentSlot3 ?rs ?payment3)
            (storedAt ?r ?rs)
            (ringCost ?r one)
        ))
    )
    :effect (and 
        (at start (and                                       
            (not (stationState ?rs idle))
            (stationState ?rs processing)
        ))
        (at end (and                                         
            (not (stationState ?rs processing))
            (stationState ?rs outputReady)
            (stationState ?rs paymentSlot1Free)
            (stationState ?rs paymentSlot2Free)
            (stationState ?rs paymentSlot3Free)
            (stationOutput ?rs ?r)
            (not (stationInput ?rs ?wp))
            (not (ringstationPaymentSlot1 ?rs ?payment1))
            (not (ringstationPaymentSlot2 ?rs ?payment2))
            (not (ringstationPaymentSlot2 ?rs ?payment3))
            (not (storedAt ?r ?rs))
            (on ?r ?wp)
            (disposed ?payment1)
            (disposed ?payment2)
            (disposed ?payment3)
        ))
    )
)
; Cap Station

(:durative-action prepareCap
    :parameters (?cs - capStation ?c - Cap ?cB - Base)
    :duration (= ?duration 20.3)                             
    :condition (and 
        (at start (and                                     
            (stationState ?cs idle)
            (stationState ?cs noCapCarrierOutput)
            (storedAt ?c ?cs)
            (on ?c ?cB)
        ))
    )
    :effect (and 
        (at start (and                                     
            (not (stationState ?cs idle))
            (stationState ?cs processing)
        ))
        (at end (and                                        
            (not (stationState ?cs processing))
            (not (stationState ?cs noCapCarrierOutput))              
            (stationOutput ?cs ?cB)
            (not (storedAt ?c ?cs))    
            (stationInput ?cs ?c)                     
            (not (on ?c ?cB))
        ))
    )
)

(:durative-action addCapToBase
    :parameters (?cs - capStation ?wp - base ?c - Cap) 
    :duration (= ?duration 22)                              
    :condition (and 
        (at start (and                                      
            (stationState ?cs idle)
            (stationInput ?cs ?wp)
            (stationInput ?cs ?c)
        ))
    )
    :effect (and 
        (at start (and                                     
            (not (stationState ?cs idle))
            (stationState ?cs processing)
        ))
        (at end (and                                       
            (not (stationState ?cs processing))
            (stationState ?cs outputReady)
            (stationOutput ?cs ?c)        
            (not (stationInput ?cs ?wp))
            (not (stationInput ?cs ?c))
            (on ?c ?wp)
        ))
    )
)

(:durative-action addCapToRing
    :parameters (?cs - capStation ?wp - ring ?c - Cap) 
    :duration (= ?duration 22)                             
    :condition (and 
        (at start (and                                    
            (stationState ?cs idle)
            (stationInput ?cs ?wp)
            (stationInput ?cs ?c)
        ))
    )
    :effect (and 
        (at start (and                                   
            (not (stationState ?cs idle))
            (stationState ?cs processing)
        ))
        (at end (and                                        
            (not (stationState ?cs processing))
            (stationState ?cs outputReady)
            (stationOutput ?cs ?c)        
            (not (stationInput ?cs ?wp))
            (not (stationInput ?cs ?c))
            (on ?c ?wp)
        ))
    )
)

(:durative-action getCapCarrier
    :parameters (?r - robot ?cs - capStation ?b - base)
    :duration (= ?duration 44)
    :condition (and 
        (at start (and 
            (stationOutput ?cs ?b)
            (available ?r)
            (gripFree ?r)
        ))
    )
    :effect (and 
        (at start (and 
            (not (available ?r))
            (not (gripFree ?r))
        ))
        (at end (and 
            (stationState ?cs idle)
            (not (stationOutput ?cs ?b))
            (available ?r)
            (holds ?r ?b)
            (stationState ?cs noCapCarrierOutput)
        ))
    )
)

; Delivery Station

(:durative-action deliverProduct
    :parameters (?ds - deliveryStation ?product - cap)
    :duration (= ?duration 5.7)                             
    :condition (and 
        (at start (and 
            (stationState ?ds idle)
            (stationInput ?ds ?product)
        ))
    )
    :effect (and 
        (at start (and 
            (not (stationState ?ds idle))
            (stationState ?ds processing)       
        ))
        (at end (and 
            (not (stationState ?ds processing))
            (stationState ?ds idle)
            (not (stationInput ?ds ?product))
            (delivered ?product)
        ))
    )
)

(:durative-action disposeBase
    :parameters (?ds - deliveryStation ?b - base)
    :duration (= ?duration 5.7)                      
    :condition (and 
        (at start (and 
            (stationState ?ds idle)
            (stationInput ?ds ?b)
        ))
    )
    :effect (and 
        (at start (and 
            (not (stationState ?ds idle))
            (stationState ?ds processing)       
        ))
        (at end (and 
            (not (stationState ?ds processing))
            (stationState ?ds idle)
            (not (stationInput ?ds ?b))
            (disposed ?b)
        ))
    )
)
)

