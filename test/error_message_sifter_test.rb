require 'test_helper'
require 'set'

# TODO: make sure to refactor/kill/do-something-with the "training wheel" tests

describe "overridden error_messages_for" do
  it "passes through to the standard ActionView error_messages_for if no block given" do
    self.expects(:error_messages_for_without_humanized_error_messages).with(:options)
    error_messages_for_with_humanized_error_messages(:options)
  end
  
  it "creates the output itself if a block is given" do
    self.expects(:error_messages_for_without_humanized_error_messages).never
    error_messages_for_with_humanized_error_messages(:options) {}
  end
  
  it "successfully outputs html for the given errors (also temporarily ignores the last argument passed in, if it's a hash)" do
    errors_1 = [
      ["field_1", "is invalid"], 
      ["field_2", "is really bad, way bad"],
    ]
    errors_2 = [
      ["base", ["completely wrong, dude.", "I said completely wrong.  Totally."]],
      ["raisin", "is gotten above of"],
    ]
    
    @instance_variable_1 = stub(:errors => errors_1)
    @instance_variable_2 = stub(:errors => errors_2)
    
    self.expects(:error_messages_html).with([
      Error.new(:instance_variable_1, :field_1, "is invalid"),
      Error.new(:instance_variable_1, :field_2, "is really bad, way bad"),
      Error.new(:instance_variable_2, :base, "completely wrong, dude."),
      Error.new(:instance_variable_2, :base, "I said completely wrong.  Totally."),
      Error.new(:instance_variable_2, :raisin, "is gotten above of"),
    ]).returns(:html_output)
    
    output = error_messages_for_with_humanized_error_messages(:instance_variable_1, "instance_variable_2", {:class => "something"}) {}
    output.should == :html_output
  end
  
  it "evaluates the block of rules over the list of errors" do
    @instance_variable = stub(:errors => [["field_1", "is invalid"], ["field_2", "is really bad, way bad"]])
    self.expects(:error_messages_html).with([Error.new(:instance_variable, :field_2, "is really bad, way bad")])
        
    output_errors = error_messages_for_with_humanized_error_messages(:instance_variable, {:class => "something"}) do
      suppress :instance_variable, :field_1, "is invalid"
    end
  end
end

describe "outputing HTML for errors" do
  it "outputs the standard 'error_messages_for' html for the given errors" do
    html = <<HTML 
<div id="errorExplanation">
  <h2>2 errors prohibited this from being saved</h2>
  <p>There were problems with the following fields:</p>
  <ul>
    <li>Company is invalid</li>
    <li>Name can't be blank</li>
  </ul>
</div>
HTML

  errors = [
    Error.new(:instance_variable, :company, "is invalid"), 
    Error.new(:instance_variable, :name, "can't be blank"),
  ]
  
  self.send(:error_messages_html, errors).should == html
  end
end

describe "finding errors from instance variables" do
  it "returns a list of errors that are on the named instance variables in the argument list" do
    errors_1 = [["field_1", "is invalid"], ["field_2", "is really bad, way bad"]]
    errors_2 = [
      ["base", ["completely wrong, dude.", "I said completely wrong.  Totally."]],
      ["raisin", "is gotten above of"],
    ]
    
    @instance_variable_1 = stub(:errors => errors_1)
    @instance_variable_2 = stub(:errors => errors_2)
    
    ErrorMessageSifter.errors_for(self, :instance_variable_1, "instance_variable_2").should == [
      Error.new(:instance_variable_1, :field_1, "is invalid"),
      Error.new(:instance_variable_1, :field_2, "is really bad, way bad"),
      Error.new(:instance_variable_2, :base, "completely wrong, dude."),
      Error.new(:instance_variable_2, :base, "I said completely wrong.  Totally."),
      Error.new(:instance_variable_2, :raisin, "is gotten above of"),
    ]
  end
  
  it "handles the case where the instance variables have no errors" do
    @instance_variable_1 = stub(:errors => [])
    @instance_variable_2 = stub(:errors => [])
    
    ErrorMessageSifter.errors_for(:instance_variable_1, "instance_variable_2").should == []
  end
  
  it "handles the case where the instance variables named do not exists" do
    ErrorMessageSifter.errors_for(:instance_variable_1, "instance_variable_2").should == []
  end
end

describe "Sifter object" do
  it "tracks a list of errors" do
    Sifter.new(:some_errors).errors.should == :some_errors
  end

  it "suppresses any errors that match the given instance variable, field, and string message" do
    error1 = Error.new(:instance_variable_1, :field_1, "is invalid")
    error2 = Error.new(:instance_variable_1, :field_2, "is really bad, way bad")
    sifter = Sifter.new([error1, error1, error2])
    sifter.suppress :instance_variable_1, :field_1, "is invalid"
    sifter.errors.should == [error2]
  end
end

describe "Error object" do
  it "creates a human-readable error message by titleizing the field and appending the message (default Rails behavior)" do
    Error.new(:instance_variable, :field, "is invalid").humanize.should == "Field is invalid"
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
