require "sinatra"
require "sinatra/reloader"
require "http"

get("/") do
  erb(:home)
end

get("/umbrella") do
  erb(:umbrella)
end

get("/process_umbrella") do
  erb(:process_umbrella)
  @location=params.fetch("umbrella_input").downcase
  
end

get("/message") do
  erb(:message)
end

get("/chat") do
  erb(:chat)
end
