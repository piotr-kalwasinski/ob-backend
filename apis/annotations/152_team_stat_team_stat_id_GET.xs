// Get team_stat record
query "team_stat/{team_stat_id}" verb=GET {
  api_group = "Annotations"

  input {
    uuid team_id?
  }

  stack {
    db.get team_stat {
      field_name = "team_id"
      field_value = $input.team_id
    } as $team_stat
  
    precondition ($team_stat != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  
    db.query team_stat {
      sort = {team_stat.total_photos_annoted: "desc"}
      return = {type: "list"}
      output = ["team_id"]
    } as $team_stat1
  
    array.find_index ($team_stat1.id) if ($this == $input.team_id) as $x1
  }

  response = $team_stat
}