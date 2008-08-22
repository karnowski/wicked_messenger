module ErrorMessageSifter
  class Sifter
    attr_reader :errors
    
    def initialize(errors=[])
      @errors = errors
    end
    
    def error(object, field, message)
      Error.new(object, field, message)
    end
    
    def suppress(*arguments)
      error = error_from_arguments(arguments)
      @errors.delete(error)
    end
    
    def has_error(*arguments)
      error = error_from_arguments(arguments)
      @errors.include?(error)
    end
    
    private
    
    def error_from_arguments(arguments)
      return nil if arguments == nil
      return arguments[0] if arguments[0].is_a?(Error)
      raise "wrong number of arguments (requires object, field, and message)" unless arguments.length == 3
      Error.new(arguments[0], arguments[1], arguments[2])
    end
  end
end