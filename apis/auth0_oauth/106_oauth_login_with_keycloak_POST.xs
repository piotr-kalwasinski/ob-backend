query "oauth/login-with-keycloak" verb=POST {
  api_group = "auth0-oauth"

  input {
    text keycloak_token filters=trim
  }

  stack {
    api.request {
      url = "https://id.speakleash.org.pl/auth/realms/SpeakLeash/protocol/openid-connect/certs"
      method = "GET"
    } as $jwks
  
    var $jwt_key {
      value = $jwks.response.result.keys|first
    }
  
    security.jws_decode {
      token = $input.keycloak_token
      key = $jwt_key
      signature_algorithm = "RS256"
    } as $decoded_token
  
    precondition ($decoded_token != null) {
      error = "Invalid or expired token"
    }
  
    db.get user {
      field_name = "auth_sub"
      field_value = $decoded_token.sub
    } as $user
  
    conditional {
      if ($user == null) {
        db.add user {
          data = {
            created_at       : "now"
            name             : ""
            email            : $decoded_token.email
            password         : "social_auth_managed_123"
            auth_provider    : "keycloak"
            registration_date: "now"
            last_login       : "now"
            status           : "ACTIVE"
            auth_sub         : $decoded_token.sub
            user_type        : "REGULAR"
          }
        } as $user
      }
    }
  
    security.create_auth_token {
      table = "user"
      extras = ""
      expiration = 604800
      id = $user.id
    } as $token
  }

  response = {name: $user.name, token: $token}
}