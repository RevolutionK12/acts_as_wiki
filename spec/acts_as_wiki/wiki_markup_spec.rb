require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActsAsWiki::WikiMarkup do
  let(:wiki_markup) { subject.tap {|wm| wm.column = "text" } }

  it "should markup text" do
    wiki_markup.markup = "abc"
    expect(wiki_markup.text).to eq "<p>abc</p>" #/
  end

  context "when saving" do
    let(:markable) { MarkableModel.create(:text => "abc") }

    it "caches wiki-ized html on the markable" do
      wiki_markup.markable = markable
      wiki_markup.markup = "bcd"
      wiki_markup.save!
      markable.reload
      expect(markable.text).to eq "<p>bcd</p>" #/
    end
  end
end


