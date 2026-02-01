query weekly_goal verb=GET {
  api_group = "Achievements"

  input {
  }

  stack {
    db.query weekly_goal {
      return = {type: "list"}
    } as $weekly_goal1
  }

  response = $weekly_goal1
}