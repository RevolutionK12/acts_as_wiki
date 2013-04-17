require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "ActsAsWiki" do

	before(:each) do 
		clean_database!
	end

  describe "accessors" do
    it "should have a wiki_columns accessor" do
      MarkableModel.wiki_columns.should == ['text']
    end
    it "should be enabled by default" do
      MarkableModel.acts_as_wiki_disabled?.should be_false
    end
    it "should allow subclasses to disable" do
      MarkableModelSubClass.acts_as_wiki_disabled?.should be_true
    end
  end
	
	describe "WikiMarkup methods" do
	
		before(:each) do 
			clean_database!
			@markable_model = MarkableModel.new
		end
		
		it "should have a nil markupable column" do
			@markable_model.wiki_markup.should == nil
		end

    context "#allow_markup!" do
      context "when column value is present" do
        it "should have a markupable record" do
          @markable_model.text = "ABC"
          @markable_model.save!
          @markable_model.allow_markup!.should_not == nil
          @markable_model.has_markup?.should == true
        end
      end

      context "when column value is missing" do
        it "should not have a markupable record" do
          @markable_model.text = ""
          @markable_model.save!
          @markable_model.allow_markup!.should_not == nil
          @markable_model.has_markup?.should == false
        end
      end

      context "when removing a column's value" do
        it "should clear out the markable record" do
          @markable_model.text = "ABC"
          @markable_model.save! # Needs an ID when reloaded
          @markable_model.allow_markup!
          @markable_model.has_markup?.should == true
          @markable_model.text = ""
          @markable_model.cache_wiki_html
          @markable_model.has_markup?.should == false
        end
      end
    end

    context "#dissallow_markup!" do
      it "should clear out the markable record" do
        @markable_model.text = "ABC"
        @markable_model.save!
        @markable_model.allow_markup!.should_not == nil
        @markable_model.has_markup?.should == true
        @markable_model.dissallow_markup!
        @markable_model.has_markup?.should == false
      end
    end
	
	end

  describe "caching html" do
    before(:each) do
      clean_database!
      @markable_model = MarkableModel.new
    end

    context "when creating markup" do
      it "caches html in the markable" do
        @markable_model.text = "abc"
        @markable_model.save!
        @markable_model.allow_markup!
        @markable_model.text.should == "<p>abc</p>"
      end
    end
  end
	
	describe "WikiMarkup methods with alternate column" do
		before(:each) do 
			clean_database!
			@markable_model = OtherMarkableModel.new
      @markable_model.save!
		end
		
		it "should have a nil markupable column" do
			@markable_model.wiki_markup.should == nil
		end
		
		it "should now have a markupable record" do
      @markable_model.other_column_text = "ABC"
			@markable_model.allow_markup!.should_not == nil
			@markable_model.allow_markup!.should include(@markable_model.wiki_markup)
			@markable_model.has_markup?.should == true
		end
		
		it "should clear out the markable record" do 
      @markable_model.other_column_text = "ABC"
			@markable_model.allow_markup!.should_not == nil
			@markable_model.has_markup?.should == true
			@markable_model.dissallow_markup!
			@markable_model.has_markup?.should == false
		end
	end
	
  describe "Null markup" do
    before(:each) do
      clean_database!
      @markable_model = MarkableModel.new
    end

    it "should not allow markup when column value is nil" do
      MarkableModel.wiki_columns.should == ["text"]
      @markable_model.text = nil
      @markable_model.save!
      @markable_model.allow_markup!
      @markable_model.should_not have_markup
    end

    it "should allow markup when column value is not nil" do
      @markable_model.text = "abc"
      @markable_model.save!
      @markable_model.allow_markup!
      @markable_model.should have_markup
    end

    it "should change markup" do
      @markable_model.text = "abc"
      @markable_model.save!
      @markable_model.allow_markup!
      @markable_model.cache_wiki_html
      @markable_model.text.should == "<p>abc</p>"
      markup = @markable_model.wiki_markup("text")
      markup.markup = "abc_def"
      markup.save!
      @markable_model.cache_wiki_html
      @markable_model.text.should == "<p>abc_def</p>"
    end

    it "should remove markup when column's value is set to an empty string or nil" do
      @markable_model.text = "abc"
      @markable_model.save! # Needs ID for reloading
      @markable_model.allow_markup!
      @markable_model.should have_markup
      @markable_model.cache_wiki_html
      @markable_model.text.should == "<p>abc</p>"
      @markable_model.text = nil
      @markable_model.cache_wiki_html
      @markable_model.should_not have_markup

      @markable_model.text = "abc"
      @markable_model.cache_wiki_html
      @markable_model.should have_markup
      @markable_model.text = ""
      @markable_model.cache_wiki_html
      @markable_model.should_not have_markup
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
			@markable_model.save!
			@markable_model.text.should eql(@test_string)
		end
		
		it "should put the html into the markup when we allow_markup" do
			@markable_model.text = @test_string
			@markable_model.save!
      @markable_model.allow_markup!
			@markable_model.wiki_markup.markup.should eql(@test_string)
		end
		
		it "should accept html in markup and return html" do
			@markable_model.text = @test_string
			@markable_model.save!
      @markable_model.allow_markup!
			@markable_model.text.should eql(@test_string)
		end
		
		it "should accept wiki and create html" do
			@markable_model.text = @test_wiki
			@markable_model.save!
      @markable_model.allow_markup!
			@markable_model.text.should eql(@result_html)	
		end
		
	end

end
