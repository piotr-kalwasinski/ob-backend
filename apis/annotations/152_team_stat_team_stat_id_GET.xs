// Get team_stat record
query "team_stat/{team_stat_id}" verb=GET {
  api_group = "Annotations"

  input {
    uuid team_stat_id?
  }

  stack {
    db.get team_stat {
      field_name = "id"
      field_value = $input.team_stat_id
    } as $team_stat
  
    precondition ($team_stat != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $team_stat
}