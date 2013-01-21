#al parecer una instancia include class no responde a ningun metodo
#asi que tengo que pasarla como parámetro en metodos de otra clase
class IClassAnalizer
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
      VALUE get_klass(VALUE iklass) {
        return RBASIC(iklass)->klass;
      }
    }
  end
end