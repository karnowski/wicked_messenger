require 'test_helper'

describe "Sifter" do
  it "tracks a list of errors" do
    Sifter.new(:some_errors).errors.should == :some_errors
  end

  it "has a convenience method method, error, to create instances of the Error object" do
    error = Error.new(:variable, :field, "is invalid")
    Sifter.new.error(:variable, :field, "is invalid").should == error
  end
end

describe "Sifter#suppress" do
  it "suppresses any errors that match the given instance variable, field, and string message" do
    error1 = Error.new(:variable_1, :field_1, "is invalid")
    error2 = Error.new(:variable_1, :field_2, "is really bad, way bad")
    sifter = Sifter.new([error1, error1, error2])
    sifter.suppress :variable_1, :field_1, "is invalid"
    sifter.errors.should == [error2]
  end

  it "suppresses any errors that match the given Error object" do
    error1 = Error.new(:variable_1, :field_1, "is invalid")
    error2 = Error.new(:variable_1, :field_2, "is really bad, way bad")
    sifter = Sifter.new([error1, error1, error2])
    sifter.suppress(error1)
    sifter.errors.should == [error2]
  end
end

describe "Sifter#add" do
  it "appends a new error to the list" do
    error1 = Error.new(:variable_1, :field_1, "is invalid")
    error2 = Error.new(:variable_1, :field_2, "is really bad, way bad")
    sifter = Sifter.new([error1])
    sifter.add(error2)
    sifter.errors.should == [error1, error2]
  end
  
  it "appends a new error to the list wrappering the given object, field, and message" do
    error1 = Error.new(:variable_1, :field_1, "is invalid")
    error2 = Error.new(:variable_1, :field_2, "is really bad, way bad")
    sifter = Sifter.new([error1])
    sifter.add(:variable_1, :field_2, "is really bad, way bad")
    sifter.errors.should == [error1, error2]
  end
end

describe "Sifter#has_error" do
  #TODO: what about suppressed messages?
  it "has_error returns true if the given error object is present" do
    error = Error.new(:variable, :field, "is invalid")
    Sifter.new([error]).has_error(error).should == true  
  end
  
  it "has_error returns true if an error with the given object, field, and message is present" do  
    error = Error.new(:variable, :field, "is invalid")
    Sifter.new([error]).has_error(:variable, :field, "is invalid").should == true
  end
  
  it "has_error returns false if an error with the given object, field, and message is NOT present" do
    Sifter.new([]).has_error(:variable, :field, "is invalid").should == false
  end
end

describe "Sifter#replace" do
  it "does not alter any messages of errors that do not match the given object, field, and message" do
    sifter = Sifter.new([Error.new(:variable, :field, "old message 1"), Error.new(:variable, :field, "old message 2")])
    sifter.replace(:variable, :field, "non-matching message", :with => "new message")
    sifter.errors.select {|e| e.overridden_message == "new message"}.should.be.empty
  end
  
  it "does not alter any messages of errors that do not match the given error" do
    sifter = Sifter.new([Error.new(:variable, :field, "old message 1"), Error.new(:variable, :field, "old message 2")])
    sifter.replace(Error.new(:variable, :field, "non-matching message"), :with => "new message")
    sifter.errors.select {|e| e.overridden_message == "new message"}.should.be.empty
  end
  
  it "overrides the message of any errors that match the given object, field, and message" do
    sifter = Sifter.new([Error.new(:variable, :field, "old message 1"), Error.new(:variable, :field, "old message 2")])
    sifter.replace(:variable, :field, "old message 1", :with => "new message")
    sifter.errors[0].overridden_message.should == "new message"
    sifter.errors[1].overridden_message.should.be.nil
  end
  
  it "overrides the message of any errors that match the given error" do
    sifter = Sifter.new([Error.new(:variable, :field, "old message 1"), Error.new(:variable, :field, "old message 2")])
    sifter.replace(Error.new(:variable, :field, "old message 1"), :with => "new message")
    sifter.errors[0].overridden_message.should == "new message"
    sifter.errors[1].overridden_message.should.be.nil
  end
  
  #TODO what do we do if :with is not specified?
  it "just return with no changes if an override message is not specified" do
    error = Error.new(:variable, :field, "some message")
    error.expects(:overridden_message=).never
    Sifter.new([error]).replace(error, {})
  end
end
