module WickedMessenger
  class Error
    attr_reader :object, :field, :message
    attr_accessor :overridden_message
    
    def initialize(object, field, message)
      @object = object
      @field = field
      @message = message
    end
    
    def humanize
      return @overridden_message if @overridden_message
      
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