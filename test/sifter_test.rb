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
  
  it "just return with no changes if an override message is not specified" do
    error = Error.new(:variable, :field, "some message")
    error.expects(:overridden_message=).never
    Sifter.new([error]).replace(error, {})
  end
end

describe "Sifter#trump" do
  it "leaves the inferior error in place if the superior (trump) error is not present" do
    inferior_error = Error.new(:variable, :field, "some bad message")
    superior_error = Error.new(:variable, :field, "a better message")
    
    sifter = Sifter.new([inferior_error])
    sifter.trump(superior_error, :over => inferior_error)
    sifter.errors.should == [inferior_error]
  end
  
  it "suppresses an inferior error if the superior (trump) error is present" do
    inferior_error = Error.new(:variable, :field, "some bad message")
    superior_error = Error.new(:variable, :field, "a better message")
    
    sifter = Sifter.new([inferior_error, superior_error])
    sifter.trump(superior_error, :over => inferior_error)
    sifter.errors.should == [superior_error]
  end

  it "suppresses an inferior error if the superior (trump) object, field, and message are present" do
    inferior_error = Error.new(:variable, :field, "some bad message")
    superior_error = Error.new(:variable, :field, "a better message")
    
    sifter = Sifter.new([inferior_error, superior_error])
    sifter.trump(:variable, :field, "a better message", :over => inferior_error)
    sifter.errors.should == [superior_error]
  end

  it "handles multiple inferior messages" do
    inferior_error1 = Error.new(:variable, :field, "some bad message1")
    inferior_error2 = Error.new(:variable, :field, "some bad message2")
    superior_error  = Error.new(:variable, :field, "a better message")
    
    sifter = Sifter.new([inferior_error1, inferior_error2, superior_error])
    sifter.trump(superior_error, :over => [inferior_error1, inferior_error2])
    sifter.errors.should == [superior_error]
  end
  
  it "just returns with no changes if the inferior error is not specified" do
    error = Error.new(:variable, :field, "message")
    sifter = Sifter.new([error])
    sifter.trump(error)
    sifter.errors.should == [error]
  end
end