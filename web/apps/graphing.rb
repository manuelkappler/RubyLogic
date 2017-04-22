# Displays a graph of the extension of a binary relation

# Given: Extension of a relation (array of arrays) [(a, b), (b, c), (c, c)]
# Result: d3 - graph of that relation

require 'sinatra'
require 'json'

class ExtensionGraph < Sinatra::Base

  set :root, File.expand_path('../../', __FILE__)


  get '/' do
    haml :extension_graph
  end

  post '/extension_submit' do
    extension_string = params[:extension]
    puts extension_string
    puts extension_string.split(/\)\s*,\s*\(/).map{|x| x.split(",")}.inspect
    extension = extension_string.split(/\)\s*,\s*\(/).map{|x| x.split(",").map{
      |y| /[[:punct:]]*\s?(?<l>[[:alnum:]]*)/ =~ y; l}}
    print extension.inspect + "\n"
    if extension.any?{|x| x.length != 2} or extension.empty?
      halt 403, "Something is wrong"
    end
    # Prepare the hash
    links = extension.flatten.uniq.map!.with_object({}){|x, hsh| hsh[x] = []}
    ids = extension.flatten.uniq.map!.with_object({}){|x, hsh| hsh[x] = {}}    
    # Fill the hash
    extension.each{|x| links[x[0]] << x[1]}
    extension.flatten.uniq.each_with_index{|x, idx| puts "#{x.inspect}: #{links[x]}"; ids[x] = {:label => x, :id => idx, :has_self => "#{(links[x].include? x) ? 'T' : 'F'}"}}
    status 200
    content_type :json
    body({:links => links, :ids => ids}.to_json)
  end
end
