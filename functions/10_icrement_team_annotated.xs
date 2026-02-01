// Dodaj +1 do wyniku zespolu
function icrement_team_annotated {
  input {
    uuid? user_id?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $input.user_id
    } as $user1
  
    conditional {
      if ($user1.team_id != null) {
        db.get team_stat {
          field_name = "team_id"
          field_value = $user1.team_id
        } as $team_stat1
      
        conditional {
          if ($team_stat1 != null) {
            var $x1 {
              value = $team_stat1.total_photos_annoted + 1
            }
          
            db.edit team_stat {
              field_name = "id"
              field_value = $team_stat1.id
              data = {total_photos_annoted: $x1}
            } as $team_stat3
          }
        
          else {
            db.add team_stat {
              data = {
                created_at          : "now"
                team_id             : $user1.team_id
                total_photos_annoted: 1
                total_photos_added  : 0
              }
            } as $team_stat2
          }
        }
      }
    }
  }

  response = "OK"
}