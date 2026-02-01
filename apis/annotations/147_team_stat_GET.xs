// Statystyki odnosnie zespolu
query team_stat verb=GET {
  api_group = "Annotations"

  input {
  }

  stack {
    db.query team_stat {
      sort = {team_stat.total_photos_annoted: "desc"}
      return = {type: "list"}
    } as $team_stat1
  }

  response = $team_stat1
}