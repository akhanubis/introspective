class Object
  inline do |builder|
    #devuelve la verdadera clase de self (sin ignorar singleton o include classes)
    builder.c %{
      VALUE get_klass() {
        return RBASIC(self)->klass;
      }
    }
  end

  inline do |builder|
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