require "./spec_helper"

describe "Mechanize AuthRealm test" do
  it "test_initialize" do
    uri = URI.parse("http://example.com")
    realm = Mechanize::HTTP::AuthRealm.new "Digest", uri, "r"
    realm.realm.should eq "r"

    realm = Mechanize::HTTP::AuthRealm.new "Digest", uri, "R"
    realm.realm.should_not eq "r"
    realm.realm.should eq "R"

    realm = Mechanize::HTTP::AuthRealm.new "Digest", uri, nil
    realm.realm.should eq nil
  end

  it "test_equals2" do
    uri = URI.parse("http://example.com")
    realm = Mechanize::HTTP::AuthRealm.new "Digest", uri, "r"
    other = realm.dup
    realm.should eq other

    other = Mechanize::HTTP::AuthRealm.new "Basic", uri, "r"
    realm.should_not eq other

    other = Mechanize::HTTP::AuthRealm.new "Digest", URI.parse("http://other.example/"), "r"
    realm.should_not eq other

    other = Mechanize::HTTP::AuthRealm.new "Digest", uri, "R"
    realm.should_not eq other

    other = Mechanize::HTTP::AuthRealm.new "Digest", uri, "s"
    realm.should_not eq other
  end

  it "test_hash" do
    uri = URI.parse("http://example.com")
    realm = Mechanize::HTTP::AuthRealm.new "Digest", uri, "r"
    h = Hash(Mechanize::HTTP::AuthRealm, Int32).new(0)
    h[realm] = 1

    other = realm.dup
    h[other].should eq 1

    other = Mechanize::HTTP::AuthRealm.new "Basic", uri, "r"
    h[other].should eq 0
  end
end
