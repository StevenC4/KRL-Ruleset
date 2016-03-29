ruleset manage_fleet {
  meta {
    name "Manage fleet"
    description <<
Ruleset for managing your fleet of vehicles
>>
    author "Steven Carroll"
    logging on
    sharing on
 
  }

  global {
    vehicles = function(){
      results = wranglerOS:children();
      children = results{"children"};
      children;
    };
  }

  rule create_vehicle is active {
    select when car new_vehicle
    pre{
      child_name = "Vehicle_" + random:uuid();
      attr = {}
        .put(["Prototype_rid"],"b507734x3.prod")
        .put(["name"],child_name)
        .put(["parent_eci"],meta:eci());
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "child_creation")  // wrangler os event.
      with attrs = attributes.klog("attributes: "); // needs a name attribute for child
    }
    always{
      log("create child for " + child);
    }
  }

  rule delete_vehicle is active {
    select when car unneeded_vehicle
    pre{
      child_name = "Vehicle_" + random:uuid();
      attr = {}
        .put(["Prototype_rid"],"b507734x3.prod")
        .put(["name"],child_name)
    }
  }  

  rule autoAccept {
    select when wrangler inbound_pending_subscription_added 
    pre{
      attributes = event:attrs().klog("subcription :");
    }
    {
      send_directive("Accepting subscription");
      noop();
    }
    always{
      raise wrangler event 'pending_subscription_approval'
          attributes attributes;        
          log("auto accepted subcription.");
    }
  }
}