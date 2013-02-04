require './sprintly_client'

sprintly = SprintlyClient.new

items = []

["someday", "backlog", "in-progress", "completed", "accepted"].each do |status|
  puts "Getting items for status '#{status}'"
  items_for_status = sprintly.get_items(status)
  puts "Got #{items_for_status.count} items"
  items.concat(items_for_status)
end

puts "#{items.count} total items:"
items.each do |i|
  puts "#{i["number"]}:#{i["type"]}:#{i["status"]}: #{i["title"]}"
end

puts ""

people = sprintly.get_users
puts "#{people.count} total people:"
puts JSON.pretty_generate(people)