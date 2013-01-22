introspective
=============

A set of Ruby methods coded in C for getting access to structs and vars used by Ruby's inner core.

Implemented so far
------------
* an_object.nth_klass(n) Access nth order singleton classes and metaclasses bypassing the Ruby method singleton_class and thus breaking integrity.
* an_object.nth_class(n) Access nth order singleton classes and metaclasses invoking .class n times (ignores singleton classes).
* an_object.nth_singleton_class(n) Access nth order singleton classes and metaclasses invoking .singleton_class n times.
* an_object.klass Get the actual class of an_object: RBASIC(an_object)->klass.
* a_class.zuperclass Get the actual superclass of a_class (can retrieve singleton and include classes).
* a_module.zuperclass Get the actual superclass of a_module (it is always false unless a_module includes another_module in which case it is an include class of another_module).
* a_class.nth_superclass(n) Access nth order superclass of a_class invoking .superclass n times (ignores singleton classes and instead of showing include classes it shows the modules included).
* a_class.nth_zuperclass(n) Access nth order superclass of a_class invoking .zuperclass n times (doesn't ignore singleton or include classes).
* a_class.attached_object Get the attached object of a_class (raise an error if a_class is not a singleton class). 
* a_class.attached_id a_class.attached_object.object_id.
* a_class.is_singleton Return true if a_class is a singleton_class, otherwise false.
* IClassAnalizer.is_iclass(a_class) Return true if a_class is an include class.
* IClassAnalizer.klass(an_inclass) Get the actual class of an_iclass (it should return the module included by an_iclass). 
* IClassAnalizer.zuperclass(an_iclass) Get the actual superclass of an_iclass.
* IClassAnalizer.same_pointer(a_pointer, another_pointer) Return true if a_pointar == another_pointer.
* 
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
irb(main):008:0> String.klass
=> #<Class:String>
```
The real superclass of String (goes up in the ancestors chain until it finds a normal class (not singleton, not include))
```ruby
irb(main):009:0> String.superclass
=> Object
```
String includes Comparable, so String's superclass is actually an include class of Comparable
```ruby
irb(main):010:0> String.zuperclass
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
irb(main):012:0> IClassAnalizer.is_iclass(String.zuperclass)
=> true
```
The class of an include class is the module which it includes
```ruby
irb(main):013:0> IClassAnalizer.klass(String.zuperclass)
=> Comparable
```
From now on I will refer to metaclass as singleton class of class(an instance of Class). Metaclass is an special type of singleton class. 
The class of the class of String (aka the metametaclass of String, aka the class of the metaclass of String)
```ruby
irb(main):017:0> String.nth_klass(2)
=> #<Class:#<Class:String>>
```
The class of the class of the class of String (aka the metametametaclass of String). Here is something interesting: every class has a metaclass, so in theory there are infinit metaclasses of each class. Ruby tackles this with lazy creation of metaclasses, but because we aren't triggering this creation using Ruby's methods << or singleton_class, we can see that the class of the last "created" metaclass of a class is the metaclass of Class of the same order (check comment in class.c line 321). In this case, the class of the metametametaclass of String is the metametametaclass of Class
```ruby
irb(main):018:0> String.nth_klass(3)
=> #<Class:#<Class:Class>>
irb(main):019:0> String.nth_klass(4)
```
Finally, the class of the last "created" meta^nclass of Class is itself 
```ruby
=> #<Class:#<Class:#<Class:Class>>>
irb(main):020:0> String.nth_klass(5)
=> #<Class:#<Class:#<Class:Class>>>
irb(main):021:0> String.nth_klass(20)
=> #<Class:#<Class:#<Class:Class>>>
irb(main):022:0> String.nth_klass(5).object_id
=> 19801524
irb(main):023:0> String.nth_klass(20).object_id
=> 19801524
```
Lets see what happens when we actually create the meta^nclasses of String until n = 10 by calling String.singleton_class.singleton_class.singleton_class.etc
```ruby
irb(main):024:0> String.nth_class(10)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:String>>>>>>>>>>
irb(main):025:0> String.nth_klass(10)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:String>>>>>>>>>>
```
To ensure class hierarchy integrity, Ruby creates the metaclass of a class when the class is created. This also applies to metaclasses, so by creating the meta^10class we force the creation of the meta^11class (we also force the creation of the meta^nclasses for the superclasses)
```ruby
irb(main):026:0> String.nth_klass(11)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:String>>>>>>>>>>>
```
But, as we expected, the meta^11class of String was created with its class pointing to the meta^11class of Class 
```ruby
irb(main):027:0> String.nth_klass(12)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>>
```
And the meta^11class of Class keeps being self referential
```ruby
irb(main):028:0> String.nth_klass(13)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>>
irb(main):079:0> Class.nth_klass(500)
=> #<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:#<Class:Class>>>>>>>>>>>
```
Finally, lets check one more thing. When we created the meta^10 class of String, we force the creation of the meta^11class of String and the metaclasses of Class up to 11 (and the ones of Class' ancestors Module, Object, etc). So, the meta^11class of Class should have the meta^10class of Class as the attached_object. And because the meta^500class of Class is the meta^11class of Class (unless we create the 490 metaclasses between them), the meta^500class of Class should also have the meta^10class of Class as the attached_object  
```ruby
irb(main):082:0> Class.nth_klass(10) == Class.nth_klass(11).attached_object
=> true
irb(main):083:0> Class.nth_klass(10) == Class.nth_klass(500).attached_object
=> true
```

Requirements
------------
gem "RubyInline", "~> 3.12.0"

Credits
-------

Pablo Bianciotto.

License
-------

Copyright (c) 2013 Pablo Bianciotto.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
