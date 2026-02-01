query user_weekly_goal verb=GET {
  api_group = "Achievements"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    precondition ($user1 != null) {
      error_type = "accessdenied"
    }
  
    db.query user_weekly_goal {
      where = $db.user_weekly_goal.user_id == $auth.id && $db.user_weekly_goal.start_of_week <= now && $db.user_weekly_goal.end_of_the_week >= now
      sort = {user_weekly_goal.end_of_the_week: "desc"}
      return = {type: "single"}
    } as $user_weekly_goal1
  
    var $current_timestamp {
      value = now
    }
  
    var $check_date {
      value = now
        |format_timestamp:"Y-m-d H:i:s":"UTC"
    }
  
    conditional {
      if ($user_weekly_goal1 == null) {
        function.run get_monday {
          input = {current_time: now, timezone: "UTC"}
        } as $monday
      
        function.run add_seven_days {
          input = {input_date: $monday}
        } as $sunday
      
        var $end_timestamp {
          value = ($sunday|concat:" 23:59:59")|parse_timestamp:"Y-m-d H:i:s":"UTC"
        }
      
        var $initial_goal {
          value = "f9c4d8b9-03a3-4ce5-b932-9bda9141c0fd"
        }
      
        var $num_of_photos {
          value = 0
        }
      
        var $target_photos {
          value = 0
        }
      
        var $missing_annotations {
          value = 5
        }
      
        var $procentage {
          value = 0
        }
      
        var $days_remaining {
          value = (($end_timestamp - $current_timestamp) / 86400000)|floor
        }
      
        var $goal_image {
          value = 5
        }
      
        var $motivational_message {
          value = "Świetny start! Przed Tobą cały tydzień na osiągnięcie celu 💪"
        }
      
        db.add user_weekly_goal {
          data = {
            created_at      : "now"
            start_date      : now
            photos_described: 0
            completed       : false
            user_id         : $auth.id
            weekly_goal_id  : $initial_goal
            start_of_week   : $monday
            end_of_the_week : $end_timestamp
          }
        } as $user_weekly_goal2
      }
    
      else {
        db.get weekly_goal {
          field_name = "id"
          field_value = $user_weekly_goal1.weekly_goal_id
        } as $weekly_goal1
      
        db.query annotation {
          where = $db.annotation.created_at >= $user_weekly_goal1.start_of_week && $db.annotation.created_at <= $user_weekly_goal1.end_of_the_week && $db.annotation.user_id == $auth.id
          return = {type: "count"}
        } as $annotation_count
      
        var $num_of_photos {
          value = $annotation_count
        }
      
        var $target_photos {
          value = $weekly_goal1.target_photos
        }
      
        var $missing_annotations {
          value = $target_photos - $num_of_photos
        }
      
        var $goal_image {
          value = $weekly_goal1.icon
        }
      
        var $end_timestamp {
          value = `$user_weekly_goal1.end_of_the_week`
        }
      
        var $days_remaining {
          value = (($end_timestamp - $current_timestamp) / 86400000)|floor
        }
      
        conditional {
          if ($target_photos == 0) {
            var $procentage {
              value = 0
            }
          }
        
          else {
            var $procentage {
              value = ($num_of_photos / $target_photos) * 100
            }
          }
        }
      
        conditional {
          if ($procentage < 33) {
            var $motivational_message {
              value = $weekly_goal1.motivation_message_start
            }
          }
        
          elseif ($procentage < 75) {
            var $motivational_message {
              value = $weekly_goal1.motivation_message_inprogress
            }
          }
        
          else {
            var $motivational_message {
              value = $weekly_goal1.motivation_message_nearcomplete
            }
          }
        }
      }
    }
  }

  response = {
    annoted             : $num_of_photos
    procentage          : $procentage
    goal                : $target_photos
    missing_annotations : $missing_annotations
    days_remaining      : $days_remaining
    goal_image          : $goal_image
    motivational_message: $motivational_message
  }
}