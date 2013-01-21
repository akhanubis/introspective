introspective
=============

A set of Ruby methods coded in C for getting access to structs and vars used by Ruby's inner core.

Implemented so far
------------
* Access nth order singleton classes and metaclasses bypassing the Ruby method singleton_class and thus breaking integrity.
* Access include classes (ICLASS).
* Access the attached object of a singleton class.
* Access the class of an include class.
* Check if a class is a singleton class.
* Check if a class is an include class.

Usage and some insights
------------

```ruby
$ irb
irb(main):001:0> load 'introspective.rb'
=> true
irb(main):007:0> String.class
#the real class of String (ignoring singleton classes and include classes)
=> Class
irb(main):008:0> String.get_klass
#the class of String (in this case, it is its singleton class)
=> #<Class:String>
irb(main):009:0> String.superclass
#the real superclass of String (goes up in the ancestors chain until it finds a normal class (not singleton, not include))
=> Object
irb(main):010:0> String.get_super
#String includes Comparable, so String's superclass is actually an include class of Comparable
(Object doesn't support #inspect)
=>
irb(main):011:0> IClassAnalizer.is_iclass(String)
#String is not an include class
=> false
irb(main):012:0> IClassAnalizer.is_iclass(String.get_super)
#the superclass of String was an include class of Comparable
=> true
irb(main):013:0> IClassAnalizer.get_klass(String.get_super)
#the class of an include class is the module which it includes
=> Comparable
irb(main):017:0> String.nklass(2)
#metaclass = singleton class of an instance of Class
#the class of the class of String (aka the metametaclass of String, aka the class of the metaclass of String)
=> #<Class:#<Class:String>>
irb(main):018:0> String.nklass(3)
#the class of the class of the class of String (aka the metametametaclass of String)
#here is something interesting. every class has a metaclass, so in theory there are infinit metaclasses of each class
#Ruby tackles this with lazy creation of metaclasses, but because we aren't triggering this creation using Ruby's methods << or singleton_class
#we see that the class of the last "created" metaclass of a class is the metaclass of Class of the same order (check comment in class.c line 321)
#in this case, the class of the metametametaclass of String is the metametametaclass of Class
=> #<Class:#<Class:Class>>
irb(main):019:0> String.nklass(4)
#lastly, the class of the last "created" meta^nclass of Class is itself. 
=> #<Class:#<Class:#<Class:Class>>>
irb(main):020:0> String.nklass(5)
=> #<Class:#<Class:#<Class:Class>>>
irb(main):021:0> String.nklass(20)
=> #<Class:#<Class:#<Class:Class>>>
irb(main):022:0> String.nklass(5).object_id
=> 19801524
irb(main):023:0> String.nklass(20).object_id
=> 19801524
#lets see what happens when we actually create the meta^nclasses of String until n = 10
irb(main):024:0> String.nclass(10)
#so now we created 10 actual instances of metaclasses
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:String>>>>>>>>>>
irb(main):025:0> String.nklass(10)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:String>>>>>>>>>>
irb(main):026:0> String.nklass(11)
#to ensure class hierarchy integrity, Ruby creates the metaclass of a class when the class is created
#this also applies to metaclasses, so by creating the meta^10class we force the creation of the meta^11class
#(we also force the creation of the meta^nclasses for the superclasses)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:String>>>>>>>>>>>
irb(main):027:0> String.nklass(12)
#but, as we expected, the meta^11class of String was created with its class pointing to the meta^11class of Class 
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>>
irb(main):028:0> String.nklass(13)
#and the meta^11class of Class keeps being self referential
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>>
irb(main):038:0> String.nklass(12).attached_object
#finally, lets check that the object attached to the last meta^nclass of Class created its itself
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>
irb(main):039:0> String.nklass(500).attached_object
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>
```

Requirements
------------
gem "RubyInline", "~> 3.12.0"
