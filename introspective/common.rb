module Common
  module Zuperclass
    inline do |builder|
      #devuelve la verdadera superclase de self (sin ignorar singleton o include classes)
      builder.c %{
			  VALUE zuperclass() {
          return RCLASS_SUPER(self);
        }
		  }
    end
  end
end