require "./spec_helper"

describe "Mechanize AuthChallenge test" do
  it "test_realm_basic" do
    uri = URI.parse "http://example.com/"
    challenge = Mechanize::HTTP::AuthChallenge.new "Digest", {"realm" => "r"}, "Digest realm=r"
    challenge.scheme = "Basic"

    expected = Mechanize::HTTP::AuthRealm.new "Basic", uri, "r"
    uri_path = URI.parse("http://example.com/foo")

    challenge.realm(uri_path).should eq expected
  end

  it "test_realm_digest" do
    uri = URI.parse "http://example.com/"
    challenge = Mechanize::HTTP::AuthChallenge.new "Digest", {"realm" => "r"}, "Digest realm=r"

    expected = Mechanize::HTTP::AuthRealm.new "Digest", uri, "r"
    uri_path = URI.parse("http://example.com/foo")

    challenge.realm(uri_path).should eq expected
  end

  it "test_realm_digest_case" do
    uri = URI.parse "http://example.com/"
    challenge = Mechanize::HTTP::AuthChallenge.new "Digest", {"realm" => "R"}, "Digest realm=R"

    expected = Mechanize::HTTP::AuthRealm.new "Digest", uri, "R"
    uri_path = URI.parse("http://example.com/foo")

    challenge.realm(uri_path).should eq expected
  end

  it "test_realm_unknown" do
    challenge = Mechanize::HTTP::AuthChallenge.new "Digest", {"realm" => "R"}, "Digest realm=R"
    challenge.scheme = "Unknown"

    uri_path = URI.parse("http://example.com/foo")
    expect_raises(Exception, "unknown HTTP authentication scheme #{challenge.scheme}") do
      challenge.realm(uri_path)
    end
  end

  it "test_realm_name" do
    uri = URI.parse "http://example.com/"
    challenge = Mechanize::HTTP::AuthChallenge.new "Digest", {"realm" => "r"}, "Digest realm=r"
    challenge.realm_name.should eq "r"
  end

  it "test_realm_name_case" do
    uri = URI.parse "http://example.com/"
    challenge = Mechanize::HTTP::AuthChallenge.new "Digest", {"realm" => "R"}, "Digest realm=R"
    challenge.realm_name.should eq "R"
  end

  it "test_realm_name_ntlm" do
    challenge = Mechanize::HTTP::AuthChallenge.new "Negotiate, NTLM"
    challenge.realm_name.should eq nil
  end
end
