require "active_support"
require "error_message_sifter/error"
require "error_message_sifter/sifter"

module ErrorMessageSifter
  def self.errors_for(model, *args)
    ivar_names_and_values = args.collect {|ivar_name| [ivar_name, model.instance_variable_get("@#{ivar_name}")] }
    errors = []
    ivar_names_and_values.each do |name, value|
      unless value.nil?
        value.errors.each do |field, message|
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
end
