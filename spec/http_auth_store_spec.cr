require "./spec_helper"

describe "Mechanize AuthStore test" do
  it "add_auth" do
    auth_store = Mechanize::HTTP::AuthStore.new
    url = URI.parse("http://example.com/")
    user = "kanezoh"
    password = "password"
    realm = ""
    auth_store.add_auth(url, user, password)
    auth_store.auth_accounts[url].size.should eq 1
    auth_store.auth_accounts[url][realm].should eq(["kanezoh", "password", ""])
  end

  it "test_add_auth_domain" do
    auth_store = Mechanize::HTTP::AuthStore.new
    url = URI.parse("http://example.com/")
    user = "kanezoh"
    password = "password"
    domain = "domain"
    realm = ""
    auth_store.add_auth(url, user, password, nil, domain)
    auth_store.auth_accounts[url][realm].should eq(["kanezoh", "password", "domain"])
  end

  it "test_add_auth_realm" do
    auth_store = Mechanize::HTTP::AuthStore.new
    url = URI.parse("http://example.com/")
    auth_store.add_auth url, "user1", "pass"
    auth_store.add_auth url, "user2", "pass", "realm"

    expected = {
      url => {
        ""      => ["user1", "pass", ""],
        "realm" => ["user2", "pass", ""],
      },
    }

    auth_store.auth_accounts.should eq expected
  end

  it "test_add_auth_realm_case" do
    auth_store = Mechanize::HTTP::AuthStore.new
    url = URI.parse("http://example.com/")
    auth_store.add_auth url, "user1", "pass", "realm"
    auth_store.add_auth url, "user2", "pass", "Realm"

    expected = {
      url => {
        "realm" => ["user1", "pass", ""],
        "Realm" => ["user2", "pass", ""],
      },
    }

    auth_store.auth_accounts.should eq expected
  end

  it "test_add_auth_string" do
    auth_store = Mechanize::HTTP::AuthStore.new
    url = URI.parse("http://example.com/")
    auth_store.add_auth "#{url}/path", "user", "pass"

    expected = {
      url => {
        "" => ["user", "pass", ""],
      },
    }

    auth_store.auth_accounts.should eq expected
  end

  it "test_credentials_eh" do
    auth_store = Mechanize::HTTP::AuthStore.new
    url = URI.parse("http://example.com/")

    challenges = [
      Mechanize::HTTP::AuthChallenge.new("Basic", {"realm" => "r"}),
      Mechanize::HTTP::AuthChallenge.new("Digest", {"realm" => "r"}),
    ]

    auth_store.credentials?(url, challenges).should_not eq true

    auth_store.add_auth url, "user", "pass"

    auth_store.credentials?(url, challenges).should eq true
    auth_store.credentials?("#{url}/path", challenges).should eq true
  end
end
