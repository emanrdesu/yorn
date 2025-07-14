class Format
  def self.examples(option, hash)
    return if hash[:examples].nil?

    hash[:examples]
      .then { |x| x.is_a?(String) ? [x] : x }
      .map { |e| (" " * 2) + e }
      .unshift("--#{option} examples:")
      .join("\n")
  end

  def self.syntax(syntax)
    [syntax].flatten.join("\n")
  end

  def self.monthswap(string)
    string = string.downcase

    %w[ january february march april
        may june july august september
        october november december
    ].map { |m| [m, m[0..2]].map { |x| Regexp.new(x) } }
      .zip(1..) do |names, i|
      names.each { |n| string.gsub!(n, i.to_s) }
    end

    string
  end

  def self.special(x)
    eval "\"#{x}\""
  end
end
