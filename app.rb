require "sinatra"
require "sinatra/reloader"
require "http"
require "openai"

get("/") do
  erb(:home)
end

get("/umbrella") do
  erb(:umbrella)
end

get("/process_umbrella") do
  #location information
  @location=params.fetch("umbrella_input").downcase
  access_gmaps_key = ENV.fetch("GMAPS_KEY")
  @gmaps_location= HTTP.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{@location}&key=#{access_gmaps_key}")
  @location_data=JSON.parse(@gmaps_location)
  @location_hash=@location_data.fetch("results").at(0)
  @geometry_hash=@location_hash.fetch("geometry")
  @lat=@geometry_hash.fetch("location").fetch("lat")
  @lng=@geometry_hash.fetch("location").fetch("lng")

  #weather information
  pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
  pirate_weather_url = HTTP.get("https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{@lat},#{@lng}")
  pirate_weather_data = JSON.parse(pirate_weather_url)
  weather_hash = pirate_weather_data.fetch("currently")
  @current_temp = weather_hash.fetch("temperature")

  #summary information
  summary_hash = pirate_weather_data.fetch("minutely")
  @summary=summary_hash.fetch("summary")

  #umbrella?
  hourly_hash = pirate_weather_data.fetch("hourly")
  hourly_data_array = hourly_hash.fetch("data") 
  next_twelve_hours = hourly_data_array[1..12]
  precip_prob_threshold = 0.10
  any_precipitation = false

  next_twelve_hours.each do |hour_hash|
    precip_prob = hour_hash.fetch("precipProbability")
    if precip_prob > precip_prob_threshold
      any_precipitation = true
    end
  end
  
  if any_precipitation == true
    @outcome= "You might want to take an umbrella!"
  else
    @outcome= "You probably won't need an umbrella."
  end

  erb(:process_umbrella)
end

get("/message") do

  erb(:message)
end

get("/process_single_message") do
  @my_message=params.fetch("my_input")
  client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  message_list = [@my_message]
  
  @api_response = client.chat(
  parameters: {
    model: "gpt-3.5-turbo",
    messages: message_list
  })
  erb(process_single_message)
end

get("/chat") do
  erb(:chat)
end
