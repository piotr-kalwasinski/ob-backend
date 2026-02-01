// Funkcja dodająca 7 dni do podanej daty i zwracająca jako string
function add_seven_days {
  input {
    timestamp input_date
  }

  stack {
    // Dodajemy 7 dni do podanego timestampa
    var $new_date {
      value = $input.input_date
        |transform_timestamp:"+6 days":"UTC"
    }
  
    // Formatujemy na string Y-m-d
    var $formatted_date {
      value = $new_date|format_timestamp:"Y-m-d"
    }
  }

  response = $formatted_date
}