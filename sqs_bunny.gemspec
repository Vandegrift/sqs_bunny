Gem::Specification.new do |s|
  s.name        = 'sqs_bunny'
  s.version     = '0.0.2'
  s.date        = '2014-09-08'
  s.summary     = "Copy Amazon SQS messages from one master queue to multiple child queues"
  s.description     = "Polls a single SQS queue and copies the body of any messages to a configurable set of child queues then deletes the message from the parent."
  s.authors     = ["Brian Glick"]
  s.email       = 'brian@brian-glick.com'
  s.files       = ["lib/sqs_bunny.rb"]
  s.require_paths = ['lib']
  s.homepage    =
    'https://github.com/Vandegrift/sqs_bunny'
  s.license       = 'Apache 2.0'
  s.executables << 'sqs_bunny'
  s.add_dependency('aws-sdk-core',['~> 2.0.beta'])
  s.add_development_dependency('rspec',['~> 3.1'])
end