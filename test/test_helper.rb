gem "mocha", "0.5.6"

require "error_message_sifter"
require 'test/spec'
require 'mocha'

include ErrorMessageSifter

class Test::Unit::TestCase
  def self.alias_method_chain(*args)
    #just here to make including ErrorMessageSifter work
    #TODO: should I fix that somehow?
  end
  
  include ErrorMessageSifter::ActionViewExtensions
end