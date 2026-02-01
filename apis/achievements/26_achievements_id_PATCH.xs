// Edit achievement record
query "achievements/{id}" verb=PATCH {
  api_group = "Achievements"
  auth = "user"

  input {
    uuid achievements_id?
    dblink {
      table = "achievement"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch achievement {
      field_name = "id"
      field_value = $input.achievement_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $achievement
  }

  response = $achievement
}