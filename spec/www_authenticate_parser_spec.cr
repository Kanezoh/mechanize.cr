require "./spec_helper"

describe "Mechanize HTTP Authentication test" do
  it "auth_param" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new("realm=here")
    parser.auth_param.should eq ["realm", "here"]
  end

  it "auth_param no value" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new("realm=")
    parser.auth_param.should eq nil
  end

  it "auth_param bad token" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new("realm")
    parser.auth_param.should eq nil
  end

  it "auth_param bad value" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new("realm=\"this ")
    parser.auth_param.should eq nil
  end

  it "auth_param with quote" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new("realm=\"this site\"")
    parser.auth_param.should eq ["realm", "this site"]
  end

  it "test parse" do
    expect = [Mechanize::HTTP::AuthChallenge.new("Basic", {"realm" => "foo", "qop" => "auth,auth-int"})]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm=foo, qop=\"auth,auth-int\"")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
  end

  it "test_parse_without_comma_delimiter" do
    expect = [challenge("Basic", {"realm" => "foo", "qop" => "auth,auth-int"})]
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm=foo qop=\"auth,auth-int\"")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
  end

  it "test_parse_multiple" do
    expect = [
      challenge("Basic", {"realm" => "foo"}),
      challenge("Digest", {"realm" => "bar"}),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm=foo, Digest realm=bar")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[1].scheme.should eq expect[1].scheme
    result[1].params.should eq expect[1].params
  end
end

private def challenge(scheme, params)
  Mechanize::HTTP::AuthChallenge.new(scheme, params)
end
