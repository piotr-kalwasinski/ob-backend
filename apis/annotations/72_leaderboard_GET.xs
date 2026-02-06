// Get a leaderboard of annotated images
query leaderboard verb=GET {
  api_group = "Annotations"

  input {
  }

  stack {
    db.query user_stat {
      join = {
        user: {table: "user", where: $db.user_stat.user_id == $db.user.id}
      }
    
      where = $db.user.name_or_pseudonym != ""
      sort = {user_stat.total_photos_described: "desc"}
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "consecutive_days"
        "total_photos_described"
        "total_photos_uploaded"
        "max_weekly_photos"
        "last_activity_date"
        "weekly_goal_record"
      ]
    
      addon = [
        {
          name  : "user"
          output: ["name", "name_or_pseudonym"]
          input : {user_id: $output.user_id}
          as    : "_user"
        }
      ]
    } as $user_stat1
  }

  response = {leaderboard: $user_stat1}
}