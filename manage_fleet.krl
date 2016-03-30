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

    cloud_url = "https://#{meta:host()}/sky/cloud/";
        
    cloud = function(eci, mod, func, params) {
        response = http:get("#{cloud_url}#{mod}/#{func}", (params || {}).put(["_eci"], eci));


        status = response{"status_code"};


        error_info = {
            "error": "sky cloud request was unsuccesful.",
            "httpStatus": {
                "code": status,
                "message": response{"status_line"}
            }
        };


        response_content = response{"content"}.decode();
        response_error = (response_content.typeof() eq "hash" && response_content{"error"}) => response_content{"error"} | 0;
        response_error_str = (response_content.typeof() eq "hash" && response_content{"error_str"}) => response_content{"error_str"} | 0;
        error = error_info.put({"skyCloudError": response_error, "skyCloudErrorMsg": response_error_str, "skyCloudReturnValue": response_content});
        is_bad_response = (response_content.isnull() || response_content eq "null" || response_error || response_error_str);


        // if HTTP status was OK & the response was not null and there were no errors...
        (status eq "200" && not is_bad_response) => response_content | error
    };
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
        with child_name = child_name;
    }
    always{
      log("create child for " + child_name);
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

  rule fetch_children is active {
    select when car fetch_vehicles
    pre{
      children = vehicles().klog("Children: ");
    }
    {
      send_directive("Children: ")
        with children = children;
    }
  }

  rule call_trips_function is active {
    select when explicit get_trips
      foreach vehicles() setting(child)
        pre{
          childEci = child[0].klog("Child eci: ");
          trips = cloud(childEci,'b507734x3.prod','trips');
        }
        {
          send_directive("Called trips()") with trips = trips and eci = childEci;
        }
  }

  rule auto_accept is active {
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

  rule request_report is active {
    select when fleet request_report
    foreach vehicles() setting(child)
      pre{
        childEci = child[0].klog("Child eci: ");
      }
      {
        event:send({"cid":childEci}, "car", "send_report"); 
      }
  }

  rule collect_trip_reports is active {
    select when fleet collect_trip
    {
      log("Collecting trips");
    }
  }
}