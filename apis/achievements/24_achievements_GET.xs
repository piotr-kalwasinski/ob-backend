// Query all achievement records
query achievements verb=GET {
  api_group = "Achievements"

  input {
  }

  stack {
    db.query achievement {
      return = {type: "list"}
    } as $achievement
  }

  response = $achievement
}