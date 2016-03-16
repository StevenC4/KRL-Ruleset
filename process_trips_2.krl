ruleset track_trips_2 {
  meta {
    name "Track Trips 2"
    description <<
Track trips ruleset
>>
    author "Steven Carroll"
    logging on
    sharing on
    provides process_trip
 
  }
  global{
    longest_length = 0;
  }

  rule process_trip is active {
    select when explicit trip_processed where mileage > longest_length setting(length) 
    longest_length(attr:length)
    send_directive("trip") with
      trip_length = attr:length;
  }
}