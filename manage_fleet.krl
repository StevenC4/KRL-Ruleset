ruleset manage_fleet {
  meta {
    name "Manage fleet"
    description <<
Ruleset for managing your fleet of vehicles
>>
    use module  b507199x5 alias wrangler_api
    author "Steven Carroll"
    logging on
    sharing on
 
  }

  global {
    vehicles = function(){
      results = wrangler_api:children();
      children = results{"children"};
      children;
    }
  }

  rule create_vehicle is active {
    select when car new_vehicle
    pre{
      child_name = "Vehicle_" + random:uuid();

      attr = {}
        .put(["Prototype_rids"],"b507734x3.prod")
        .put(["name"],child_name);
      cid = meta:eci();
    }
    {
      event:send({"cid":cid}, "wrangler", "child_creation") with attrs = attr.klog("Attributes: ");
      send_directive("Creating vehicle") 
        with child_name = child_name and
        cid = cid;
    }
    always{
      log("create child for " + child_name);
    }
  }

  rule delete_vehicle is active {
    select when car unneeded_vehicle
    pre{
      childEci = event:attr("eci");
      childDeletionAttrs = {}.put(["deletionTarget"], childEci).klog("Deletion attributes: ");
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "child_deletion") with attrs = childDeletionAttrs;
    }
  }

  rule unsubscribe_vehicle is active {
    select when car unneeded_vehicle
    pre{
      channelName = event:attr("name");
      childUnsubscriptionAttrs = {}.put(["channel_name"], channelName).klog("Unsubscription attributes: ");
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "subscription_cancellation") with attrs = childUnsubscriptionAttrs;
    }
  }

  rule fetch_children is active {
    select when fleet fetch_vehicles
    pre{
      children = vehicles().klog("Children: ");
    }
    {
      send_directive("Children: ")
        with children = children;
    }
  }


  rule auto_accept is active {
    select when wrangler inbound_pending_subscription_added 
    pre{
      attributes = event:attrs().klog("subcription :");
    }
    {
      send_directive("Accepting subscription");
    }
    always{
      raise wrangler event 'pending_subscription_approval'
          attributes attributes;        
          log("auto accepted subcription.");
    }
  }
}