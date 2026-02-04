// Sprawdza czy miedzy ostatnim opisanym zdjeceim a teraz jest wiecej niz 1 dzien jesli tak zeruje rekord
function check_last_annotation {
  input {
    uuid? user_id?
  }

  stack {
    db.query annotation {
      where = $db.annotation.user_id == $input.user_id
      sort = {annotation.created_at: "desc"}
      return = {type: "single"}
    } as $annotation1
  
    var $teraz {
      value = now|format_timestamp:"U":"UTC"
    }
  
    var $x1 {
      value = ($var.teraz*1000 - $annotation1.created_at) / 86400000 | floor
    }
  
    conditional {
      if ($x1 > 1) {
        db.edit user_stat {
          field_name = "user_id"
          field_value = $input.user_id
          data = {annotation_streak_days: 0}
        } as $user_stat1
      }
    }
  }

  response = "OK"
}