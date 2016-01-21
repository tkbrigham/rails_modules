module ArchiveCountable
  def archive_count(args = {})
    group = grouped_relation(args)
    collect_counts(group)
  end
  
  private

  def grouped_relation(args)
    group_field = args.delete(:group_by) || 'created_at'
    self.where(args).
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
