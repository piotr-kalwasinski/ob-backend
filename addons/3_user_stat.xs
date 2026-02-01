addon user_stat {
  input {
    uuid user_id? {
      table = "user"
    }
  }

  stack {
    db.query user_stat {
      where = $db.user_stat.user_id == $input.user_id
      return = {type: "single"}
    }
  }
}