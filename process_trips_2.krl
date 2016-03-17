ruleset track_trips_2 {
  meta {
    name "Track Trips 2"
    description <<
Track trips ruleset
>>
    author "Steven Carroll"
    logging on
    sharing on
    provides process_trip, set_longest_length
 
  }
  
  global{
    getLongestLength = function() {
      length = ent:longest_length
      length
    }
  }

  rule process_trip is active {
    select when car new_trip mileage re#(\d+)# setting(length)
    always{  
      raise explicit event 'trip_processed'
        attributes event:attrs()
    }
  }

  rule find_long_trip is active {
    select when explicit trip_processed mileage re#(\d+)# setting(length)
    pre{
      longest_length = getLongestLength().klog("Getting the current longest trip length: ");
    }
    always { 
      set ent:longest_length length.klog("New longest trip length: ") if (length > longest_length);
      set ent:longest_length 0 if (true);
    }
  }
}
