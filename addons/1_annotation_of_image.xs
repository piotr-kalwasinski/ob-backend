addon annotation_of_image {
  input {
    uuid image_id? {
      table = "image"
    }
  }

  stack {
    db.query annotation {
      where = $db.annotation.image_id == $input.image_id
      return = {type: "single"}
    }
  }
}