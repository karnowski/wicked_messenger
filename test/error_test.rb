require 'test_helper'

describe "Error#humanize" do
  it "creates a human-readable error message by titleizing the field and appending the message (default Rails behavior)" do
    Error.new(:instance_variable, :field, "is invalid").humanize.should == "Field is invalid"
  end
  
  it "drops the field name if the field is 'base' or :base" do
    Error.new(:instance_variable, :base,  "A stand-alone message").humanize.should == "A stand-alone message"
    Error.new(:instance_variable, "base", "A stand-alone message").humanize.should == "A stand-alone message"    
  end
end

describe "Error equality" do
  it "two Error objects with the same instance variables are considered equal" do
    Error.new(:object, :field, "message").should == Error.new(:object, :field, "message")
  end
  
  it "two Error objects with any different in their instance variables are considered unequal" do
    Error.new(:object, :field, "message").should.not == Error.new(:different_object, :field, "message")
    Error.new(:object, :field, "message").should.not == Error.new(:object, :different_field, "message")
    Error.new(:object, :field, "message").should.not == Error.new(:object, :field, "different message")
  end
end
