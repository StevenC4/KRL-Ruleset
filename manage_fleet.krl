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
    }
    {
      noop();
    }
    always{
      raise wrangler event "child_creation"
      attributes attr.klog("attributes: ");
      log("create child for " + child);
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
      noop();
    }
    always{
      raise wrangler event 'pending_subscription_approval'
          attributes attributes;        
          log("auto accepted subcription.");
    }
  }
}