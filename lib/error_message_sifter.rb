module ErrorMessageSifter
  class Error
    attr_reader :object, :field, :message
    
    def initialize(object, field, message)
      @object = object
      @field = field
      @message = message
    end
    
    def ==(other)
      self.object == other.object && self.field == other.field && self.message == other.message
    end
  end
  
  #TODO move this into a Rails-specific module
  def error_messages_for_with_humanized_error_messages(*args, &block)
    #TODO: why does safe_erb bitch unless I untaint this?  it works fine everywhere else?
    return error_messages_for_without_humanized_error_messages(*args).untaint if block.nil?
    
    #get a list of errors from these objects
    errors = errors_for(*args)
    #run the block over the list of errors (if any)
    #send the list of errors to an output string
    #return the output string
  end
  
  #TODO move this into a core module, not Rails-specific
  def errors_for(*args)
    objects = args.collect {|object_name| [object_name, instance_variable_get("@#{object_name}")] }
    errors = []
    objects.each do |name, object|
      unless object.nil?
        object.errors.each do |field, message|
          if message.respond_to?(:each)
            message.each {|single_message| errors << Error.new(name.to_sym, field.to_sym, single_message)}
          else
            errors << Error.new(name.to_sym, field.to_sym, message)
          end
        end
      end
    end
    errors
  end
  
  def self.included(base)
    base.class_eval { alias_method_chain :error_messages_for, :humanized_error_messages }
  end
end


