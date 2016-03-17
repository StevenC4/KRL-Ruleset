ruleset trip_store {
  meta {
    name "Trip Store"
    description <<
Trip store ruleset
>>
    author "Steven Carroll"
    logging on
    sharing on
    provides trips, long_trips, short_trips
  }
  
  global{
    trips = function() {
      trip = ent:trip || {}
      trip
    }

    long_trips = function() {
      long_trip = ent:long_trip || {}
      long_trip
    }

    short_trips = function() {
      trip = ent:trip.filter(function(k,v){not ent:long_trip.keys().has(k)}) || {}
      trip
    } 
  }

  rule collect_trips is active {
    select when explicit trip_processed mileage re#(\d+)# setting(length)
    pre {
      timestamp = time:now();
    }
    {
      send_directive("trip") with
        trips = map.encode({"canonical": true, "pretty": true})
        and short_trips = shortMap.encode({"canonical": true, "pretty": true});
    }
    always {
      log "Trip processed: time=" + timestamp + " mileage=" + length;
      set ent:trip{timestamp} length;
    }
  }

  rule collect_long_trips is active {
    select when explicit found_long_trip mileage re#(\d+)# setting(length)
    pre {
      timestamp = time:now();
    }
    always{
      log "Long trip processed: time=" + timestamp + " mileage=" + length;
      set ent:long_trip{timestamp} length; 
    }
  }

  rule clear_trips is active {
    select when car trip_reset
    always {
      clear ent:trip;
      clear ent:long_trip;
    }
  }

  rule get_trips is active {
    select when explicit fetch_trips
    pre{
      map = trips();
    }
    {
      send_directive("trip") with
        trips = map.encode({"canonical": true, "pretty": true})
    }
  } 

  rule get_long_trips is active {
    select when explicit fetch_long_trips
    pre{
      map = long_trips();
    }
    {
      send_directive("trip") with
        trips = map.encode({"canonical": true, "pretty": true})
    }
  } 

  rule get_short_trips is active {
    select when explicit fetch_short_trips
    pre{
      map = short_trips();
    }
    {
      send_directive("trip") with
        trips = map.encode({"canonical": true, "pretty": true})
    }
  }   
}