ruleset trip_store {
  meta {
    name "Trip Store"
    description <<
Trip store ruleset
>>
    author "Steven Carroll"
    logging on
    sharing on
    provides collect_trips
 
  }
  
  global{
    
  }

  rule collect_trips is active {
    select when car new_trip mileage re#(\d+)# setting(length)
    always{  
      raise explicit event 'trip_processed'
        attributes event:attrs()
    }
  }
}
