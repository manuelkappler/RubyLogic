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

  def self.Proof()
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
    proof = ProofTree.new implication
    ProofHolder::SetProof( proof )
    status 200
    cur_step = proof.get_current_step_wffs
    body ({:proof => proof.to_latex, :next_step => {:premises => cur_step[:premises].map{|x| x.to_latex}, :conclusion => cur_step[:conclusion].map{|x| x.to_latex}}}.to_json)
  rescue Exception => e
    status 400
    puts e
    body "Could not parse string input"
  end
end

post '/apply_law' do
  puts "In apply law"
  proof = ProofHolder::Proof()
  law_string = params[:law].split("_")
  law = proof.get_law_from_string law_string[0]
  match = /(?<loc>[a-z]*)(?<idx>\d{1,2})/.match(params[:element])
  loc = match[:loc]
  idx = match[:idx]
  cur_step = proof.get_current_step_wffs
  wff = (loc == "premise") ? cur_step[:premises][idx.to_i] : cur_step[:conclusion][idx.to_i]
  if law_string.length == 2
    proof.apply_step law, wff, law_string[1].to_i
  else
    proof.apply_step law, wff
  end
  cur_step = proof.get_current_step_wffs
  content_type :json
  status 200
  if cur_step
    body ({:message => "more", :proof => proof.to_latex, :next_step => {:premises => cur_step[:premises].map{|x| x.to_latex}, :conclusion => cur_step[:conclusion].map{|x| x.to_latex}}}.to_json)
  else
    if proof.valid?
      body ({:message => "valid", :proof => proof.to_latex}.to_json)
    else
      body ({:message => "invalid", :proof => proof.to_latex, :counterexample => proof.get_counterexample}.to_json)
    end
  end
end

get '/get_laws' do
  status 200
  content_type :json
  body ProofHolder::Proof().get_all_laws.to_json
end

get '/get_laws/:element' do
  puts params[:element]
  match = /(?<loc>[a-z]*)(?<idx>\d{1,2})/.match(params[:element])
  puts match.inspect
  loc = match[:loc]
  idx = match[:idx]
  proof = ProofHolder::Proof()
  cur_step = proof.get_current_step_wffs
  wff = (loc == "premise") ? cur_step[:premises][idx.to_i] : cur_step[:conclusion][idx.to_i]
  laws = proof.get_applicable_laws_for_wff(wff, loc == "premise").reject{|key, val| not val}
  status 200
  content_type :json
  body laws.to_json
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
