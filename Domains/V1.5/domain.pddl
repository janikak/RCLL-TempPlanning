
(define (domain RCLLV1_colors)
; Only C0, no rings, no ringstation, colors


(:requirements :durative-actions :typing)

(:types
    robot - object

    workpiece - object
    workpieceColor - object

    base - workpiece
    cap - workpiece

    mps - object
    mpsState - object

    baseStation - mps
    capStation - mps
    deliveryStation - mps
)

(:constants 
    red - workpieceColor 		    ;base 
    silver - workpieceColor 	    ;base 
    black - workpieceColor 		    ;base+cap
    grey - workpieceColor		    ;cap

    idle - mpsState                 ;station is free to be used
    processing - mpsState           ;station is currently processing an order
    outputReady - mpsState          ;station has finished processing and has the output ready to be picked up; cannot start a new order (but can receive new inputs)
    noCapCarrierOutput - mpsState   ;station has no cap carrier on its output slot
)

(:predicates 
    (color ?wp - workpiece ?c - workpieceColor)             ;defined in initial state: Workpiece wp has color c (c is constant)

    (on ?topWP - cap ?bottomWP - base)             
    (storedAt ?wp - workpiece ?s - mps)   

    (delivered ?wp - workpiece)
    (disposed ?base - base)

    (holds ?r - robot ?wp - workpiece)             ; Robot r holds workpiece wp (multiple, connected workpieces are defined by the topmost piece)
    (available ?r - robot)        
    (gripFree ?r - robot)                 
        
    (stationState ?s - mps ?state - mpsState)    ; Station s is in the mpsState state (state is a consant)
    (stationInput ?s - mps ?wp - workpiece)        ; Workpiece wp is in the input area of station s
    (stationOutput ?s - mps ?wp - workpiece)       ; Workpiece wp is in the output area of station s
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
            (gripFree ?r)
            (not (holds ?r ?wp))
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

(:durative-action addCap
    :parameters (?cs - capStation ?wp - Base ?c - Cap)
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

