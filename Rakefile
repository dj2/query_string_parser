require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'spec/rake/spectask'
require 'fileutils'
include FileUtils

# Default Rake task is compile
task :default => :compile

def make(makedir)
  Dir.chdir(makedir) { sh 'make' }
end

def extconf(dir)
  Dir.chdir(dir) { ruby "extconf.rb" }
end

def setup_extension(dir, extension)
  ext = "ext/#{dir}"
  ext_so = "#{ext}/#{extension}.#{Config::CONFIG['DLEXT']}"
  ext_files = FileList[
    "#{ext}/*.c",
    "#{ext}/*.h",
    "#{ext}/extconf.rb",
    "#{ext}/Makefile",
    "lib"
  ]

  task "lib" do
    directory "lib"
  end

  desc "Builds just the #{extension} extension"
  task extension.to_sym => ["#{ext}/Makefile", ext_so ]

  file "#{ext}/Makefile" => ["#{ext}/extconf.rb"] do
    extconf "#{ext}"
  end

  file ext_so => ext_files do
    make "#{ext}"
    cp ext_so, "lib"
  end
end

setup_extension("", "pr_query_parser")

desc "Compile the extension"
task :compile => [:pr_query_parser]

Spec::Rake::SpecTask.new('do_spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end
desc "run spec tests"
task :spec => [:clean, :compile, :do_spec]

CLEAN.include ['build/*', '**/*.o', '**/*.so', '**/*.bundle', '**/*.a', '**/*.log', 'pkg']
CLEAN.include ['ext/Makefile']

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "query_string_parser"
    s.summary = "Simple query string parser"
    s.email = "dj2@everburning.com"
    s.homepage = "http://github.com/dj2/query_string_parser"
    s.description = s.summary
    s.authors = ["dan sinclair"]
    s.files = [
      "Rakefile",
      "ext/extconf.rb",
      "ext/pr_query_parser.c",
      "lib/query_string_parser.rb",
      "spec/query_string_parser_spec.rb"
    ]
    s.extensions << 'ext/extconf.rb'
    s.require_paths = ['lib']
    s.test_files = ['spec/query_string_parser_spec.rb']
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

