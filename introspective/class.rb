class Class
  include Common::Zuperclass

  inline do |builder|
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

  def nth_superclass(index)
    a = self
    index.times {a = a.superclass}
    a
  end

  def nth_zuperclass(index)
    a = self
    index.times {a = a.zuperclass}
    a
  end
end