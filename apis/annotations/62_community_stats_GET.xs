query community_stats verb=GET {
  api_group = "Annotations"
  auth = "user"

  input {
  }

  stack {
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
  }

  response = {num_desc: $annotation1, photo_to_desc: $x1}
  tags = ["stat"]
}