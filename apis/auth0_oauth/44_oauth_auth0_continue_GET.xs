query "oauth/auth0/continue" verb=GET {
  api_group = "auth0-oauth"

  input {
    text code? filters=trim
    text redirect_uri? filters=trim
  }

  stack {
    api.request {
      url = "https://id.speakleash.org.pl/auth/realms/SpeakLeash/protocol/openid-connect/token"|sprintf:$env.auth0_domain
      method = "POST"
      params = {}
        |set:"grant_type":"authorization_code"
        |set:"client_id":$env.auth0_clientid
        |set:"client_secret":$env.auth0_clientsecret
        |set:"code":$input.code
        |set:"redirect_uri":"https://xe7h-ziuu-timf.n7e.xano.io/api:zszBAomk/oauth/auth0/continue"
        |set:"code_verifier":"pLmhFCPp66I2ywZx.ff~-TTJEQ_Ost-z92ps_i_pHFdWYr2YWm"
      headers = []
        |push:"content-type: application/x-www-form-urlencoded"
      verify_host = false
      verify_peer = false
    } as $api_1
  
    precondition ($api_1.response.status == 200) {
      error = "Access Denied"
      payload = $api_1
    }
  
    debug.log {
      value = $api_1
    }
  
    api.request {
      url = "https://id.speakleash.org.pl/auth/realms/SpeakLeash/protocol/openid-connect/certs"|sprintf:$env.auth0_domain
      method = "GET"
      verify_host = false
      verify_peer = false
    } as $jwks
  
    var $jwt_key {
      value = $jwks.response.result.keys|first
    }
  
    security.jws_decode {
      token = $api_1.response.result.id_token
      key = $jwt_key
      check_claims = {}
      signature_algorithm = "RS256"
      timeDrift = 0
    } as $crypto_1
  
    precondition ($crypto_1.iss == $env.auth0_issuer) {
      error_type = "accessdenied"
      error = "Incorrect issuer"
    }
  
    precondition ($crypto_1.azp == $env.auth0_clientid) {
      error_type = "accessdenied"
      error = "Incorrect issuer"
    }
  
    var $x1_name {
      value = $crypto_1.name|sprintf
    }
  
    var $x1_sub {
      value = $crypto_1.sub|sprintf
    }
  
    var $x1_email {
      value = $crypto_1.email|sprintf
    }
  
    db.add login_history {
      data = {created_at: "now", auth: $crypto_1, sub: $x1_sub}
    } as $login_history1
  
    db.get user {
      field_name = "auth_sub"
      field_value = $x1_sub
    } as $user
  
    !db.get user {
      field_name = "id"
      field_value = "a6ebf1da-3769-4024-ad74-1a60843aa895"
    } as $user
  
    conditional {
      if ($user == null) {
        !db.add_or_edit user {
          field_name = "auth_sub"
          field_value = $x1_sub
          data = {}
        } as $user1
      
        db.add user {
          data = {
            created_at                  : "now"
            name                        : $x1_name
            email                       : $x1_email
            password                    : "Ydxgsadsahjdbvckahsbcu1"
            name_or_pseudonym           : null
            auth_provider               : $env.auth0_issuer
            registration_date           : now
            last_login                  : now
            privacy_policy_accepted_date: now
            team_id                     : null
            user_type                   : "REGULAR"
            status                      : "ACTIVE"
            auth_sub                    : $x1_sub
          }
        } as $user1
      }
    }
  
    security.create_auth_token {
      table = "user"
      extras = ""
      expiration = 604800
      id = "a6ebf1da-3769-4024-ad74-1a60843aa895"
    } as $token
  
    util.set_header {
      value = "Access-Control-Allow-Origin:"
        |concat:"http://localhost:64957":""
      duplicates = "replace"
    }
  
    util.set_header {
      value = "Access-Control-Allow-Methods:"|concat:"GET, POST, OPTIONS":""
      duplicates = "replace"
    }
  
    util.set_header {
      value = "Access-Control-Allow-Headers:"
        |concat:"Content-Type, Authorization":""
      duplicates = "replace"
    }
  
    util.set_header {
      value = "Authorization: Bearer "|concat:$token:""
      duplicates = "replace"
    }
  
    util.set_header {
      value = "https://obywatel-bielik-dev.web.app/onboarding/policy"
      duplicates = "replace"
    }
  }

  response = {!name: $user.name, token: $token}
}