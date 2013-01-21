module MethodLocator
  #monkeypath of method_locator gem to avoid forcing creation of singleton class
  private
  def fetch_singleton_class
    if self == self.klass.attached_object
      self.singleton_class
    else
      nil
    end
  end
end