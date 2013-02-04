require './youtrack_client'

youtrack = YouTrackClient.new

youtrack.delete_all_issues("PE")
