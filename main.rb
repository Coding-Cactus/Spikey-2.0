require "mongo"
require "sinatra"
require "discordrb"

require_relative "lib/spikey"


set :bind, "0.0.0.0"

get "/" do
	"hi"
end

Thread.new { Spikey.new(ENV["token"], ENV["mongouri"]).run }
