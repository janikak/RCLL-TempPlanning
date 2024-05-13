;Header and description

(define (domain RCLLV0)
; C0, no cap carriers, no delivery


(:requirements :durative-actions :typing)

(:types
    robot - object

    workpiece - object

    base - workpiece
    cap - workpiece

    mps - object
    mpsState - object

    baseStation - mps
    capStation - mps
)

(:constants 
    idle - mpsState                 ;station is free to be used
    processing - mpsState           ;station is currently processing an order
    outputReady - mpsState          ;station has finished processing and has the output ready to be picked up; cannot start a new order (but can receive new inputs)
)

(:predicates 
    (on ?topWP - cap ?bottomWP - base)          
    (storedAt ?wp - workpiece ?s - mps)   

    (holds ?r - robot ?wp - workpiece)                      
    (available ?r - robot)                                 
    (gripFree ?r - robot)

    (stationState ?s - mps ?state - mpsState)               
    (stationInput ?s - mps ?wp - workpiece)                 
    (stationOutput ?s - mps ?wp - workpiece)    
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

(:durative-action addCap
    :parameters (?cs - capStation ?wp - Base ?c - Cap)
    :duration (= ?duration 22)                              
    :condition (and 
        (at start (and                                      
            (stationState ?cs idle)
            (stationInput ?cs ?wp)
            (storedAt ?c ?cs)
        ))
    )
    :effect (and 
        (at start (and                                      
            (not (stationState ?cs idle))
            (stationState ?cs processing)
        ))
        (at end (and                                        
            (not (stationState ?cs processing))
            (stationState ?cs idle)                         
            (stationOutput ?cs ?c)
            (not (stationInput ?cs ?wp))
            (not (storedAt ?c ?cs))
            (on ?c ?wp)
        ))
    )
)

)

