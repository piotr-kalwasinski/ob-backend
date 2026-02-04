// Get a leaderboard of annotated images
query "leaderboard/teams" verb=GET {
  api_group = "Annotations"

  input {
  }

  stack {
    db.query team_stat {
      join = {
        team: {
          table: "team"
          type : "left"
          where: $db.team_stat.team_id == $db.team.id
        }
      }
    
      sort = {team_stat.total_photos_annoted: "desc"}
      eval = {
        team                : $db.team.name
        total_photo_desribed: $db.team_stat.total_photos_annoted
        total_photo_added   : $db.team_stat.total_photos_added
      }
    
      return = {type: "list"}
      output = ["total_photos_added", "team", "total_photo_desribed"]
    } as $team_leaderboard
  }

  response = $team_leaderboard
}