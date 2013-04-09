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
    file = open("http://www.omdbapi.com/?s=#{URI.escape(@query)}")
    @results = JSON.load(file.read)["Search"] || []
    if @results.size == 1 || (@results.size > 1 && @button == "lucky")
      redirect "/movies?id=#{@results.first["imdbID"]}"
    else
      erb :serp
    end
  end

  get '/movies' do
    @id = params[:id]
    @query = params[:q]
    file = open("http://www.omdbapi.com/?i=#{URI.escape(@id)}&tomatoes=true")
    @result = JSON.load(file.read)
    file = open("http://www.omdbapi.com/?s=#{URI.escape(@result["Title"])}")
    @results = JSON.load(file.read)["Search"] || []
    @results.reject!{|movie| movie["Title"] == @result["Title"]}
    @page_title += ": #{@result["Title"]}"
    @actors = @result["Actors"].split(", ")
    @directors = @result["Director"].split(", ")
    erb :detail
  end

  run!
end
