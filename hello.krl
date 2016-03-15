ruleset hello_world {
  meta {
    name "Hello World"
    description <<
A first ruleset for the Quickstart
>>
    author "Phil Windley"
    logging on
    sharing on
    provides hello
 
  }
  global {
    hello = function(obj) {
      msg = "Hello " + obj
      msg
    };
 
  }
  rule hello_name {
    select when echo hello name "(.*)"
    pre{
      name = event:attr("name").klog("our passed in Name: ");
    }
    {
      send_directive("say") with
        something = "Hello #{name}";
    }
    always{
      log ("LOG says Hello " + name);
    }
  }

  rule hello_world is active {
    select when echo hello
    send_directive("say") with
      something = "Hello World";
  }
   
  rule echo is active {
    select when echo message input "(.*)" setting(m)
    send_directive("say") with
      something = m;
  }
}