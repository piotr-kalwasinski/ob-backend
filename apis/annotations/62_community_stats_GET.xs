query community_stats verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    // Wszystkie dostepne opisy
    db.query annotation {
      return = {type: "count"}
    } as $annotation1
  
    db.query image {
      return = {type: "count"}
    } as $image1
  
    // Przelicz liczbe unikalnych opisanych zdjec 
    db.query annotation {
      where = $db.annotation.image_id not overlaps? ""
      return = {type: "count"}
      output = [
        "id"
        "created_at"
        "narrative_description"
        "factual_description"
        "auto_generated_description"
        "updated_at"
        "is_corrected"
        "verification_status"
        "image_id"
        "user_id"
        "verified_by_user_id"
      ]
    } as $annotation2
  
    var $x1 {
      value = $image1 - $annotation2
    }
  
    db.query annotation {
      where = $db.annotation.created_at >= $user1.last_login
      return = {type: "count"}
    } as $annotation3
  
    var $x3 {
      value = now|format_timestamp:"U":"UTC+1"
    }
  
    // Oblicz różnicę w dniach między now() a last_login
    var $x2 {
      value = ($x3*1000 - $user1.last_login) / 86400000
    }
  
    conditional {
      if ($x2 > 1) {
        db.edit user {
          field_name = "id"
          field_value = $auth.id
          data = {last_login: now}
        } as $user2
      }
    }
  }

  response = {
    num_desc        : $annotation1
    photo_to_desc   : $x1
    since_last_visit: $annotation3
  }

  tags = ["stat"]
}