// Funkcja zwracająca datę poniedziałku bieżącego tygodnia
// Obsługuje timestampy z dowolnym timezone
function get_monday {
  input {
    timestamp current_time
    text timezone?
  }

  stack {
    // Ustawiamy domyślny timezone jeśli nie podano
    var $tz {
      value = ```
          $input.timezone == null 
          ? "UTC" 
          : $input.timezone
        ```
    }
  
    // Pobieramy dzień tygodnia z timestampa w odpowiednim timezone
    // Format "N" zwraca: 1=poniedziałek, 2=wtorek, ..., 7=niedziela
    var $day_of_week {
      value = $input.current_time|format_timestamp:"N":$tz
    }
  
    // Obliczamy ile dni cofnąć do poniedziałku
    // Jeśli dzisiaj jest poniedziałek (1), to cofamy 0 dni
    // Jeśli dzisiaj jest wtorek (2), to cofamy 1 dzień
    // Jeśli dzisiaj jest niedziela (7), to cofamy 6 dni
    var $days_to_subtract {
      value = ```
          $day_of_week == "1" 
          ? 0 
          : (($day_of_week|to_int) - 1)
        ```
    }
  
    // Tworzymy string transformacji (np. "-3 days")
    var $transform_string {
      value = ```
          $days_to_subtract == 0
          ? "+0 days"
          : ("-"|concat:$days_to_subtract|concat:" days")
        ```
    }
  
    // Odejmujemy odpowiednią liczbę dni od timestampa
    var $this_monday_timestamp {
      value = $input.current_time
        |transform_timestamp:$transform_string:$tz
    }
  
    // Formatujemy wynik na początku dnia (00:00:00)
    // Używamy transform_timestamp z "midnight" aby ustawić na początek dnia
    var $monday_start_of_day {
      value = $this_monday_timestamp
        |transform_timestamp:"midnight":$tz
    }
  
    // Formatujemy wynik na czytelną datę
    var $formatted_monday {
      value = $monday_start_of_day|format_timestamp:"Y-m-d":$tz
    }
  
    // Formatujemy pełną datę z godziną
    var $formatted_monday_full {
      value = $monday_start_of_day
        |format_timestamp:"Y-m-d H:i:s":$tz
    }
  }

  response = $formatted_monday
}