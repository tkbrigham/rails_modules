#  Groups by 'created_at' field, unless value is passed to :group_by key.
#  Can also filter by any additional fields for the model (ie 'online: true').
#  All arguments, including :group_by, should be passed in as a single hash.

module ArchiveCountable
  def archive_count(args = {})
    cleanse!(args)
    group = grouped_relation(args)
    collect_counts(group)
  end
  
  private

  # Converts all keys to strings, and all boolean-as-string values to boolean.
  # Prefers a string key if both a string and a symbol key exist with same name.
  def cleanse!(args)
    args.tap do |a|
      a.each { |k,v| a[k] = str_to_bool(v) }
      symbol_keys = a.keys.select { |k| k.is_a?(Symbol) && !a.has_key?(k.to_s) }
      symbol_keys.each { |k| a[k.to_s] = a[k] }
      a.delete_if { |k,_| k.is_a?(Symbol) }
    end
  end

  def str_to_bool(string)
    return true if string == "true"
    return false if string == "false"
    string
  end

  def grouped_relation(args)
    group_field = args.delete('group_by') || 'created_at'
    self.where(args).where("#{group_field} <= ?", Date.today).
      group("year(#{group_field})").group("month(#{group_field})").
      order("year(#{group_field}) desc, month(#{group_field}) desc")
  end

  def collect_counts(relation)
    relation.count.collect do |array|
      array.flatten!
      YearAndMonthTotal.new(array[0], array[1], array[2])
    end
  end

  YearAndMonthTotal = Struct.new(:year, :month, :total)
end
