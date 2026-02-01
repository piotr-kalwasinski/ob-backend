// Get team record
query "teams/{id}" verb=GET {
  api_group = "Annotations"

  input {
    uuid team_id?
  }

  stack {
    db.get team {
      field_name = "id"
      field_value = $input.team_id
    } as $team
  
    precondition ($team != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $team
}