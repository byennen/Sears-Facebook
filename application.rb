require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'environment'
require 'omniauth/oauth'

configure do
  config = YAML.load_file('config.yaml') if !production?
  APP_ID = production? ? ENV['APP_ID'] : config['APP_ID']
  APP_API_KEY = production? ? ENV['APP_API_KEY'] : config['APP_API_KEY']
  APP_SECRET = production? ? ENV['APP_SECRET'] : config['APP_SECRET']
  APP_CANVAS_NAME = production? ? ENV['APP_CANVAS_NAME'] : config['APP_CANVAS_NAME']

  set :views, "#{File.dirname(__FILE__)}/views"
  enable :sessions
  use Rack::Facebook, { :secret => APP_SECRET }
  use OmniAuth::Builder do
    provider :facebook, APP_ID, APP_SECRET, {:client_options => client_options, :scope => ''}
  end
end

helpers do
  def partial(name, locals={})
    haml "_#{name}".to_sym, :layout => false, :locals => locals
  end

  def check_auth
    redirect '/auth/facebook' unless !session['fb_auth'].nil?
    # If we don't have the right user in the session, clear the session
    if !session['fb_auth'].nil? and !params['facebook'].nil? and 
      session['fb_auth']['uid'] != params['facebook']['user_id']
      clear_session
      redirect '/auth/facebook'
    end
  end 
end

before do
  content_type :html, :charset => 'utf-8'
  @js_conf = { :appId => APP_ID, :canvasName => APP_CANVAS_NAME,
    :userIdOnServer => session['fb_token'] ? session['fb_auth']['uid'] : nil}.to_json
end

error do
  haml :error
end

not_found do
  haml :not_found
end

get '/' do
  check_auth

  if session[:confirmation_message]
    @confirmation_message = session[:confirmation_message]
    session[:confirmation_message] = nil
  end
  haml :index
end

get '/clients/:api_key/?' do |api_key|
  content_type 'application/json', :charset => 'utf-8'
  [200, get_clients(api_key).to_json]
end

get '/lists/:api_key/:client_id/?' do |api_key, client_id|
  content_type 'application/json', :charset => 'utf-8'
  [200, get_lists_for_client(api_key, client_id).to_json]
end

get '/auth/facebook/callback/?' do
  session['fb_auth'] = request.env['omniauth.auth']
  session['fb_token'] = session['fb_auth']['credentials']['token']
  session['fb_error'] = nil
  redirect '/'
end

get '/auth/failure/?' do
  clear_session
  session['fb_error'] = 'In order to use this application you must permit access to your basic information.'
  redirect '/'
end

get '/logout/?' do
  clear_session
  redirect '/'
end

def clear_session
  session['fb_auth'] = nil
  session['fb_token'] = nil
  session['fb_error'] = nil
end