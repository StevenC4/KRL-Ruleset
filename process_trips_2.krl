ruleset track_trips_2 {
  meta {
    name "Track Trips 2"
    description <<
Track trips ruleset
>>
    author "Steven Carroll"
    logging on
    sharing on
    provides long_trip

  }

  global {
    long_trip = 50
  }

  rule process_trip is active {
    select when car new_trip mileage re#(\d+)# setting(length)
    always{  
      raise explicit event 'trip_processed'
        attributes event:attrs()
    }
  }

  rule find_long_trip is active {
    select when explicit trip_processed
    pre{
      length = event:attr('mileage').klog("Mileage: ");
    }
    always{
      log "Is a long trip" if (length > long_trip);  
      raise explicit event 'tested'
        attributes event:attrs();
    }
  }

  rule test_rule is active {
    select when explicit test
    always{
      log "Here we go"
    }
  }
}