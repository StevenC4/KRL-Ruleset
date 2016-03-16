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
      length = ent:longest_length || 0
      length
    }
  }

  rule process_trip is active {
    select when explicit trip_processed mileage re#(\d+)# setting(length)
    pre{
      longest_length = getLongestLength()
    }
    {
      send_directive("trip") with
        trip_length = length and longest_length = getLongestLength()
    }
    always { 
      set ent:longest_length test if (length > longest_length);
    }
  }
}
