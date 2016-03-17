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
    always {  
      raise explicit event 'trip_processed'
        attributes event:attrs()
    }
  }

  rule find_long_trip is active {
    select when explicit trip_processed
    pre {
      length = event:attr('mileage').klog("Mileage: ");
    }
    if (length > long_trip) then {
      send_directive("Registering a long trip: " + length);
    }
    fired {
      log "Is a long trip: " + length;
      raise explicit event 'found_long_trip'
        attributes event:attrs() if (length > long_trip);
    }
    else {
      log "Is a short trip: " + length;
    }
  }
}