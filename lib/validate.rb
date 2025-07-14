class Validate
  def self.queryFlag(query)
    query =~ %r{//} and err "consecutive / in query"
    query.split("/")
         .tap { |x| (x.size > 0) or err "empty query" }
         .each do |n|
      n.split(",").each do |n|
        unless (n =~ /^\d+(-\d+)?$/) || (n == "@")
          err "malformed --query component '#{n}'"
        end
      end
    end
  end

  def self.entryLiteral(argument)
    fields = argument.split("/")
    fields.all?(&:integer?) or err "malformed entry literal"
    (fields.size <= 6) or err "only 6 datetime fields can be specified max"
    fields.map(&:to_i).all? { |i| i >= 0 } or err "negative numbers not allowed"
  end
end
