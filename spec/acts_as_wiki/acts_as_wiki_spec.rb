require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "ActsAsWiki" do
  
	before(:each) do 
		clean_database!
	end
	
	describe "WikiMarkup methods" do
	
		before(:each) do 
			clean_database!
			@markable_model = MarkableModel.new
		end
		
		it "should have a nil markupable column" do
			@markable_model.wiki_markup.should == nil
		end
		
		it "should now have a markupable record" do
			@markable_model.allow_markup!.should_not == nil
			@markable_model.has_markup?.should == true
		end
		
		it "should clear out the markable record" do 
			@markable_model.allow_markup!.should_not == nil
			@markable_model.has_markup?.should == true
			@markable_model.dissallow_markup!
			@markable_model.has_markup?.should == false
		end
	
	end
	
	describe "WikiMarkup methods with alternate column" do
		before(:each) do 
			clean_database!
			@markable_model = OtherMarkableModel.new
		end
		
		it "should have a nil markupable column" do
			@markable_model.wiki_markup.should == nil
		end
		
		it "should now have a markupable record" do
			@markable_model.allow_markup!.should_not == nil
			@markable_model.allow_markup!.should eql(@markable_model.wiki_markup)
			@markable_model.has_markup?.should == true
		end
		
		it "should clear out the markapble record" do 
			@markable_model.allow_markup!.should_not == nil
			@markable_model.has_markup?.should == true
			@markable_model.dissallow_markup!
			@markable_model.has_markup?.should == false
		end
	end
	
	describe "WikiMarkup html testing" do
		before(:each) do
			clean_database!
			@markable_model = MarkableModel.new
			@test_string = "<html><body>Test</body></html>"
			@test_wiki = 
%Q{h1. Give RedCloth a try!

A *simple* paragraph with
a line break, some _emphasis_ and a "link":http://redcloth.org

* an item
* and another

# one
# two}
			@result_html = 
%Q{<h1>Give RedCloth a try!</h1>
<p>A <strong>simple</strong> paragraph with<br />
a line break, some <em>emphasis</em> and a <a href="http://redcloth.org">link</a></p>
<ul>
	<li>an item</li>
	<li>and another</li>
</ul>
<ol>
	<li>one</li>
	<li>two</li>
</ol>}
		end
		
		it "should accept html and return html" do
			@markable_model.text = @test_string
			@markable_model.save
			@markable_model.text.should eql(@test_string)
		end
		
		it "should put the html into the markup when we allow_markup" do
			@markable_model.text = @test_string
			@markable_model.save
			@markable_model.allow_markup!
			@markable_model.wiki_markup.markup.should eql(@test_string)
		end
		
		it "should accept html in markup and return html" do
			@markable_model.allow_markup!.markup = @test_string
			@markable_model.save
			@markable_model.text.should eql(@test_string)
		end
		
		it "should accept wiki and create html" do
			@markable_model.allow_markup!.markup = @test_wiki
			@markable_model.save
			@markable_model.text.should eql(@result_html)	
		end
		
	end

end