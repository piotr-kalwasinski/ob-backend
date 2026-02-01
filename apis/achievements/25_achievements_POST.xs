// Add achievement record
query achievements verb=POST {
  api_group = "Achievements"
  auth = "user"

  input {
    dblink {
      table = "achievement"
    }
  }

  stack {
    db.add achievement {
      data = {created_at: "now"}
    } as $achievement
  }

  response = $achievement
}