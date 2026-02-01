// Get an user record to leaderboard
query leaderboard_user verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
    uuid user_id
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $input.user_id
    } as $user
  
    var $score {
      value = ""
    }
  
    conditional {
      if ($user.name_or_pseudonym == null) {
        var.update $score {
          value = null
        }
      }
    
      else {
        db.get user_stat {
          field_name = "user_id"
          field_value = $user.id
        } as $user_stat
      
        var $keys {
          value = ["name", "annotations"]
        }
      
        var $values {
          value = [$user.name, $user_stat.total_photos_described]
        }
      
        var.update $score {
          value = $keys|create_object:$values
        }
      }
    }
  }

  response = {score: $score}
}