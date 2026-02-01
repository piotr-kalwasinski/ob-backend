// Zwraca wszystkie dostepne kategorie
query category verb=GET {
  api_group = "Annotations"

  input {
  }

  stack {
    db.query category {
      return = {type: "list"}
    } as $category1
  }

  response = $category1
}