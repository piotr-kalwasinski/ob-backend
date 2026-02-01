// Delete team record.
query "teams/{id}" verb=DELETE {
  api_group = "Annotations"

  input {
    uuid team_id?
  }

  stack {
    db.del team {
      field_name = "id"
      field_value = $input.team_id
    }
  }

  response = null
}