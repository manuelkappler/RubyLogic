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
require_relative '../../proof/proof_fol'

class ParsingError < StandardError
end

class MismatchedParenthesis < StandardError
end

class ProofFOL < Sinatra::Base
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
    haml :predicate_proof
  end

  get '/to_latex' do
    proof = ProofHolder::GetProof().to_latex
    status 200
    content_type :text
    proof
  end

  post '/formula_string' do
    status 200
    content_type :json
    premise_string = params[:premises]
    conclusion_string = params[:conclusion]
    puts "Parsing #{premise_string} |= #{conclusion_string}"
    halt 403, "Empty conclusion" if conclusion_string.empty?
    begin
      proof = FOLProof.new premise_string, conclusion_string
      ProofHolder::SetProof( proof )
      status 200
      content_type :json
      body after_laws proof
    rescue ParsingError
      halt 403, "Could not parse your expression. Make sure to only use capital letters (P, Q, ...) for your predicates, lower case letters for terms, and the connectives #{ObjectSpace.each_object(Class).select{|cl| cl < BinaryConnective or cl < UnaryConnective and not cl == Quantifier}.map{|x| inst = x.new; inst.strings.join(', ')}.join('; ')}.
  <br> <b> Here's an example: <br> Premises: P(a, b) -> H(a), not H(a) <br> Conclusion: P(a, b) or H(a)</b>"
    rescue MismatchedParenthesis
      halt 403, "Mismatched parentheses. Make sure all parentheses are closed properly"
    rescue Exception => e
      halt 403, "Could not parse string input. You should inform the developer of this and send him the following: <br> #{e.message} #{e.backtrace}"
    end
  end

  def after_laws proof
    all_steps, cur_step = proof.next_step!
    ProofHolder.SetCurStep(cur_step)
    latex = all_steps.map{|step| [step.step_number, "\\[ #{step.implication.to_latex} \\]", "\\[ #{step.law.to_latex} \\]", (step.valid? ? "✔" : (step.abort? ? "✘" : ""))]}
    if cur_step
      body ({:message => "more", :proof => latex, :next_step => {:premises => cur_step.implication.premises.sort.map{|x| x.to_latex}, :conclusion => cur_step.implication.conclusion.to_latex}}.to_json)
    else
      if proof.valid?
        body ({:message => "valid", :proof => latex}.to_json)
      else
        body ({:message => "invalid", :proof => latex, :counterexample => proof.get_counterexample.to_latex}.to_json)
      end
    end
    return body
  end

  get '/get_laws/:element' do
    cur_step = ProofHolder.CurStep()
    if params[:element] == "conclusion"
      loc = "Conclusion"
    else
      match = /(?<loc>[a-z]*)(?<idx>\d{1,2})/.match(params[:element])
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
    if laws.include? UniversalPremise
      laws.delete UniversalPremise
      constants = cur_step.implication.get_all_constants.to_a
      if constants.empty?
        laws << UniversalPremise.new(Constant.new 'a' )
      else
        constants.each{|x| laws << (UniversalPremise.new x)}
      end
    end
    if laws.include? ExistentialPremise
      laws.delete ExistentialPremise
      constants = cur_step.implication.get_all_constants.to_a
      if constants.empty?
        laws << ExistentialPremise.new(Constant.new 'a' )
      else
        laws << ExistentialPremise.new(Constant.new(("a".."z").to_a[("a".."z").to_a.index(constants.to_a.sort[-1].name) + 1]))
      end

    end
    ProofHolder.SetLaws(laws)
    status 200
    content_type :json
    body laws.map{|x| x.to_s}.to_json
  end

  post '/apply_law' do
    status 200
    content_type :json
    laws = ProofHolder.GetLaws()
    law = laws[params[:law].to_i]
    if law.is_a? UniversalPremise or law.is_a? ExistentialPremise
    elsif law < Equivalence
      law = SubstituteEquivalents.new law
    else
      law = law.new
    end
    proof = ProofHolder.GetProof()
    proof.apply_step! ProofHolder.WFF(), law
    body after_laws proof
  end
end
