require 'test_helper'
require 'error_message_sifter/action_view_extensions'

class Test::Unit::TestCase
  def self.alias_method_chain(*args)
    #just here to make including the ActionViewExtensions work
  end
  
  include ErrorMessageSifter::ActionViewExtensions
end

describe "overridden error_messages_for" do
  it "passes through to the standard ActionView error_messages_for if no block given" do
    self.expects(:error_messages_for_without_humanized_error_messages).with(:options)
    error_messages_for_with_humanized_error_messages(:options)
  end
  
  it "creates the output itself if a block is given" do
    self.expects(:error_messages_for_without_humanized_error_messages).never
    error_messages_for_with_humanized_error_messages(:options) {}
  end
  
  it "successfully outputs html for the given errors" do
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
    ], {:class => "some_css_class"}).returns(:html_output)
    
    output = error_messages_for_with_humanized_error_messages(:instance_variable_1, "instance_variable_2", {:class => "some_css_class"}) {}
    output.should == :html_output
  end
  
  it "evaluates the block of rules over the list of errors" do
    @instance_variable = stub(:errors => [["field_1", "is invalid"], ["field_2", "is really bad, way bad"]])
    self.expects(:error_messages_html).with([Error.new(:instance_variable, :field_2, "is really bad, way bad")], anything)
        
    output_errors = error_messages_for_with_humanized_error_messages(:instance_variable) do
      suppress :instance_variable, :field_1, "is invalid"
    end
  end
end

describe "outputing HTML for errors" do
  it "outputs the standard 'error_messages_for' html for the given errors" do
    html = <<HTML 
<div class="errorExplanation" id="errorExplanation">
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
    
    self.stubs(:pluralize).with(2, 'error').returns("2 errors")
    self.send(:error_messages_html, errors).should == html
  end
  
  it "returns an empty string if the errors list is empty or nil" do
    self.send(:error_messages_html, []).should == ""
    self.send(:error_messages_html, nil).should == ""
  end
  
  it "allows for the 'class' (CSS class name) HTML option" do
    errors = [Error.new(:instance_variable, :company, "is invalid")]
    self.stubs(:pluralize)
    html = self.send(:error_messages_html, errors, :class => "some css class")
    html.should.include('<div class="some css class" id="errorExplanation">')
  end
end

