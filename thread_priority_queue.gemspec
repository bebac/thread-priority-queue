GEMSPEC = Gem::Specification.new do |s|   
  s.name         = 'thread_priority_queue'
  s.version      = '1.0.0'
  s.platform     = Gem::Platform::RUBY
  s.author       = 'Benny Bach'
  s.email        = 'benny.bach@gmail.com'
  s.homepage     = 'http://rake.rubyforge.org'
  s.summary      = 'Thread safe priority queues'
  s.description  = 'Provide prioritized versions of the ruby standard library Queue and SizedQueue.'
  s.files        = Dir.glob('{lib,test}/**/*') + %w[README.md Rakefile]
  s.require_path = 'lib'
end
