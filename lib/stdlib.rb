class Integer
  def to_ss
    sign = self < 0 ? "-" : "+"
    "#{sign}#{abs}"
  end
end

class Time
  def minute
    min
  end

  def box
    ""
  end

  def path(x)
    # only first 5 elements are relevant (m,h,d,mon,y)
    to_a[..5].reverse.take([0, DEPTH[x] - 1].max).join("/")
  end
end

class String
  def lstrip_by(chars)
    gsub(Regexp.new("^[#{chars}]+"), "")
  end

  def rstrip_by(chars)
    gsub(Regexp.new("[#{chars}]+$"), "")
  end

  def strip_by(chars)
    lstrip_by(chars).rstrip_by(chars)
  end

  def stlip(c)
    strip_by(c).split(c)
  end

  def integer?
    self =~ /^\d+$/
  end
end

class Array
  def jomp(x)
    join(x).chomp(x)
  end
end
