# RubyLogic is a Sinatra-based Web App that enables students to play
# around with proving claims in Sentential and Predicate logic following
# the system laid out by Haim Gaifman.
# 
# Copyright (C) 2017 Manuel Käppler, manuel.kaeppler@columbia.edu
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.


require 'sinatra'
require 'json'
require_relative '../../proof/proof_sentential'

class ProofSent < Sinatra::Base
  set :root, File.expand_path('../../', __FILE__)
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
    haml :sentential_proof
  end

  get '/to_latex' do
    proof = ProofHolder::GetProof().to_latex
    status 200
    content_type :text
    proof
  end

  post '/formula_string' do
    premise_string = params[:premises]
    conclusion_string = params[:conclusion]
    begin
      proof = SententialProof.new premise_string, conclusion_string
      #puts proof.inspect
      ProofHolder::SetProof( proof )
      status 200
      content_type :json
      all_steps, cur_step = proof.next_step!
      ProofHolder.SetCurStep(cur_step)
      latex = all_steps.map{|step| [step.step_number, "\\[ #{step.implication.to_latex} \\]", "\\[ #{step.law.to_latex} \\]", (step.valid? ? "✔" : (step.abort? ? "✘" : ""))]}
      if cur_step
        body ({:message => "more", :proof => latex, :next_step => {:premises => cur_step.implication.premises.sort.map{|x| x.to_latex}, :conclusion => cur_step.implication.conclusion.to_latex}}.to_json)
      else
        if proof.valid?
          #puts "Valid implication"
          body ({:message => "valid", :proof => latex}.to_json)
        else
          #puts "Invalid implication: #{proof.get_counterexample.to_s}"
          body ({:message => "invalid", :proof => latex, :counterexample => proof.get_counterexample.to_s}.to_json)
        end
      end
    rescue Exception => e
      status 400
      puts e.backtrace
      body "Could not parse string input"
    end
  end

  get '/get_laws/:element' do
    cur_step = ProofHolder.CurStep()
    #puts params[:element]
    if params[:element] == "conclusion"
      loc = "Conclusion"
    else
      match = /(?<loc>[a-z]*)(?<idx>\d{1,2})/.match(params[:element])
      #puts match.inspect
      loc = match[:loc]
      idx = match[:idx]
    end
    wff = (loc == "premise") ? cur_step.implication.premises.sort[idx.to_i] : cur_step.implication.conclusion
    ProofHolder.SetWFF(wff)
    laws = wff.get_applicable_laws (loc == "premise")
    if laws.include? SubstituteEquivalents
      laws.delete SubstituteEquivalents
      find_equivalences(wff).each{|eq| laws << eq}
    end
    ProofHolder.SetLaws(laws)
    #puts laws.inspect
    status 200
    content_type :json
    body laws.map{|x| x.to_s}.to_json
  end

  post '/apply_law' do
    #puts "In apply law"
    laws = ProofHolder.GetLaws()
    law = laws[params[:law].to_i]
    #puts law.inspect
    if law < Equivalence
      law = SubstituteEquivalents.new law
    else
      law = law.new
    end
    cur_step = ProofHolder.CurStep()
    proof = ProofHolder.GetProof()
    proof.apply_step! ProofHolder.WFF(), law
    all_steps, cur_step = proof.next_step!
    latex = all_steps.map{|step| [step.step_number, "\\[ #{step.implication.to_latex} \\]", "\\[ #{step.law.to_latex} \\]", (step.valid? ? "✔" : (step.abort? ? "✘" : ""))]}
    ProofHolder.SetCurStep(cur_step)
    status 200
    content_type :json
    if cur_step
      body ({:message => "more", :proof => latex, :next_step => {:premises => cur_step.implication.premises.sort.map{|x| x.to_latex}, :conclusion => cur_step.implication.conclusion.to_latex}}.to_json)
    else
      if proof.valid?
        #puts "Valid implication"
        body ({:message => "valid", :proof => latex}.to_json)
      else
        #puts "Invalid implication: #{proof.get_counterexample.to_s}"
        body ({:message => "invalid", :proof => latex, :counterexample => proof.get_counterexample.to_latex}.to_json)
      end
    end
  end
end
