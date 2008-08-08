module ErrorMessageSifter
  def error_messages_for_with_humanized_error_messages(*args, &block)
    #TODO: why does safe_erb bitch unless I untaint this?  it works fine everywhere else?
    return error_messages_for_without_humanized_error_messages(*args).untaint if block.nil?
    
  end
  
  def self.included(base)
    base.class_eval { alias_method_chain :error_messages_for, :humanized_error_messages }
  end
end


