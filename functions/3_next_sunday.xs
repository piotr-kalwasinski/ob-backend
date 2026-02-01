// Funkcja zwracająca datę najbliższej niedzieli
function next_sunday {
  input {
    timestamp current_time
  }

  stack {
    // Pobieramy dzień tygodnia z timestampa (0=niedziela, 1=poniedziałek, ..., 6=sobota)
    // Niestety XanoScript używa innej konwencji gdzie niedziela = 7
    var $day_of_week {
      value = $input.current_time|format_timestamp:"U"
    }
  
    // Obliczamy ile dni do niedzieli
    // Jeśli dzisiaj jest niedziela (7), to najbliższa niedziela to za 7 dni
    // Jeśli dzisiaj jest inny dzień, to dni_do_niedzieli = 7 - day_of_week
    var $days_to_add {
      value = ```
          $day_of_week == 7 
          ? 7 
          : (7 - $day_of_week|to_int)
        ```
    }
  
    // Dodajemy odpowiednią liczbę dni do aktualnego timestampa
    var $next_sunday_timestamp {
      value = $input.current_time
        |transform_timestamp:("+"
          |concat:$days_to_add
          |concat:" days"
        ):"UTC"
    }
  
    // Formatujemy wynik na czytelną datę (opcjonalnie)
    var $formatted_sunday {
      value = $next_sunday_timestamp|format_timestamp:"Y-m-d"
    }
  }

  response = $formatted_sunday
}