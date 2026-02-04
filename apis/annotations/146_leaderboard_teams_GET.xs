// Get a leaderboard of annotated images
query "leaderboard/teams" verb=GET {
  api_group = "Annotations"

  input {
  }

  stack {
    db.query user {
      join = {
        user_stat: {
          table: "user_stat"
          where: $db.user.id == $db.user_stat.user_id
        }
        team     : {table: "team", where: $db.user.team_id == $db.team.id}
      }
    
      sort = {total_photo_desribed: "desc", total_photos_added: "desc"}
      eval = {
        total_photos_desc : $db.user_stat.total_photos_described
        total_photos_added: $db.user_stat.total_photos_uploaded
        team_name         : $db.team.name
      }
    
      return = {
        type : "aggregate"
        group: {team: $db.team_name}
        eval : {
          total_photo_desribed: $db.total_photos_desc|sum
          total_photos_added  : $db.total_photos_added|sum
        }
      }
    } as $team_leaderboard
  
    db.query team_stat {
      join = {
        team: {
          table: "team"
          type : "left"
          where: $db.team_stat.team_id == $db.team.id
        }
      }
    
      sort = {team_stat.total_photos_annoted: "desc"}
      eval = {team: $db.team.name}
      return = {type: "list"}
      output = ["total_photos_annoted", "total_photos_added", "team"]
    } as $team_stat1
  }

  response = $team_stat1
}