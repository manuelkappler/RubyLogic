require 'sinatra'
require 'json'
require_relative '../proof/proof_pc0.rb'

class ProofHolder

  @@proof = nil

  def self.init()
    @@proof = nil
  end

  def self.SetProof(prooftree)
    @@proof = prooftree
  end

  def self.GetProof()
    return @@proof
  end

  def self.CurStep()
    return @@cur_step
  end

  def self.AllSteps()
    return @@all_steps
  end
  
  def self.SetCurStep(step)
    @@cur_step = step
  end

  def self.SetAllSteps()
    return @@all_steps
  end

  def self.SetLaws(law_ary)
    @@laws = law_ary
  end

  def self.GetLaws()
    return @@laws
  end

  def self.SetWFF(wff)
    @@wff = wff
  end

  def self.WFF()
    return @@wff
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
  conclusion_string = params[:conclusion]
  begin
    proof = Proof.new premise_string, conclusion_string
    puts proof.inspect
    ProofHolder::SetProof( proof )
    status 200
    content_type :json
    all_steps, cur_step = proof.next_step!
    ProofHolder.SetCurStep(cur_step)
    latex = all_steps.map{|step| [step.step_number, "\\[ #{step.implication.to_latex} \\]", "\\[ #{step.law.to_latex} \\]", (step.implication.valid? ? "✔" : (step.implication.abort? ? "✘" : ""))]}
    if cur_step
      body ({:message => "more", :proof => latex, :next_step => {:premises => cur_step.implication.premises.map{|x| x.to_latex}, :conclusion => cur_step.implication.conclusion.to_latex}}.to_json)
    else
      if proof.valid?
        puts "Valid implication"
        body ({:message => "valid", :proof => latex}.to_json)
      else
        puts "Invalid implication: #{proof.get_counterexample.to_s}"
        body ({:message => "invalid", :proof => latex, :counterexample => proof.get_counterexample.to_s}.to_json)
      end
    end
  rescue Exception => e
    status 400
    puts e.backtrace
    body "Could not parse string input"
  end
end

#  proof.proof do |all_steps, cur_step|
#    puts cur_step.to_s
#    wff = nil
#    law = nil
#    if cur_step
#      body ({:message => "more", :proof => all_steps.map{|step| step.to_latex}, :next_step => {:premises => cur_step.implication.premises.map{|x| x.to_latex}, :conclusion => cur_step.implication.conclusion.to_latex}}.to_json)
#    else
#      if proof.valid?
#        puts "Valid implication"
#        body ({:message => "valid", :proof => proof.to_latex}.to_json)
#      else
#        puts "Invalid implication: #{proof.get_counterexample}"
#        body ({:message => "invalid", :proof => proof.to_latex, :counterexample => proof.get_counterexample}.to_json)
#      end
#    end
#  end
#
get '/get_laws/:element' do
  cur_step = ProofHolder.CurStep()
  puts params[:element]
  if params[:element] == "conclusion"
    loc = "Conclusion"
  else
    match = /(?<loc>[a-z]*)(?<idx>\d{1,2})/.match(params[:element])
    puts match.inspect
    loc = match[:loc]
    idx = match[:idx]
  end
  wff = (loc == "premise") ? cur_step.implication.premises[idx.to_i] : cur_step.implication.conclusion
  puts "Chose element #{wff} (#{wff.inspect}) (is equality? #{wff.predicate.is_a? Equality}) to go on with"
  ProofHolder.SetWFF(wff)
  laws = wff.get_applicable_laws (loc == "premise")
  if laws.include? SubstituteEquivalents
    laws.delete SubstituteEquivalents
    find_equivalences(wff).each{|eq| laws << eq}
  end
  ProofHolder.SetLaws(laws)
  puts laws.inspect
  status 200
  content_type :json
  body laws.to_json
end

post '/apply_law' do
  puts "In apply law"
  laws = ProofHolder.GetLaws()
  law = laws[params[:law].to_i]
  puts law.inspect
  if law < Equivalence
    law = SubstituteEquivalents.new law
  else
    law = law.new
  end
  cur_step = ProofHolder.CurStep()
  proof = ProofHolder.GetProof()
  proof.apply_step! ProofHolder.WFF(), law
  all_steps, cur_step = proof.next_step!
  latex = all_steps.map{|step| [step.step_number, "\\[ #{step.implication.to_latex} \\]", "\\[ #{step.law.to_latex} \\]", (step.implication.valid? ? "✔" : (step.implication.abort? ? "✘" : ""))]}
  ProofHolder.SetCurStep(cur_step)
  status 200
  content_type :json
  if cur_step
    body ({:message => "more", :proof => latex, :next_step => {:premises => cur_step.implication.premises.map{|x| x.to_latex}, :conclusion => cur_step.implication.conclusion.to_latex}}.to_json)
  else
    if proof.valid?
      puts "Valid implication"
      body ({:message => "valid", :proof => latex}.to_json)
    else
      puts "Invalid implication: #{proof.get_counterexample.to_s}"
      body ({:message => "invalid", :proof => latex, :counterexample => proof.get_counterexample.to_s}.to_json)
    end
  end
end

 ###   [wff, law]
  #      match = /(?<loc>[a-z]*)(?<idx>\d{1,2})/.match(params[:element])
  #      loc = match[:loc]
  #      idx = match[:idx]
  #      cur_step = proof.get_current_step_wffs
  #      wff = (loc == "premise") ? cur_step[:premises][idx.to_i] : cur_step[:conclusion][idx.to_i]
  #      if law_string.length == 2
  #        proof.apply_step law, wff, law_string[1].to_i
  #      else
  #        proof.apply_step law, wff
  #      end
  #      cur_step = proof.get_current_step_wffs
  #      content_type :json
  #      status 200
  #      if cur_step
  #        body ({:message => "more", :proof => proof.to_latex, :next_step => {:premises => cur_step[:premises].map{|x| x.to_latex}, :conclusion => cur_step[:conclusion].map{|x| x.to_latex}}}.to_json)
  #      else
  #        if proof.valid?
  #          body ({:message => "valid", :proof => proof.to_latex}.to_json)
  #        else
  #          body ({:message => "invalid", :proof => proof.to_latex, :counterexample => proof.get_counterexample}.to_json)
  #        end
  #      end

