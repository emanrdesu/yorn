class Yornal
  attr_reader :name, :type

  ## class methods

  def self.dotYornalEdit(message, &block)
    File.write(
      $dotyornal,
      Yornal.list.tap(&block)
    )

    git(:add, $dotyornal)
    git(:commit, "-m '#{message}'")
  end

  def self.create(name, type)
    { /^\./ => "begin with a dot",
     %r{^/} => "begin with /",
     %r{/$} => "end with /",
     /\^/ => "contain ^",
     %r{//} => "contain consecutive /",
     /\.git/ => "contain '.git'",
     /^git$/ => "be 'git'",
     /^\d+$/ => "be digits only",
     %r{[^/._A-za-z0-9-]} => "have chars not in [a-z], [0-9] or [/_-.]" }.each do |regex, message|
      err "name cannot #{message}" if name =~ regex
    end

    err "yornal '#{name}' already exists" if Yornal.list.find { |n, _| n == name }

    [$yornalPath, name]
      .jomp("/").tap(&method(type == :box ? :touch : :mkdir))
      .then { |f| git(:add, f) if type == :box }

    message = "Create #{type} yornal '#{name}'"
    Yornal.dotYornalEdit(message) { |h| h[name] = type }
  end

  def self.delete(name, ask = true)
    Yornal.list.any? { |n, _| n == name } or err "'#{name}' yornal doesn't exist"
    pre = "You are about to delete yornal '#{name}'."
    question = "Are you sure you want to delete it?"

    if !ask || yes_or_no?(question, pre)
      Yornal.new(name).entries.each { |e| e.delete(ask = false) }
      message = "Delete #{name} yornal"
      Yornal.dotYornalEdit(message) do |h|
        h.delete name
      end

      system "rm -rf #{name} 2> /dev/null"
    end
  end

  def self.list
    eval(File.read($dotyornal)).assert(Hash)
  rescue Exception
    err "Malformed .yornal file"
  end

  def self.report
    spacing = nil
    countSpacing = nil
    Yornal.list.keys
          .map { |y| [y, Yornal.new(y).entries.size] }
          .tap do |ycs|
      die { puts "No yornals available. Create one with --create" } if ycs.empty?
      spacing = (ycs + [["yornal"]]).map(&:first).map(&:size).max + 1
      countSpacing = ycs.map(&:last).map(&:to_s).map(&:size).max
      printf "%-#{spacing}s %-#{countSpacing}s  type\n", "yornal", "#"
    end.each do |y, c|
      printf "%-#{spacing}s %-#{countSpacing}d  %s\n", y, c, Yornal.new(y).type
    end
  end

  ## instance methods

  def initialize(name)
    @name = name
    @type = Yornal.list[name]
  end

  def path
    $yornalPath + "/" + @name
  end

  def edit(editor = editor(), time = Time.now, ignore = nil)
    entryParent = [path, time.path(@type)].jomp("/")
    mkdir(entryParent) unless @type == :box
    entry = [entryParent, time.send(@type).to_s].jomp("/")

    if File.exist? entry
      Entry.fromPath(entry).edit(editor, :Modify, ignore)
    else
      system "touch #{entry}"
      Entry.fromPath(entry).edit(editor, :Create, ignore)
      File.delete entry if File.size(entry) == 0
    end
  end

  def entries(query = "@")
    self.query(query).map { |p| Entry.fromPath p }.sort
  end

  # e.g. pattern: @/@/8, 2022/09/@ ; depends on yornal type (depth)
  def query(pattern)
    dateStructure = %i[year month day hour min]
    datehash = ->(x) { x.zip(dateStructure).to_h.flip }

    tree(path).filter do |path|
      entry = path[$yornalPath.size + @name.size + 1..]
      unless entry.split("/").join =~ /\D/ # remove nested yornals
        entryHash = datehash.call(entry.stlip("/"))
        patternHash = datehash.call(pattern.downcase.stlip("/"))

        patternHash.map do |k, v|
          !entryHash[k] or (v == "@") or
            v.split(",").map do |x|
              l, r = x.split("-")
              (l..(r or l)) # ranges work for integer strings
            end.any? { |range| range.include? entryHash[k] }
        end.all? true
      end
    end
  end

  def first(x, n = 1, from = entries)
    return from[..(n - 1)] if x == :entry

    t = from[0].to_t
    from.filter { |e| e < (t + n) }
  end

  def last(x, n = 1, from = entries)
    return from[(-n)..] if x == :entry

    t = Time.now
    from.filter { |e| e > (t - n) }
  end
end
