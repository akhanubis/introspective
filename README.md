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
```
The real class of String (ignoring singleton classes and include classes)
```ruby
irb(main):007:0> String.class
=> Class
```
The class of String (in this case, it is its singleton class)
```ruby
irb(main):008:0> String.get_klass
=> #<Class:String>
```
The real superclass of String (goes up in the ancestors chain until it finds a normal class (not singleton, not include))
```ruby
irb(main):009:0> String.superclass
=> Object
```
String includes Comparable, so String's superclass is actually an include class of Comparable
```ruby
irb(main):010:0> String.get_super
(Object doesn't support #inspect)
=>
```
String is not an include class
```ruby
irb(main):011:0> IClassAnalizer.is_iclass(String)
=> false
```
The superclass of String was an include class of Comparable
```ruby
irb(main):012:0> IClassAnalizer.is_iclass(String.get_super)
=> true
```
The class of an include class is the module which it includes
```ruby
irb(main):013:0> IClassAnalizer.get_klass(String.get_super)
=> Comparable
```
From now on I will refer to metaclass as singleton class of class(an instance of Class). Metaclass is an special type of singleton class. 
The class of the class of String (aka the metametaclass of String, aka the class of the metaclass of String)
```ruby
irb(main):017:0> String.nklass(2)
=> #<Class:#<Class:String>>
```
The class of the class of the class of String (aka the metametametaclass of String). Here is something interesting: every class has a metaclass, so in theory there are infinit metaclasses of each class. Ruby tackles this with lazy creation of metaclasses, but because we aren't triggering this creation using Ruby's methods << or singleton_class, we can see that the class of the last "created" metaclass of a class is the metaclass of Class of the same order (check comment in class.c line 321). In this case, the class of the metametametaclass of String is the metametametaclass of Class
```ruby
irb(main):018:0> String.nklass(3)
=> #<Class:#<Class:Class>>
irb(main):019:0> String.nklass(4)
```
Finally, the class of the last "created" meta^nclass of Class is itself 
```ruby
=> #<Class:#<Class:#<Class:Class>>>
irb(main):020:0> String.nklass(5)
=> #<Class:#<Class:#<Class:Class>>>
irb(main):021:0> String.nklass(20)
=> #<Class:#<Class:#<Class:Class>>>
irb(main):022:0> String.nklass(5).object_id
=> 19801524
irb(main):023:0> String.nklass(20).object_id
=> 19801524
```
Lets see what happens when we actually create the meta^nclasses of String until n = 10 by calling String.singleton_class.singleton_class.singleton_class.etc
```ruby
irb(main):024:0> String.nclass(10)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:String>>>>>>>>>>
irb(main):025:0> String.nklass(10)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:String>>>>>>>>>>
```
To ensure class hierarchy integrity, Ruby creates the metaclass of a class when the class is created. This also applies to metaclasses, so by creating the meta^10class we force the creation of the meta^11class (we also force the creation of the meta^nclasses for the superclasses)
```ruby
irb(main):026:0> String.nklass(11)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:String>>>>>>>>>>>
```
But, as we expected, the meta^11class of String was created with its class pointing to the meta^11class of Class 
```ruby
irb(main):027:0> String.nklass(12)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>>
```
And the meta^11class of Class keeps being self referential
```ruby
irb(main):028:0> String.nklass(13)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>>
```
Finally, lets check that the object attached to the last meta^nclass of Class created its itself
```ruby
irb(main):038:0> String.nklass(12).attached_object
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>
irb(main):039:0> String.nklass(500).attached_object
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>
```

Requirements
------------
gem "RubyInline", "~> 3.12.0"
