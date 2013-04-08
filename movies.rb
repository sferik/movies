require 'sinatra/base'
require 'sinatra/reloader'
require 'open-uri'
require 'json'

class Movies < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  before do
    @app_name = "Movies App"
    # Sets the default page title
    @page_title = @app_name
  end

  get '/' do
    @page_title += ": Home"
    erb :home
  end

  get '/search' do
    @query = params[:q]
    @page_title += ": Search Results for #{@query}"
    @button = params[:button]
    if @button == "lucky"
      file = open("http://www.omdbapi.com/?t=#{URI.escape(@query)}")
      @result = JSON.load(file.read)
      set_actors_and_directors(@result)
      erb :detail
    else
      file = open("http://www.omdbapi.com/?s=#{URI.escape(@query)}")
      @results = JSON.load(file.read)["Search"] || []
      if @results.size == 1
        redirect "/movies?id=#{@results.first["imdbID"]}"
      else
        erb :results
      end
    end
  end

  get '/movies' do
    @id = params[:id]
    file = open("http://www.omdbapi.com/?i=#{URI.escape(@id)}&tomatoes=true")
    @result = JSON.load(file.read)
    @page_title += ": #{@result["Title"]}"
    set_actors_and_directors(@result)
    erb :detail
  end

  def set_actors_and_directors(result)
    @actors = result["Actors"].split(", ")
    @directors = result["Director"].split(", ")
  end

  run!
end
