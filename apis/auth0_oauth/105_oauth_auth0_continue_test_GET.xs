query "oauth/auth0/continue/test" verb=GET {
  api_group = "auth0-oauth"

  input {
    text code? filters=trim
    text state? filters=trim
  }

  stack {
    var $redirect_url {
      value = "https://obywatel-bielik.web.app/auth"
        |concat:"?code=":$input.code:"&state=":$input.state
    }
  
    util.set_header {
      value = "Location: "|concat:$redirect_url:""
      duplicates = "replace"
    }
  }

  response = null
}