require 'sinatra'
require 'json'
require_relative '../../truthtable/truthtable'

class TruthTable < Sinatra::Base
  set :root, File.expand_path('../../', __FILE__)

  get '/' do
    haml :truthtable
  end

  post '/sentence_string' do
    tt = TruthTableCreater.new params[:string] 
    status 200
    content_type :json
    (tt.row_wise_ary).to_json  
  end

end
