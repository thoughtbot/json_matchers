require "factory_bot"

FactoryBot.find_definitions

Minitest::Test.include(FactoryBot::Syntax::Methods)
