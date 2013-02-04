class YouTrackSprintlyUtils
  def self.get_youtrack_login(sprintly_user)
    return nil if sprintly_user.nil?
    puts "Getting youtrack login for sprintly user: '#{sprintly_user}'"
    "#{sprintly_user['first_name'][0]}#{sprintly_user['last_name']}".downcase
  end

  def self.get_youtrack_issue_type(sprintly_issue)
    sprintly_type = sprintly_issue['type']
    case sprintly_type
      when "story"
        "Feature"
      when "defect"
        "Bug"
      when "task"
        "Task"
      when "test"
        "Test"
      else
        raise "Unrecognized sprintly issue type: '#{sprintly_type}'"
    end
  end

  def self.get_youtrack_status(sprintly_issue)
    sprintly_status = sprintly_issue['status']
    case sprintly_status
      when "someday"
        "Submitted"
      when "backlog"
        "Backlog"
      when "in-progress"
        "In Progress"
      when "completed"
        "Fixed"
      when "accepted"
        "Verified"
      else
        raise "Unrecognized sprintly issue status: '#{sprintly_status}'"
    end
  end

  def self.get_youtrack_estimation(sprintly_size)
    case sprintly_size
      when "S"
        "3h"
      when "M"
        "3d"
      when "L"
        "1w"
      when "XL"
        "2w"
      when "~"
        nil
      else
        raise "Unrecognized sprintly issue size: '#{sprintly_size}'"
    end
  end

  def self.get_youtrack_comment(sprintly_comment)
    puts "CONVERTING COMMENT TO YOUTRACK: '#{sprintly_comment}'"
    { :body       => sprintly_comment['body'],
      :created_by => get_youtrack_login(sprintly_comment['created_by'])
    }
  end


end