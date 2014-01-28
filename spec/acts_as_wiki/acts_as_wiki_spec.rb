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
    let(:markable_model) { MarkableModel.new }
	
		before(:each) do 
			clean_database!
		end
		
		it "should have a nil markupable column" do
			markable_model.wiki_markup.should == nil
		end

    context "#create_markup!" do
      context "when creating markable" do
        context "when column value is present" do
          it "should create an associated markup record" do
            markable_model.text = "ABC"
            markable_model.save!
            markable_model.has_markup?.should == true
          end

          it "should cache wiki-ized html on the markable" do
            markable_model.text = "abcd"
            markable_model.save!
            markable_model.reload
            expect(markable_model.text).to eq "<p>abcd</p>" #/
          end
        end

        context "when column value is missing" do
          it "should not have a markupable record" do
            markable_model.save!
            markable_model.has_markup?.should == false
          end
        end
      end

      context "associations" do
        let(:attrs) { {
          "text" => "abc",
          "associated_markables_attributes" => [
             { "text" => "bcd" },
             { "text" => "efg" }
          ]
        } }

        it "should markup associations" do
          markable = MarkableModel.new(attrs)
          markable.save!
          markable.reload
        end
      end
    end

    context "when updating markup via nested attributes" do
      it "caches the marked up value in the markable record" do
        markable_model.text = "ABC"
        markable_model.save!
        markable_model.has_markup?.should == true
        id = markable_model.wiki_markups.first.id
        attrs = { "wiki_markups_attributes" => { "0" => { "id" => id, "markup"=>"abcd", "column"=>"text" } } }
        markable_model.update_attributes!(attrs)
        wiki_markup = markable_model.wiki_markups.first
        wiki_markup.markup.should == "abcd"
        markable_model.reload
        markable_model.text.should == "<p>abcd</p>" #/
      end
    end

    context "#dissallow_markup!" do
      it "should clear out the markable record" do
        markable_model.text = "ABC"
        markable_model.save!
        markable_model.has_markup?.should == true
        markable_model.dissallow_markup!
        markable_model.has_markup?.should == false
        ActsAsWiki::WikiMarkup.count.should == 0
      end
    end
  end

  describe "WikiMarkup methods with alternate column" do
    let(:markable_model) { OtherMarkableModel.new }

    before(:each) do 
      clean_database!
    end
    
    it "should have a nil markupable column" do
      markable_model.wiki_markup.should == nil
    end
    
    it "should now have a markupable record" do
      markable_model.other_column_text = "ABC"
      markable_model.save!
      markable_model.reload
      wiki_markup = ActsAsWiki::WikiMarkup.find_by_column_and_markup("other_column_text","ABC")
      markable_model.wiki_markups.should include(wiki_markup)
      markable_model.has_markup?.should == true
    end
    
    it "should clear out the markable record" do 
      markable_model.other_column_text = "ABC"
      markable_model.save!
      markable_model.has_markup?.should == true
      markable_model.dissallow_markup!
      markable_model.has_markup?.should == false
    end
  end
	
  describe "Null markup" do
    let(:markable_model) { MarkableModel.new }

    before(:each) do
      clean_database!
    end

    it "should not allow markup when column value is nil" do
      MarkableModel.wiki_columns.should == ["text"]
      markable_model.text = nil
      markable_model.save!
      markable_model.should_not have_markup
    end

    it "should allow markup when column value is not nil" do
      markable_model.text = "abc"
      markable_model.save!
      markable_model.should have_markup
    end
  end

  describe "WikiMarkup html testing" do
    let(:markable_model) { MarkableModel.new }
    let(:test_string) { "<html><body>Test</body></html>" } 
    let(:test_wiki) { 
%Q{h1. Give RedCloth a try!

A *simple* paragraph with
a line break, some _emphasis_ and a "link":http://redcloth.org

* an item
* and another

# one
# two}
   }

   # Note: contains tabs. Don't replace them!
   let(:result_html) {
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
    }

    before(:each) do
      clean_database!
    end

    it "should accept html and return html" do
      markable_model.text = test_string
      markable_model.save!
      markable_model.text.should eql(test_string)
    end
		
    it "should put the html into the markup when we allow_markup" do
      markable_model.text = test_string
      markable_model.save!
      markable_model.wiki_markup.markup.should eql(test_string)
    end
		
    it "should accept html in markup and return html" do
      markable_model.text = test_string
      markable_model.save!
      markable_model.text.should eql(test_string)
    end
		
    it "should accept wiki and create html" do
      markable_model.text = test_wiki
      markable_model.save!
      markable_model.text.should eql(result_html)	
    end
		
  end

  context "#clone_markups" do
    context "when markable_exists" do
      let(:markable) { MarkableModel.new(:text => "abc") }
      let(:wiki_markup) { markable.wiki_markups.first }

      before do
        markable.save!
      end

      it "creates a new markup record for the cloned markable" do
        expect(wiki_markup.markup).to eq "abc"
        cloned_markable = markable.dup
        cloned_markable.save!
        markable.clone_markups(cloned_markable)
        expect(cloned_markable.wiki_markups.count).to eq 1
        cloned_markable.reload
        expect(cloned_markable.wiki_markups.first.markup).to eq "abc"
        expect(cloned_markable.text).to eq "<p>abc</p>"
        expect(ActsAsWiki::WikiMarkup.count).to eq 2
      end
    end
  end #/
  

end
