require 'rubygems'
require 'inline'

class Object
    inline do |builder|
        #devuelve la verdadera clase de self (sin ignorar singleton o include classes)   
		builder.c %{
            VALUE get_klass() {
                return RBASIC(self)->klass;
            }
        }
		#hack porque una include class no tiene clase?? ni siquiera responde a __send__
		#true si klass es una include class, false en cualquier otro caso
		builder.c %{
			VALUE is_include_class(VALUE klass) {
				if (BUILTIN_TYPE(klass) == T_ICLASS) return Qtrue;
				else return Qfalse;
			}
        }
    end
	
	def nclass(index)
		a = self
		index.times do
			a = a.singleton_class
		end
		a
	end
	
	def nklass(index)
		a = self
		index.times do
			a = a.get_klass
		end
		a
	end
end

class Class
    inline do |builder|
        #devuelve la verdadera superclase de self (sin ignorar singleton o include classes)   
		builder.c %{
			VALUE get_super() {
                return RCLASS_SUPER(self);
            }
		}
		#devuelve el objeto attacheado a self o un mensaje de error si self no es una singleton class
		builder.c %{
			VALUE attached_object() {
				if (!FL_TEST(self, FL_SINGLETON)) rb_raise(rb_eTypeError, "%s no es una clase singleton", rb_class2name(self));
				else return rb_ivar_get(self, rb_intern("__attached__"));
			}
		}
		#true si self es una singleton class, false en cualquier otro caso
		builder.c %{
			VALUE is_singleton() {
				if (FL_TEST(self, FL_SINGLETON)) return Qtrue;
				else return Qfalse;
			}
        }
	end
		
	def attached_id
		attached_object.object_id
	end
	
	def nsuper(index)
		a = self
		index.times do
			a = a.superclass
		end
		a
	end
	
	def nzuper(index)
		a = self
		index.times do
			a = a.get_super
		end
		a
	end
end