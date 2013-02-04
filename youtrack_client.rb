require 'httpclient'
require 'ox'
require 'uri'

class YouTrackClient
  def initialize
    @http = HTTPClient.new

    @url_prefix = "http://explosivo:8080/rest"

    login(@http, "root", "puppet")
  end

  def add_user(login, fullName, email, password)
    puts "Adding user '#{login}'"
    request(@http, :put, "admin/user/#{URI.escape(login)}",
            { :fullName => fullName,
              :email    => email,
              :password => password })
  end

  def add_user_to_group(login, group_name)
    puts "Adding user '#{login}' to group '#{group_name}'"
    request(@http, :post, "admin/user/#{URI.escape(login)}/group/#{URI.escape(group_name)}")
  end

  def add_issue(project, type, status, summary, description, extras = {})
    estimation  = extras[:estimation]
    created_by  = extras[:created_by]
    assigned_to = extras[:assigned_to]
    comments    = extras[:comments]
    tags        = extras[:tags]

    puts "Adding issue (#{type}|#{status}) '#{summary}' to project '#{project}'"

    http = @http
    if (created_by)
      http = HTTPClient.new
      login(http, created_by, "puppet")
    end
    result = request(http, :put, 'issue',
            { :project     => project,
              :summary     => summary,
              :description => description })

    location = result.header['Location'][0]
    issue_id = File.basename(location)
    execute_command(issue_id, "type #{type} state #{status}")

    if (assigned_to)
      execute_command(issue_id, "Assignee #{assigned_to}")
    end

    if (estimation)
      execute_command(issue_id, "Estimation #{estimation}")
    end

    if (comments)
      comments.each do |comment|
        puts "Adding comment: '#{comment[:body]}'"
        execute_command(issue_id, "comment", comment[:body], comment[:created_by])
      end
    end

    if (tags)
      tags.each do |tag|
        puts "Adding tag: '#{tag}'"
        execute_command(issue_id, "add tag #{tag}")
      end
    end

    issue_id
  end

  def set_parent_issue(issue_id, parent_issue_id)
    execute_command(issue_id, "subtask of #{parent_issue_id}")
  end

  def execute_command(issue_id, command, comment = nil, run_as = 'root')
    request(@http, :post, "issue/#{URI.escape(issue_id)}/execute",
            { :command => command,
              :comment => comment,
              :runAs   => run_as })
  end

  def delete_all_issues(project)
    result = request(@http, :get, "issue/byproject/#{URI.escape(project)}",
                     { :max => 1000 })
    doc = Ox.parse(result.content)
    issues = doc.locate("issues/issue")

    issues.each do |i|
      puts "DELETING ISSUE '#{i['id']}'"
      result = request(@http, :delete, "issue/#{i['id']}")
    end
  end

  private

  def login(httpclient, username, password)
    request(httpclient, :post, 'user/login',
            { :login    => username,
              :password => password})
  end

  def request(httpclient, method, path, params = {})
    puts "Making request to '#{path}'"
    result = httpclient.send(method, "#{@url_prefix}/#{path}", params)
    puts "result: (#{result.status}) #{result.content}"
    result
  end

end