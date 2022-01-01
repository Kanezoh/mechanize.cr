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
    auth_store.auth_accounts[url][realm].should eq(["kanezoh", "password", nil])
  end

  it "credentials_for" do
    auth_store = Mechanize::HTTP::AuthStore.new
    url = URI.parse("http://example.com/")
    user = "kanezoh"
    password = "password"
    realm = ""
    auth_store.add_auth(url, user, password)
    auth_store.credentials_for(url, realm).should eq ["kanezoh", "password", nil]
  end
end
