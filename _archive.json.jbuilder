json.archives countable.archive_count(filters) do |count|
  json.year count.year
  json.month count.month
  json.total count.total
end
