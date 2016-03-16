ruleset track_trips_2 {
  meta {
    name "Hello World"
    description <<
Track trips ruleset
>>
    author "Steven Carroll"
    logging on
    sharing on
    provides process_trip
 
  }

  rule process_trip is active {
    select when explicit trip_processed mileage "(.*)" setting(length)
    send_directive("trip") with
      trip_length = length;
  }
}