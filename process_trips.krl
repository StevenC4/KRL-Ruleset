ruleset process_trips {
  meta {
    name "Hello World"
    description <<
Process trips ruleset
>>
    author "Steven Carroll"
    logging on
    sharing on
    provides process_trip
 
  }

  rule process_trip is active {
    select when car trip mileage "(.*)" setting(length)
    send_directive("trip") with
      trip_length = length;
  }
}