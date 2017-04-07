require 'sinatra'
require 'json'

class MainApp < Sinatra::Base
  get '/' do
    haml :index
  end
end

#class ProofPred < Sinatra::Base
#  get '/' do
#    status 200
#    content_type :html
#    "<h1> In Predicate Proof </h1>"
#  end
#end

class TruthTable < Sinatra::Base
  get '/' do
    "<h1> In TruthTable </h1>"
  end
end
