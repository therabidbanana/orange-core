Orange
======

Orange is intended to be a middle ground between the simplicity of Sinatra 
and the power of Rails. It also throws a bit of django's auto admin interface
into the mix. Orange is being developed by Orange Sparkle Ball, inc
for developing websites for our clients quickly and efficiently, but certainly 
could be adapted to other uses... if you come up with something creative, let
us know.

orange-core represents the core dependencies for orange applications. If you want
a full featured Orange-based CMS (where the automatic admin interface comes in), 
look at [orange-sparkles](http://github.com/orange-project/orange-sparkles).

**Note**: Orange is still in a "beta" stage. Test coverage is lack-luster at best. The library is being used on a few currently live (low traffic) sites, so it might be stable enough to use on your own projects let us know if you have issues.

More Info
=========

Orange Philosophy
-----------------
The Orange application framework is intended to be a fully customizable CMS
capable of hosting sites while maintaining Sinatra-like ease of 
programming. Some core ideas behind Orange:

* We believe in magic - as long as it's not the evil kind
* Put as much functionality into middleware as possible, so it can be easily reused
  and remixed
* Give middleware a little more power so it's useful enough to handle more tasks


Should I Use Orange?
--------------------

    "I want to create a quick RESTful web service that does one thing and does it well"

Sinatra is probably better for this kind of thing. It's perfect for creating quick web apps based on RESTful
ideals. Or perhaps use a Sinatra clone built on Orange, so you can incorporate orange plugins and built in 
database support... but such a clone doesn't exist [does it](http://github.com/therabidbanana/orange-juice)?

    "I want to create a powerful web application that needs to be rock solid and use a 
    well-tested foundation"

No. This is where Ruby on Rails shines, it's a well supported, thoroughly tested framework
for building web applications that gives you everything you need for the lifecycle of your
application

    "I want to deploy a website on Ruby that has some dynamic elements, maybe allowing me
    to create my own plugin without jumping through too many hoops."
    
Yes. This is what orange was designed for - we're building it to be able to quickly deploy
websites that can have a Ruby base without the heavy-weight Ruby on Rails backend, but also 
without feeling like you have to start from scratch like it feels in Sinatra.


Required Gems
-------------

orange-core tries to stay light on the dependencies. 

* dm-core (+ dm-[sqlite3|mysql|...]-adapter )
* dm-migrations
* rack
* haml
* crack

All dependencies should be loaded if you install the gem except for the datamapper
adapter relevant to your set up. If, for example, you want to use a mysql database,
you'll need to install dm-mysql-adapter, and for an sqlite3 database, you'll need dm-sqlite-adapter


Also, you'll need a web server of some kind and need to set it up for rack. Rack supports
WEBrick out of the box if you just want to play around though.

**Testing** 

If you want to test, you'll need the following gems:

* rspec
* rack-test

Yard is also helpful for generating API docs

The following are useful rake tasks for testing purposes:

    * rake test   =>  (same as rake spec)
    * rake spec   =>  runs rspec with color enabled and spec_helper included
    * rake doc    =>  runs yardoc (no, not really necessary)
    * rake clean  =>  clear out the temporary files not included in the repo
    * rake rcov   =>  runs rspec with rcov

For my own reference - jeweler rake task for deploying the new gem:

    * rake version:bump:patch release
    
Programming Info
================

The basics of using the orange framework...

Terminology
-----------

* **Application**: The last stop for the packet after traversing through the middleware stack.
* **Core**: This is the core orange object, accessible from all points of the orange 
  system. Usually the orange instance can be called by simply using the "orange" function
* **Mixins**: Extra functionality added directly to the core. Mixins are generally for only
  a couple of extra methods, anything more should probably be created as a resource.
* **Packet**: This object represents a web request coming in to the orange system. 
  Each request is instantiated as a packet before it is sent through the middleware stack.
* **Pulp**: Mixin added to the packet object rather than the Core.
* **Resources**: Resources are extra functionality contained within an object, accessible
  from the core. 
* **Stack**: The bundled collection of Orange-enhanced middleware sitting on top of the 
  Orange application

Pulp and Mixins
---------------
The ability to add pulp and mixins is incredibly handy because the packet and the core are 
available from just about anywhere in the Orange framework. For instance, the haml parser
evaluates all local calls as if made to the packet, so adding pulp is essentially adding 
functionality that is directly available to haml.


LICENSE:
=========
(The MIT License)

Copyright © 2009 Orange Sparkle Ball, inc

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.