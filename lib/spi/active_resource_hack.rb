
# hack the active resource base
ActiveResource::Base.class_eval do
  self.include_root_in_json = false

  # because of the schedule rule has an element trigger with attribute named as "select"
  # it will be converted as an instance of ActiveResource::Base
  # and will conflict with ActiveResource::Base's select method
  def select_with_serialization(*args)
    if( args.empty? )
      attributes["select"]
    else
      super
    end
  end
  alias_method_chain :select, :serialization
end

