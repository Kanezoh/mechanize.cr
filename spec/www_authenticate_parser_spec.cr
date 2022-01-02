require "./spec_helper"

describe "Mechanize HTTP Authentication test" do
  it "auth_param" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new("realm=here")
    parser.auth_param.should eq ["realm", "here"]
  end

  it "auth_param bad no value" do
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
    expect = [challenge("Basic", {"realm" => "foo", "qop" => "auth,auth-int"}, "Basic realm=foo, qop=\"auth,auth-int\"")]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm=foo, qop=\"auth,auth-int\"")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
  end

  it "test_parse_without_comma_delimiter" do
    expect = [challenge("Basic", {"realm" => "foo", "qop" => "auth,auth-int"}, "Basic realm=foo qop=\"auth,auth-int\"")]
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm=foo qop=\"auth,auth-int\"")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
  end

  it "test_parse_multiple" do
    expect = [
      challenge("Basic", {"realm" => "foo"}, "Basic realm=foo"),
      challenge("Digest", {"realm" => "bar"}, "Digest realm=bar"),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm=foo, Digest realm=bar")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
    result[1].scheme.should eq expect[1].scheme
    result[1].params.should eq expect[1].params
    result[1].raw.should eq expect[1].raw
  end

  it "test_parse_multiple_without_comma_delimiter" do
    expect = [
      challenge("Basic", {"realm" => "foo"}, "Basic realm=foo"),
      challenge("Digest", {"realm" => "bar"}, "Digest realm=bar"),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm=foo, Digest realm=bar")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
    result[1].scheme.should eq expect[1].scheme
    result[1].params.should eq expect[1].params
    result[1].raw.should eq expect[1].raw
  end

  it "test_parse_multiple_blank" do
    expect = [
      challenge("Basic", {"realm" => "foo"}, "Basic realm=foo"),
      challenge("Digest", {"realm" => "bar"}, "Digest realm=bar"),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm=foo, Digest realm=bar")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
    result[1].scheme.should eq expect[1].scheme
    result[1].params.should eq expect[1].params
    result[1].raw.should eq expect[1].raw
  end

  it "test_parse_ntlm_init" do
    expect = [
      challenge("NTLM", nil, "NTLM"),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("NTLM")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
  end

  it "test_parse_ntlm_type_2_3" do
    expect = [
      challenge("NTLM", "foo=", "NTLM foo="),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("NTLM foo=")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
  end

  it "test_parse_realm_uppercase" do
    expect = [
      challenge("Basic", {"realm" => "foo"}, "Basic ReAlM=foo"),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic ReAlM=foo")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
  end

  it "test_parse_realm_value_case" do
    expect = [
      challenge("Basic", {"realm" => "Foo"}, "Basic realm=Foo"),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm=Foo")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
  end

  it "test_parse_scheme_uppercase" do
    expect = [
      challenge("Basic", {"realm" => "foo"}, "BaSiC realm=foo"),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("BaSiC realm=foo")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
  end

  it "test_parse_bad_whitespace_around_auth_param" do
    expect = [
      challenge("Basic", {"realm" => "foo"}, "Basic realm = \"foo\""),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm = \"foo\"")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
  end

  it "test_parse_bad_single_quote" do
    expect = [
      challenge("Basic", {"realm" => "'foo"}, "Basic realm='foo"),
    ]

    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    result = parser.parse("Basic realm='foo bar', qop='baz'")
    result[0].scheme.should eq expect[0].scheme
    result[0].params.should eq expect[0].params
    result[0].raw.should eq expect[0].raw
  end

  it "test_quoted_string" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new "\"text\""

    string = parser.quoted_string

    string.should eq "text"
  end

  it "test_quoted_string_bad" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new "\"text"

    string = parser.quoted_string

    string.should eq nil
  end

  it "test_quoted_string_quote" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new "\"escaped \\\" here\""

    string = parser.quoted_string

    string.should eq "escaped \\\" here"
  end

  it "test_quoted_string_quote_end" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new "\"end \\\"\""

    string = parser.quoted_string

    string.should eq "end \\\""
  end

  it "test_token" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new "text"

    string = parser.token

    string.should eq "text"
  end

  it "test_token_space" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new "t ext"

    string = parser.token

    string.should eq "t"
  end

  it "test_token_special" do
    parser = Mechanize::HTTP::WWWAuthenticateParser.new
    parser.scanner = StringScanner.new "t\text"

    string = parser.token

    string.should eq "t"
  end
end

private def challenge(scheme, params, raw)
  Mechanize::HTTP::AuthChallenge.new(scheme, params, raw)
end
