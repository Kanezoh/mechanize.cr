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
end
