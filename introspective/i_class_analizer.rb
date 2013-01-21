#al parecer una instancia include class no responde a ningun método
#así que tengo que pasarla como parámetro en métodos de otra clase para poder trabajarla
module IClassAnalizer
  inline do |builder|
    #true si klass es una include class, false en cualquier otro caso
    builder.c_singleton %{
      VALUE is_iclass(VALUE klass) {
        if (BUILTIN_TYPE(klass) == T_ICLASS) return Qtrue;
        else return Qfalse;
      }
    }
  end

  inline do |builder|
    #devuelve la verdadera clase de self (sin ignorar singleton o include classes)
    builder.c_singleton %{
      VALUE klass(VALUE iklass) {
        return RBASIC(iklass)->klass;
      }
    }
  end

  inline do |builder|
    #devuelve la verdadera superclase de self (sin ignorar singleton o include classes)
    builder.c_singleton %{
			VALUE zuperclass(VALUE iklass) {
        return RCLASS_SUPER(iklass);
      }
		}
  end

  inline do |builder|
    #devuelve true si ambos parámetros representados por punteros apuntan al mismo espacio de memoria
    builder.c_singleton %{
      VALUE same_pointer(VALUE a, VALUE b) {
        if (a == b) return Qtrue;
				else return Qfalse;
      }
    }
  end
end