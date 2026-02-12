// Get the user record belonging to the authentication token
query "auth/me" verb=GET {
  api_group = "Authentication"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = [
        "id"
        "created_at"
        "name"
        "email"
        "team_id"
        "status"
        "avatar_path"
        "leaderbord_visible"
      ]
    } as $user
  
    precondition ($user.status != "DELETED") {
      error_type = "accessdenied"
    }
  
    conditional {
      if ($user.team_id != null) {
        db.get team {
          field_name = "id"
          field_value = $user.team_id
          output = ["name"]
        } as $team
      }
    }
  
    function.run check_last_annotation {
      input = {user_id: $user.id}
    } as $func1
  }

  response = {
    id                : $user.id
    created_at        : $user.created_at
    name              : $user.name
    email             : $user.email
    teamName          : ($user.team_id != null ? $team.name : null)
    avatarUrl         : $user.avatar_path
    team_id           : $user.team_id
    leaderboardVisible: $user.leaderbord_visible
  }
}