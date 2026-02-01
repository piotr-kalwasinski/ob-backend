// Delete achievement record.
query "achievements/{id}" verb=DELETE {
  api_group = "Achievements"

  input {
    uuid achievements_id?
  }

  stack {
    db.del achievement {
      field_name = "id"
      field_value = $input.id
    }
  }

  response = null
}