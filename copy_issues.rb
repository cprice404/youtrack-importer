require './sprintly_client'
require './youtrack_client'
require './youtrack_sprintly_utils'

class IssueCopier
  def initialize()
    @sprintly = SprintlyClient.new
    @youtrack = YouTrackClient.new

    @youtrack_id_map = {}
  end


  def add_issue(i)
    sprintly_id = i['number']
    if @youtrack_id_map.has_key?(sprintly_id)
      puts "Skipping previously added sprintly issue #{sprintly_id}"
      return @youtrack_id_map[sprintly_id]
    end

    puts "Adding Sprint.ly issue #{sprintly_id}"
    description = "Imported from sprint.ly issue [##{sprintly_id}|https://sprint.ly/product/7841/#!/item/#{sprintly_id}]\n\n" +
        i['description']

    comments = @sprintly.get_comments(sprintly_id).map { |c| YouTrackSprintlyUtils.get_youtrack_comment(c) }

    issue_id = @youtrack.add_issue("PE",
                                  YouTrackSprintlyUtils.get_youtrack_issue_type(i),
                                  YouTrackSprintlyUtils.get_youtrack_status(i),
                                  i['title'],
                                  description,
                                  { :assigned_to => YouTrackSprintlyUtils.get_youtrack_login(i['assigned_to']),
                                    :created_by  => YouTrackSprintlyUtils.get_youtrack_login(i['created_by']),
                                    :estimation  => YouTrackSprintlyUtils.get_youtrack_estimation(i['score']),
                                    :comments    => comments,
                                    :tags        => i['tags']
                                  })

    @youtrack_id_map[sprintly_id] = issue_id

    if (i.has_key?('parent'))
      sprintly_parent_id = i['parent']['number']
      add_issue(i['parent'])
      youtrack_id = @youtrack_id_map[sprintly_id]
      youtrack_parent_id = @youtrack_id_map[sprintly_parent_id]
      puts "Linking issue #{youtrack_id} (sprintly #{sprintly_id}) to parent: #{youtrack_parent_id} (sprintly #{sprintly_parent_id})"
      @youtrack.set_parent_issue(youtrack_id, youtrack_parent_id)
    end

    issue_id
  end

  def copy_issues()
    issues = @sprintly.get_issues

    # hack to prevent adding all of the issues for now
    #issues = [issues[0]]
    #issues = issues[0..5]

    issues.each do |i|
      issue_id = add_issue(i)
    end
  end

end

copier = IssueCopier.new
copier.copy_issues

