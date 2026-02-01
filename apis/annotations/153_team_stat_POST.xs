// Add team_stat record
query team_stat verb=POST {
  api_group = "Annotations"

  input {
    dblink {
      table = "team_stat"
    }
  }

  stack {
    db.add team_stat {
      data = {created_at: "now"}
    } as $team_stat
  }

  response = $team_stat
}