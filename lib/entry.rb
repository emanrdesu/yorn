class Entry
  include Comparable
  attr_reader :date, :yornal # pseudo date, yornal (obj or name)

  def <=>(other)
    to_t <=> (other.is_a?(Entry) ? other.to_t : other)
  end

  def self.fromPath(path)
    path[$yornalPath.size..].stlip("/")
      .partition { |x| x =~ /^\d+$/ }
      .map { |a| a.join("/") }
      .then { |date, yornal| Entry.new date, yornal }
  end

  def initialize(date, yornal)
    @date = date.is_a?(Time) ? date.to_a[..5].drop_while { |i| i == 0 }.reverse.join("/") : date
    @yornal = yornal.is_a?(Yornal) ? yornal : Yornal.new(yornal)
  end

  def path
    [$yornalPath, name].jomp("/")
  end

  def name
    [@yornal.name, @date].jomp("/")
  end

  def to_t
    Time.new(*@date.split("/"))
  end

  def contains?(word)
    File.read(path) =~ Regexp.new(word, :i)
  end

  def matches?(regex)
    File.read(path) =~ Regexp.new(regex)
  rescue RegexpError
    err "Malformed regexp"
  end

  def edit(editor = editor(), action = :Modify, ignore = nil)
    digest = SHA256.digest(File.read(path))
    system "#{editor} #{path}"
    return if ignore || digest == SHA256.digest(File.read(path))

    git(:add, path)
    git(:commit, "-m '#{action} #{@yornal.name} entry #{@date}'")
  end

  def delete(ask = true)
    pre = "You are about to delete yornal entry '#{name}'."
    question = "Are you sure you want to delete it?"
    git(:rm, "#{path}") if !ask || yes_or_no?(question, pre)
  end

  def printout(delimiter = "\n\n")
    $stdout.print File.read(path)
    $stdout.print delimiter
  end

  def printpath(delimiter = "\n", fullpath)
    $stdout.print(fullpath ? path : name)
    $stdout.print delimiter
  end
end
