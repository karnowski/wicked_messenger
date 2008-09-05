require 'test_helper'

describe "finding errors from instance variables" do
  it "returns a list of errors that are on the named instance variables in the argument list" do
    errors_1 = [["field_1", "is invalid"], ["field_2", "is really bad, way bad"]]
    errors_2 = [
      ["base", ["completely wrong, dude.", "I said completely wrong.  Totally."]],
      ["raisin", "was gotten above of"],
    ]
    
    @instance_variable_1 = stub(:errors => errors_1)
    @instance_variable_2 = stub(:errors => errors_2)
    
    WickedMessenger.errors_for(self, :instance_variable_1, "instance_variable_2").should == [
      Error.new(:instance_variable_1, :field_1, "is invalid"),
      Error.new(:instance_variable_1, :field_2, "is really bad, way bad"),
      Error.new(:instance_variable_2, :base, "completely wrong, dude."),
      Error.new(:instance_variable_2, :base, "I said completely wrong.  Totally."),
      Error.new(:instance_variable_2, :raisin, "was gotten above of"),
    ]
  end
  
  it "handles the case where the instance variables have no errors" do
    @instance_variable_1 = stub(:errors => [])
    @instance_variable_2 = stub(:errors => [])
    
    WickedMessenger.errors_for(:instance_variable_1, "instance_variable_2").should == []
  end
  
  it "handles the case where the instance variables named do not exists" do
    WickedMessenger.errors_for(:instance_variable_1, "instance_variable_2").should == []
  end
end
