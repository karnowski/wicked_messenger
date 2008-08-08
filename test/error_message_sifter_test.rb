require 'test_helper'
require 'set'

describe "overridden error_messages_for" do
  it "passes through to the standard ActionView error_messages_for if no block given" do
    self.expects(:error_messages_for_without_humanized_error_messages).with(:options)
    error_messages_for_with_humanized_error_messages(:options)
  end
  
  it "creates the output itself if a block is given" do
    self.expects(:error_messages_for_without_humanized_error_messages).never
    error_messages_for_with_humanized_error_messages(:options) {}
  end
end

describe "finding errors from instance variables" do
  it "training wheels" do
    errors_1 = [["field_1", "was invalid"], ["field_2", "was really bad, way bad"]]
    errors_2 = [
      ["base", ["completely wrong, dude.", "I said completely wrong.  Totally."]],
      ["raisin", "was gotten above of"],
    ]
    
    @instance_variable_1 = stub(:errors => errors_1)
    @instance_variable_2 = stub(:errors => errors_2)
    
    error_messages_for_with_humanized_error_messages(:instance_variable_1, "instance_variable_2") {}.should == [
      ErrorMessageSifter::Error.new(:instance_variable_1, :field_1, "was invalid"),
      ErrorMessageSifter::Error.new(:instance_variable_1, :field_2, "was really bad, way bad"),
      ErrorMessageSifter::Error.new(:instance_variable_2, :base, "completely wrong, dude."),
      ErrorMessageSifter::Error.new(:instance_variable_2, :base, "I said completely wrong.  Totally."),
      ErrorMessageSifter::Error.new(:instance_variable_2, :raisin, "was gotten above of"),
    ]
  end
  
  it "returns a list of errors that are on the named instance variables in the argument list" do
    errors_1 = [["field_1", "was invalid"], ["field_2", "was really bad, way bad"]]
    errors_2 = [
      ["base", ["completely wrong, dude.", "I said completely wrong.  Totally."]],
      ["raisin", "was gotten above of"],
    ]
    
    @instance_variable_1 = stub(:errors => errors_1)
    @instance_variable_2 = stub(:errors => errors_2)
    
    errors_for(:instance_variable_1, "instance_variable_2").should == [
      ErrorMessageSifter::Error.new(:instance_variable_1, :field_1, "was invalid"),
      ErrorMessageSifter::Error.new(:instance_variable_1, :field_2, "was really bad, way bad"),
      ErrorMessageSifter::Error.new(:instance_variable_2, :base, "completely wrong, dude."),
      ErrorMessageSifter::Error.new(:instance_variable_2, :base, "I said completely wrong.  Totally."),
      ErrorMessageSifter::Error.new(:instance_variable_2, :raisin, "was gotten above of"),
    ]
  end
end

describe "Error equality" do
  it "two Error objects with the same instance variables are considered equal" do
    ErrorMessageSifter::Error.new(:object, :field, "message").should == ErrorMessageSifter::Error.new(:object, :field, "message")
  end
  
  it "two Error objects with any different in their instance variables are considered unequal" do
    ErrorMessageSifter::Error.new(:object, :field, "message").should.not == ErrorMessageSifter::Error.new(:different_object, :field, "message")
    ErrorMessageSifter::Error.new(:object, :field, "message").should.not == ErrorMessageSifter::Error.new(:object, :different_field, "message")
    ErrorMessageSifter::Error.new(:object, :field, "message").should.not == ErrorMessageSifter::Error.new(:object, :field, "different message")
  end
end
