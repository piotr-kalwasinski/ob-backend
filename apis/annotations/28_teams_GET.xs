// Query all team records
query teams verb=GET {
  api_group = "Annotations"

  input {
  }

  stack {
    db.query team {
      eval = {uuid: $db.team.id}
      return = {type: "list"}
      output = ["name", "uuid"]
    } as $teams
  }

  response = $teams
}