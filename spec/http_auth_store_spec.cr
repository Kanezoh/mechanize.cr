require "./spec_helper"

describe "Mechanize AuthStore test" do
  it "add_auth" do
    auth_store = Mechanize::HTTP::AuthStore.new
    url = URI.parse("http://example.com/")
    user = "kanezoh"
    password = "password"
    auth_store.add_auth(url, user, password)
    auth_store.auth_accounts.size.should eq 1
    auth_store.auth_accounts[url].should eq({"kanezoh", "password"})
  end
end
