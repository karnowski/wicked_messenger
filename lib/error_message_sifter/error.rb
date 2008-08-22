module ErrorMessageSifter
  class Error
    attr_reader :object, :field, :message
    
    def initialize(object, field, message)
      @object = object
      @field = field
      @message = message
    end
    
    def humanize
      if field.to_s == "base"
        "#{message}"
      else        
        "#{field.to_s.titleize} #{message}"
      end
    end
    
    def ==(other)
      self.object == other.object && self.field == other.field && self.message == other.message
    end
  end
end