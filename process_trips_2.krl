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

    setLongestLength = function(length) {
      longest_length = length;
      {}
    }

  }

  rule process_trip is active {
    select when explicit trip_processed mileage re#(\d+)# setting(length)
    pre{
      test = event:attr("mileage").klog("Storing mileage: ");
    }
    if (test > longest_length) then {
      setLongestLength(test); 
      send_directive("trip") with
        trip_length = test;
    }
  }
}
