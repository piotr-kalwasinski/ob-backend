// Get achievement record
query "achievements/{id}" verb=GET {
  api_group = "Achievements"

  input {
    uuid achievements_id?
  }

  stack {
    db.get achievement {
      field_name = "id"
      field_value = $input.achievements_id
    } as $achievement
  
    precondition ($achievement != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $achievement
}