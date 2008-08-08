gem "mocha", "0.5.6"

require "error_message_sifter"
require 'test/spec'
require 'mocha'

describe "overridden error_messages_for" do
  def self.alias_method_chain(*args)
    #just here to make including ErrorMessageSifter work
    #TODO: should I fix that somehow?
  end
  
  include ErrorMessageSifter
  
  it "passes through to the standard ActionView error_messages_for if no block given" do
    self.expects(:error_messages_for_without_humanized_error_messages).with(:options)
    error_messages_for_with_humanized_error_messages(:options)
  end
  
  it "creates the output itself if a block is given" do
    self.expects(:error_messages_for_without_humanized_error_messages).never
    error_messages_for_with_humanized_error_messages(:options) {}
  end
end