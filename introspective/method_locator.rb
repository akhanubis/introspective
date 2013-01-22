module MethodLocator
  #monkeypath of method_locator gem to avoid forcing creation of singleton class
  private
  def fetch_singleton_class
    #dont fetch the singleton class unless it has already been created
    if self.klass.is_singleton && self == self.klass.attached_object
      self.singleton_class
    else
      nil
    end
  end
end