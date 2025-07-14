$options = {
  last: {
    default: "1",
    syntax: <<~SYNTAX,
      [$n | timeSpan[±timeSpan]*]
        where $j, $n ∈ NaturalNumber
        and timeSpan ::= [$j.]dateAttr
        and dateAttr ::= y[ear] | m[on[th]] | w[eek]
                      | d[ay] | h[our] | min[ute]
    SYNTAX

    examples: <<~EXAMPLES,
      # selects the last entry in foo
      yorn foo --last
      # all the entries in foo in the past 3 years
      yorn foo --last 3.year
      # last 4 entries in bar yornal
      yorn bar --last 4
      # all the entries in qux in the past 2 month + 3 days
      yorn qux --last 3.day+2.mon
      # default action for multiple entries is to print entry paths
    EXAMPLES
  },

  first: {
    default: "1",
    syntax: <<~SYNTAX,
      [$n | timeSpan[±timeSpan]*]
        where $j, $n ∈ NaturalNumber
        and timeSpan ::= [$j.]dateAttr
        and dateAttr ::= y[ear] | m[on[th]] | w[eek]
                      | d[ay] | h[our] | min[ute]
    SYNTAX

    examples: <<~EXAMPLES,
      # select first 5 entries in baz
      yorn baz --first 5
      # select entries in the period between the first
      # entry in pom and 2 months after the entry
      # very similiar to --last
      yorn pom --first 2.mon
    EXAMPLES
  },

  query: {
    default: "@",
    syntax: <<~SYNTAX,
      $year[/$month[/$day[/$hour[/$minute]]]]
        where $year,$month,$day,$hour and $minute
        ::= int[,(int | int-int)]* | "@"
        $month can be any month name as well
    SYNTAX

    examples: <<~EXAMPLES,
      # select all entries in the 'ter' yornal (default/automatic)
      yorn ter -q
      # select all entries in any year where the month is august
      yorn hue --query @/aug
      # selects all entries even though day was specified
      # because querying only cares about yornal set fields
      # i.e. only the two @'s are looked at in this case
      yorn monthlyJournal -q @/@/1
    EXAMPLES
  },

  edit: {
    default: "tail",
    syntax: <<~SYNTAX,
      loc[±$n | ±$k[±$i.dateAttr]*]
        where $n, $k, $i ∈ NaturalNumber
          and loc ::= [tail] | h[ead] | m[id[dle]]
          and dateAttr ::= y[ear] | m[on[th]]
                        | w[eek] | d[ay]
                        | h[our] | min[ute]
    SYNTAX

    examples: <<~EXAMPLES,
      # get entries from last year, edit the third from last entry
      yorn yup -l y -e t-2
      # error, as there is nothing after tail
      yorn jan -e tail+1
      # get all entries in hex yornal
      # edit entry 1.5 months before the fourth entry
      # entry won't exist, so will be created, and will be new first entry
      yorn hex -e head+3-2.month+15.day
    EXAMPLES
  },

  view: {
    default: "tail",
    syntax: <<~SYNTAX,
      location[±$n]*
        where location ::= [tail] | h[ead] | m[id[dle]]
          and $n ∈ NaturalNumber
    SYNTAX

    examples: <<~EXAMPLES,
      # view last entry in foo
      yorn foo -v
      # view second entry in foo
      yorn foo --view head+1
      # view third from last entry in foo
      yorn foo -v t-1-1
    EXAMPLES
  },

  add: {
    syntax: <<~SYNTAX,
      $year[/$month[/$day[/$hour[/$minute]]]]
        where all ∈ NaturalNumber
        and $month =~ month name
    SYNTAX

    examples: <<~EXAMPLES,
      # adds 2022 entry to yearYornal, ignores fields not applicable
      yorn yearYornal -a 2022/aug/20
    EXAMPLES
  },

  match: {
    syntax: "$word",
    examples: <<~EXAMPLES,
      # select entries in last 12 years
      # that have the word "money" in it  }
      yorn foo -l 12.y -m money
      # case insensitive
    EXAMPLES
  },

  regex: {
    syntax: "$regex",
    examples: <<~EXAMPLES,
      # select entries that have integers
      yorn foo -q @ -r "^\\d+$"
    EXAMPLES
  },

  create: {
    syntax: "$yornalname",
    examples: <<~EXAMPLES,
      # create box yornal named foo
      yorn -c foo
      # create yearly yornal named foo/bar
      yorn -c foo/bar -t year
      # create minute yornal named qux
      yorn -c qux -t min
    EXAMPLES
  },

  type: {
    default: "box",
    syntax: <<~SYNTAX,
      y[ear] | m[on[th]] | d[ay] |
      h[our] | min[ute]  | s[econd] | box
    SYNTAX
  },

  print: {
    default: '\\n\\n\\n\\n',
    syntax: "$delimiter",
    examples: <<~EXAMPLES,
      # select all entries and print them without a delimiter
      yorn foo -q @ -p ''
    EXAMPLES
  },

  print_path: {
    default: '\\n',
    short: :P,
    syntax: "$delimiter",
    examples: <<~EXAMPLES,
      # select last 3 entries and print paths"
      # --print-path not needed as its default action"
      yorn foo -l 3 --print-path
    EXAMPLES
  },
}
