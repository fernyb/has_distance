require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "has_distance" do
  it 'returns store' do
   Store.all.size.should > 0
  end
end
