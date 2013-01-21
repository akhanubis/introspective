class Object
  inline do |builder|
    #devuelve la verdadera clase de self (sin ignorar singleton o include classes)
    builder.c %{
      VALUE get_klass() {
        return RBASIC(self)->klass;
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