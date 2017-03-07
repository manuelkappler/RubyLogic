require 'sinatra'
require 'json'
require_relative '../Proof'
require_relative '../Implication'
require_relative '../LogicParser'

class ProofHolder

  @@proof = nil

  def self.init()
    @@proof = nil
  end

  def self.SetProof(prooftree)
    @@proof = prooftree
  end

  def self.Proof
    return @@proof
  end
end

configure do
  ProofHolder::init()
end

get '/' do
  haml :index
end

post '/formula_string' do
  premise_string = params[:premises]
  puts premise_string
  conclusion_string = params[:conclusion]
  begin
    implication = get_implication_from_strings premise_string, conclusion_string
    ProofHolder::SetProof( ProofTree.new implication)
    status 200
    body "#{ProofHolder::Proof().to_latex}"
  rescue Exception => e
    status 400
    puts e
    body "Could not parse string input"
  end
end

post '/apply_law' do
  proof = ProofHolder::Proof()
  law_string = params[:law]
  law = proof.get_law_from_string law_string
  return law.to_s
end

get '/get_laws' do
  status 200
  content_type :json
  body ProofHolder::Proof().get_all_laws.to_json
end

def get_implication_from_strings premises, conclusions
  vars = {}
  premises_string = premises.split(",").map{|x| x.strip}
  unless premises_string == [""]
    premises = []
    premises_string.each do |x| 
      vars, x_wff = parse_string(x, vars)
      premises << x_wff
    end 
  else
    premises = []
  end
  print premises.inspect + "\n"
  conclusion_string = conclusions.split(",").map{|x| x.strip}
  conclusion = []
  conclusion_string.each do |x| 
    vars, x_wff = parse_string(x, vars)
    conclusion << x_wff
  end 
  puts conclusion.inspect
  puts vars.inspect

  return Implication.new premises, conclusion
end
