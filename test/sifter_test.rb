require 'test_helper'

describe "Sifter" do
  it "tracks a list of errors" do
    Sifter.new(:some_errors).errors.should == :some_errors
  end

  it "has a convenience method method, error, to create instances of the Error object" do
    error = Error.new(:instance_variable, :field, "is invalid")
    Sifter.new.error(:instance_variable, :field, "is invalid").should == error
  end
end

describe "Sifter#suppress" do
  it "suppresses any errors that match the given instance variable, field, and string message" do
    error1 = Error.new(:instance_variable_1, :field_1, "is invalid")
    error2 = Error.new(:instance_variable_1, :field_2, "is really bad, way bad")
    sifter = Sifter.new([error1, error1, error2])
    sifter.suppress :instance_variable_1, :field_1, "is invalid"
    sifter.errors.should == [error2]
  end

  it "suppresses any errors that match the given Error object" do
    error1 = Error.new(:instance_variable_1, :field_1, "is invalid")
    error2 = Error.new(:instance_variable_1, :field_2, "is really bad, way bad")
    sifter = Sifter.new([error1, error1, error2])
    sifter.suppress(error1)
    sifter.errors.should == [error2]
  end
end  

describe "Sifter#has_error" do
  #TODO: what about suppressed messages?
  it "has_error returns true if the given error object is present" do
    error = Error.new(:instance_variable, :field, "is invalid")
    Sifter.new([error]).has_error(error).should == true  
  end
  
  it "has_error returns true if an error with the given object, field, and message is present" do  
    error = Error.new(:instance_variable, :field, "is invalid")
    Sifter.new([error]).has_error(:instance_variable, :field, "is invalid").should == true
  end
  
  it "has_error returns false if an error with the given object, field, and message is NOT present" do
    Sifter.new([]).has_error(:instance_variable, :field, "is invalid").should == false
  end
end
