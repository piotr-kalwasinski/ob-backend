query "oauth/auth0/init" verb=GET {
  api_group = "auth0-oauth"

  input {
    // https://x8ki-letl-twmt.n7.xano.io/api:zszBAomk/oauth/auth0/continue
    text redirect_uri? filters=trim
  }

  stack {
    var $authorization_url {
      value = "https://id.speakleash.org.pl/auth/realms/SpeakLeash/protocol/openid-connect/auth?"
        |sprintf:$env.auth0_domain
        |url_addarg:"response_type":"code":false
        |url_addarg:"client_id":$env.auth0_clientid:false
        |url_addarg:"redirect_uri":"https://x8ki-letl-twmt.n7.xano.io/api:zszBAomk/oauth/auth0/continue":false
        |url_addarg:"scope":"openid profile email":false
        |url_addarg:"code_challenge_method":"S256":false
        |url_addarg:"code_challenge":"SUcuziNhAE9FWqfbWTvr2WL6_OwEoOg_nzqOq3wZofM":false
    }
  
    !util.set_header {
      value = "Location: "|concat:$authorization_url:""
      duplicates = "replace"
    }
  }

  response = {authUrl: $authorization_url}
}