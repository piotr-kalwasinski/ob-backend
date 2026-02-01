// Delete team_stat record.
query "team_stat/{team_stat_id}" verb=DELETE {
  api_group = "Annotations"

  input {
    uuid team_stat_id?
  }

  stack {
    db.del team_stat {
      field_name = "id"
      field_value = $input.team_stat_id
    }
  }

  response = null
}