require 'rubygems'
require 'sinatra'
class MyApp < Sinatra::Base
  get /\/Themes\/(.*)/ do
    send_file "../gdotui/Themes/#{params[:captures].first}"
  end
  
  get /\/mootools\/(.*)/ do
    send_file "../gdotui/mootools/#{params[:captures].first}"
  end

  get /\/Builds\/(.*)/ do
    send_file "../Builds/#{params[:captures].first}"
  end
  get '/demo.js' do
    send_file "demo.js"
  end
  get '*' do
    haml 'div'
  end
end
