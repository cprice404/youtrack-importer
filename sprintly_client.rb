require 'net/https'
require 'uri'
require 'json'
require 'fileutils'
require 'uri'

class SprintlyClient

  def initialize(cache_to_files = true)
    @cache_to_files = cache_to_files
    @config = JSON.parse(File.new("sprintly.conf").read)
  end

  def get_issues()
    items = []

    #["someday", "backlog", "in-progress", "completed", "accepted"].each do |status|
    ["backlog", "in-progress", "completed", "accepted", "someday"].each do |status|
      puts "Getting items for status '#{status}'"
      items_for_status = get_items(status)
      puts "Got #{items_for_status.count} items"
      items.concat(items_for_status)
    end

    puts "#{items.count} total items."
    items
  end

  def get_items(status)
    offset = 0
    items = []
    begin
      next_items = query("items.json?status=#{URI.escape(status)}&children=true&limit=100&offset=#{offset}")
      items.concat(next_items)
      offset += 100
    end while next_items.count == 100
    items
  end

  def get_comments(issue_number)
    comments = query("items/#{URI.escape(issue_number.to_s)}/comments.json")
    puts "Found #{comments.length} comments for issue #{issue_number}"
    comments
  end

  def get_users()
    query("people.json")
  end

  private

  def query(endpoint)
    filename = File.join(".", "data", "sprintly", endpoint.gsub(/[^\w]/, '_') + ".json")

    if (@cache_to_files)
      FileUtils.mkdir_p(File.dirname(filename))
      if (File.exists?(filename))
        puts "Reading data from cached file '#{filename}'"
        return JSON.parse(File.new(filename, "r").read)
      end
    end

    puts "Retrieving data from sprint.ly (#{endpoint})"
    uri = URI.parse("https://sprint.ly/api/products/7841/#{endpoint}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(@config['u'], @config['p'])

    response = http.request(request)

    if (@cache_to_files)
      File.open(filename, "w") { |f| f.write(response.body) }
    end

    JSON.parse(response.body)
  end
end

