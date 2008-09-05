require "erb"

module WickedMessenger
  module ActionViewExtensions
    def error_messages_for_with_humanized_error_messages(*args, &block)
      #TODO: why does safe_erb bitch unless I untaint this?  it works fine everywhere else!
      return error_messages_for_without_humanized_error_messages(*args).untaint if block.nil?
    
      ivar_descriptors = args
      html_options = (ivar_descriptors.last.is_a?(Hash)) ? ivar_descriptors.slice!(-1) : {}
      
      #get a list of errors from these objects
      errors = WickedMessenger.errors_for(self, *ivar_descriptors)
      
      #run the block over the list of errors (if any)
      sifter = Sifter.new(errors)
      sifter.instance_eval(&block)
      
      #send the list of errors to an output string
      error_messages_html(errors, html_options)
    end
    
    private 
    
    def error_messages_html(errors, options={})
      html = ""
      
      unless errors.blank?
        css_class_name = options[:class] || "errorExplanation"
        
        html += %Q{<div class="#{css_class_name}" id="errorExplanation">\n}
        html += %Q{  <h2>#{pluralize(errors.length, 'error')} prohibited this from being saved</h2>\n}
        html += %Q{  <p>There were problems with the following fields:</p>\n}
        html += %Q{  <ul>\n}
      
        errors.each do |error|
          html += %Q{    <li>#{ERB::Util.h(error.humanize)}</li>\n}
        end
      
        html += %Q{  </ul>\n}
        html += %Q{</div>\n}
      end
      
      html
    end
    
    def self.included(base)
      base.class_eval { alias_method_chain :error_messages_for, :humanized_error_messages }
    end    
  end
end
