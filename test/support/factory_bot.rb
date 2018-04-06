require "factory_bot"

FactoryBot.find_definitions

Minitest::Test.send(:include, FactoryBot::Syntax::Methods)
