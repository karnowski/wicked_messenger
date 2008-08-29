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
    
    def add(*arguments)
      @errors << error_from_arguments(arguments)
    end
    
    def has_error(*arguments)
      error = error_from_arguments(arguments)
      @errors.include?(error)
    end
    
    def replace(*arguments)
      options = arguments[-1].is_a?(Hash) ? arguments.slice!(-1) : {}
      new_message = options[:with] || return
      error_rule = error_from_arguments(arguments)
      
      matching_errors = @errors.select {|e| e == error_rule }
      matching_errors.each {|e| e.overridden_message = new_message }
    end
    
    def trump(*arguments)
      options = arguments[-1].is_a?(Hash) ? arguments.slice!(-1) : {}
      inferior_errors = options[:over] || return
      inferior_errors = [inferior_errors] unless inferior_errors.is_a?(Array)
      
      superior_error = error_from_arguments(arguments)
      inferior_errors.each do |inferior_error|
        suppress inferior_error if has_error(superior_error)
      end
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