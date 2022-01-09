require "kemal"
require "kemal-basic-auth"

TEST_SERVER_HOST = "0.0.0.0"
TEST_SERVER_PORT = 4567
TEST_SERVER_URL  = "http://#{TEST_SERVER_HOST}:#{TEST_SERVER_PORT}"

class BasicAuthHandler < Kemal::BasicAuth::Handler
  only ["/secret"]

  def call(env)
    return call_next(env) unless only_match?(env)

    super
  end
end

add_handler BasicAuthHandler.new("username", "password")

get "/secret" do
  "Authorized"
end

kemal_config = Kemal.config
kemal_config.env = "development"
kemal_config.logging = false

spawn do
  Kemal.run(port: TEST_SERVER_PORT)
end
spawn do
  sleep 300000
end

until Kemal.config.running
  sleep 1.millisecond
end
