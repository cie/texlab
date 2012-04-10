# table generation
#

def table title, settings={}
  @_table = {}
  yield
  entries = @_table

  unless @_tables
    $_latexfile.table(entries, title, settings)
  else
    @_tables << [entries, title, settings]
  end
end

def column title
  @_table_columns << (@_table_columns.last[title] || {})

  result = (yield if block_given?)
  subcolumns = @_table_columns.pop

  if not subcolumns.empty?
    @_table_columns.last[title] = subcolumns
  elsif result
    if @_table_columns.last[title]
      @_table_columns.last[title] = *@_table_columns.last[title], *result
    else
      @_table_columns.last[title] = *result
    end
  else
    @_table_columns.last[title] ||= nil
  end

end

def row title
  @_table_columns = [@_table[title] || {}]
  yield
  @_table[title] = @_table_columns.first
end

def tables *args
  opts = args.extract_options!
  caption = args.shift

  @_tables = []
  yield

  $_latexfile.tables(@_tables, caption, opts)

  @_tables = nil
end


