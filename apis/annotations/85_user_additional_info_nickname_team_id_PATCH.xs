query "user_additional_info/{nickname}/{team_id}" verb=PATCH {
  api_group = "Annotations"
  auth = "user"

  input {
    uuid user_id
    text nickname? filters=trim
    uuid? team_id?
  }

  stack {
    db.edit user {
      field_name = "id"
      field_value = $input.user_id
      data = {
        name_or_pseudonym: $input.nickname
        team_id          : $input.team_id
      }
    } as $updated_user
  }

  response = {}
}