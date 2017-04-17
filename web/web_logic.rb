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
    @articles = files.map do |x| 
      fn = File.basename(x)
      file_lines = IO.readlines(x)
      meta_sep = (file_lines[1..-1].find_index{|x| x.strip == ("---")}) + 1
      meta = file_lines[0..meta_sep]
      puts meta
      puts meta.select{|line| line.strip.start_with? "title"}
      /title:\w?(?<title>.*)/ =~ meta.select{|line| line.strip.start_with? "title"}[0]
      puts title
      teaser = file_lines[meta_sep + 1 .. 10].join("\n")
      text = file_lines[meta_sep + 1..-1].join("\n")
      {:title => title, :teaser => PandocRuby.markdown(teaser).to_html, :content => PandocRuby.markdown(text).to_html, :link => fn[0..-4]}
    end
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

