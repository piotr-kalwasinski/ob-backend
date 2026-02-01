// Check if user exists in database
query users verb=GET {
  api_group = "Annotations"

  input {
    text nickname? filters=trim
  }

  stack {
    db.query user {
      where = $db.user.name_or_pseudonym == $input.nickname
      return = {type: "exists"}
    } as $isNickname
  
    conditional {
      if ($isNickname) {
        var $status {
          value = "EXISTING"
        }
      }
    
      else {
        var $status {
          value = "NOT_EXISTING"
        }
      }
    }
  }

  response = {status: $status, nickname: $input.nickname}
}