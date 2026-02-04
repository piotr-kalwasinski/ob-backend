// Nazwa: increment_streak_days
// Opis: Zwiększa streak_count o 1, jeśli dzisiaj nie było jeszcze aktualizacji.
// Zwraca zaktualizowany rekord lub stary, jeśli nic nie zmieniono
function increment_streak_days {
  input {
    uuid user_id
  }

  stack {
    // 1. Pobierz rekord statystyk użytkownika
    db.get user_stat {
      field_name = "user_id"
      field_value = $input.user_id
    } as $user_stat
  
    // 2. Pobierz aktualny czas i sformatuj go do samej daty
    var $dzisiaj {
      value = now|format_timestamp:"Y-m-d"
    }
  
    var $ostatnia_aktualizacja {
      value = $user_stat.streak_update|format_timestamp:"Y-m-d"
    }
  
    conditional {
      if ($user_stat.annotation_streak_days == 0 && $dzisiaj == $ostatnia_aktualizacja) {
        db.edit user_stat {
          field_name = "user_id"
          field_value = $input.user_id
          data = {annotation_streak_days: 1, streak_update: now}
        } as $user_stat1
      }
    
      elseif ($dzisiaj != $ostatnia_aktualizacja) {
        db.edit user_stat {
          field_name = "user_id"
          field_value = $input.user_id
          data = {
            annotation_streak_days: $user_stat.annotation_streak_days +1
            streak_update         : now
          }
        } as $user_stat2
      }
    }
  }

  response = "OK"
}