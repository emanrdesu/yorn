Gem::Specification.new do |spec|
  spec.name = "yorn"
  spec.version = "0.1.0"
  spec.summary = "A program for managing journals (yornals)."
  spec.description = "A command-line journal management tool that uses git for version control."
  spec.authors = ["emanrdesu"]
  spec.email = "janitor@waifu.club"
  spec.files = Dir["lib/**/*.rb"] + ["bin/yorn"]
  spec.executables << "yorn"
  spec.homepage = "https://github.com/emanrdesu/yorn"
  spec.license = "GPL-3.0-only"

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_runtime_dependency "optimist", "~> 3.2.1"
  spec.add_runtime_dependency "emanlib", "~> 1.0.1"
end
