// Add team record
query teams verb=POST {
  api_group = "Annotations"

  input {
    dblink {
      table = "team"
    }
  }

  stack {
    db.add team {
      data = {created_at: "now"}
    } as $team
  }

  response = $team
}