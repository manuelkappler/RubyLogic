#\ -p 4567 -o 0
require 'rack'
require_relative 'web_logic.rb'
require_relative 'apps/predicate_proof.rb'
require_relative 'apps/sentential_proof.rb'

use Rack::Static, :urls => ['public/styles.css', 'public/index.js'], :root => 'public'

run Rack::URLMap.new(
  "/" => MainApp.new,
  "/predicate_logic/" => ProofPred.new,
  "/sentential_logic/" => ProofSent.new,
  "/truthtables/" => TruthTable.new)

