require 'minitest_helper'
require 'plugins/pre_commit/checks/gpg'

describe PreCommit::Checks::Gpg do
  let(:check){ PreCommit::Checks::Gpg.new(nil, nil, []) }

  it "succeeds if nothing changed" do
    check.call([]).must_equal nil
  end

  #~ it "succeeds if non-php file changed" do
  #~   check.call([fixture_file('bad-php.js')]).must_equal nil
  #~ end

  #~ it "succeeds if only good changes" do
  #~   check.call([fixture_file("good.php")]).must_equal nil
  #~ end

  #~ it "fails if script fails" do
  #~   check.call([fixture_file("bad.php")]).must_match(/Parse error/i)
  #~ end

end
