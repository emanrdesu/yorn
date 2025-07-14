class Parse
  @@timeFields = [
    [:week, "w", "week"],
    [:second, "s", "second"],
    [:year, "y", "year"],
    [:month, "m", "mon", "month"],
    [:day, "d", "day"],
    [:hour, "h", "hour"],
    [:minute, "min", "minute"],
  ]

  def self.entrySpecBase(argument, entries)
    location, *operands = argument.split(/[+-]/)
    ops = argument.scan(/[+-]/)

    { ["", "t", "tail"] => proc { |a, n| a[a.size - 1 + n] },
     %w[h head] => proc { |a, n| a[n] },
     %w[m mid middle] => proc { |a, n| a[(a.size / 2) + n] } }.find { |k, _v| k.any? location }
      .default { err "undefined location '#{location}'" }
      .then do |_, locator|
      return locator[entries, 0].to_t if operands.empty?

      yield location, operands, ops, locator
    end
  end

  def self.editFlag(argument, entries) # Time
    Parse.entrySpecBase(argument, entries) do |*vars|
      location, operands, ops, locator = vars

      expr = operands.take_while(&:integer?).zip(ops).map(&:reverse)
      ops = ops[expr.size..]
      operands = operands[expr.size..]

      arg = (eval expr.join) || 0
      op = ops.shift
      anchor = locator[entries, arg]
      anchor or err("entry #{location}#{arg.to_ss} does not exist")

      operands.map { |x| Parse.timeLiteral x }
              .zip(ops).join
              .then { |time| anchor.to_t + (op == "+" ? 1 : -1) * (eval(time) || 0) }
    end
  end

  def self.entrySpec(argument, entries) # Time
    Parse.entrySpecBase(argument, entries) do |*vars|
      _, operands, ops, locator = vars

      operands.all?(&:integer?) or err("invalid argument '#{argument}'")
      (operands.size == ops.size) or err("invalid expression")
      arg = (eval ops.zip(operands).join) || 0

      locator[entries, arg].to_t
    end
  end

  def self.lastFirstFlag(argument) # [Symbol, Integer]
    return [:entry, argument.to_i] if argument.integer?

    @@timeFields
      .find { |_, *forms| forms.any? argument }
      .when(Array) { argument = "1.#{argument}" }

    operands = argument.split(/[+-]/)
    ops = argument.scan(/[+-]/)

    operands
      .map { |x| Parse.timeLiteral x }
      .zip(ops).join
      .then { |r| [:time, eval(r)] }
  end

  def self.timeLiteral(x) # Integer
    x =~ /\d+\.[a-z]+/ or err("malformed time spec '#{x}'")
    n, field = x.split(".")

    @@timeFields
      .find { |_m, *forms| forms.any? field }
      .tap { |_| _ or err "undefined time field '#{field}'" }
      .slice(0).then { |m| n.to_i.send(m) }
  end

  def self.yornalType(type)
    (@@timeFields[2..] + [[:box, "x", "box"]])
      .find { |_, *forms| forms.any? type }
  end
end
