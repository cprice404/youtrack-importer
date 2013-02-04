require './sprintly_client'
require './youtrack_client'
require './youtrack_sprintly_utils'

sprintly = SprintlyClient.new
users = sprintly.get_users

# Sprintly users look like this:
#{
#    "first_name": "Joe",
#    "last_name": "Blow",
#    "revoked": false,
#    "admin": false,
#    "email": "joeblow@puppetlabs.com",
#    "id": 346
#}

# hack to prevent adding all of the users for now
#users = [users[0]]

youtrack = YouTrackClient.new
users.each do |u|
  login = YouTrackSprintlyUtils.get_youtrack_login(u)
  if (u['revoked'])
    puts "Skipping revoked user account '#{login}'"
    next
  end

  fullName = "#{u['first_name']} #{u['last_name']}"
  email    = u['email']
  password = 'puppet'
  youtrack.add_user(login, fullName, email, password)

  youtrack.add_user_to_group(login, "PE Devs")

  if u['admin']
    youtrack.add_user_to_group(login, "PE Admins")
  end
end
