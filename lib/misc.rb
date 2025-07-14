# frozen_string_literal: true

def yes_or_no?(question, pre = nil, post = nil)
  puts pre if pre
  loop do
    print "#{question} (yes|no): "
    answer = $stdin.gets&.chomp&.downcase
    die 1 if answer.nil?
    if %w[yes y no n].any?(answer) || answer.empty?
      puts post if post
      return %w[yes y].any?(answer)
    else
      puts "Please enter 'yes', 'y', 'n', or 'no'."
    end
  end
end

def die(status = 0)
  yield if block_given?
  exit(status)
end

def err(message, *args)
  $stderr.printf "Error: #{message} \n", *args
  die 1
end

def yornal_depth(dir)
  return 0 unless File.directory? dir

  Dir.children(dir)
     .delete_if { |i| i =~ /\D/ } # remove nested yornals
     .map { |i| 1 + yornal_depth([dir, i].join("/")) }.max or 1
end

def tree(dir)
  return [dir] if !(File.directory? dir) || dir =~ /\.git/

  Dir.children(dir).map { |f| tree [dir, f].join("/") }.flatten
end

def defbin(x, fallback: [])
  define_method(x) do
    binaries = fallback
    path = ENV["PATH"].split(":")
    ENV[x.to_s.upcase] or
      binaries.find { |b| path.any? { |p| File.exist? "#{p}/#{b}" } } or "cat"
  end
end

defbin(:editor, fallback: %w[nvim vim vi emacs zile nano code])
defbin(:pager, fallback: %w[less more])

def mkdir(path)
  system "mkdir -p #{path} > /dev/null" or
    err("could not create directory '%s'", path)
end

def touch(path)
  spath = path.split "/"
  mkdir(spath[..-2].join("/")) if spath.size > 1
  File.open(path, "w") { }
end

# wrapper for git call
def git(*command)
  system command.insert(0, "git").join(" ")
end
