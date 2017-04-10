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
require 'pandoc-ruby'



class MainApp < Sinatra::Base
	configure do
			set :reload_templates, true
	end

  get '/' do
    files = Dir['articles/*.md']
    @articles = files.map{|x| x = {:title => open(x, &:gets), :content => PandocRuby.markdown(open(x).read).to_html, :link => "/"}}
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

