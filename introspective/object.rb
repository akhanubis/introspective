class Object
  inline do |builder|
    #devuelve la verdadera clase de self (sin ignorar singleton o include classes)
    builder.c %{
      VALUE klass() {
        return RBASIC(self)->klass;
      }
    }
  end

  def nth_class(index)
    a = self
    index.times {a = a.class}
    a
  end

  def nth_singleton_class(index)
    a = self
    index.times {a = a.singleton_class}
    a
  end

  def nth_klass(index)
    a = self
    index.times {a = a.klass}
    a
  end
end