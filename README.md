introspective
=============

A set of Ruby methods coded in C for getting access to structs and vars used by Ruby's inner core.

Implemented so far
------------
* Access nth order singleton classes and metaclasses bypassing the Ruby method singleton_class and thus breaking integrity.
* Access include classes (ICLASS).
* Access the attached object of a singleton class.
* Check if a class is a singleton class.
* Check if a class is a include class.

Requirements
------------
gem "RubyInline", "~> 3.12.0"
