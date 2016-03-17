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
      long_trip = ent:long_trip
      long_trip
    }

    short_trips = function() {
      trip = ent:trip
      trip
    } 
  }

  rule collect_trips is active {
    select when explicit trip_processed mileage re#(\d+)# setting(length)
    pre {
      timestamp = time:now();
      map = trips();
      map2 = map.put([timestamp], length);
      mapString = map2.encode();
    }
    always {
      log "Trip processed: time=" + timestamp + " mileage=" + length;
      log "Updated trip map: " + mapString;
      set ent:trip{timestamp} length;
      log "Updated: " + ent:trip.encode();
    }
  }

  rule collect_long_trips is active {
    select when explicit found_long_trip mileage re#(\d+)# setting(length)
    pre {
      timestamp = time:now();
    }
    always{
      log "LONG TRIP PROCESSED: time=" + timestamp + " mileage=" + length;
    }
  }

  rule clear_trips is active {
    select when car trip_reset
    always {
      clear ent:trip;
      clear ent:long_trip;
    }
  } 
}