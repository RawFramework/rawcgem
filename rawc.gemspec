version = '1.0'
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'rawc'
  s.version     = version
  s.files = Dir['bin/**/*','lib/**/*'] #+ Dir['lib/**/*'] 
  s.bindir = 'bin'
  s.executables << 'rawc'
  
  s.summary     = 'Rawc  - rake wrapper for RAW Framework for .Net Core 1'
  s.description = 'Rawc  uses rake'
  
  s.authors            = ['Pedro Ramirez']
  s.email             = 'pramirez@sciodev.com'
  s.homepage          = 'https://rawframework.github.io/rawfdotnetcore/index.html'
  s.rubyforge_project = 'rawc'
end