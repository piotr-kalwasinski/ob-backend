table user {
  auth = true

  schema {
    uuid id
    timestamp created_at?=now
    text name filters=trim
    email? email filters=trim|lower
    password? password filters=min:8|minAlpha:1|minDigit:1
    text name_or_pseudonym?
    text auth_provider?
    timestamp registration_date?
    timestamp last_login?
    timestamp privacy_policy_accepted_date?
    uuid? team_id? {
      table = "team"
    }
  
    enum user_type?=REGULAR {
      values = ["REGULAR", "MODERATOR"]
    }
  
    enum status?=ACTIVE {
      values = ["ACTIVE", "DELETED"]
    }
  
    uuid? auth_sub?
    bool privacy_consent?
    bool service_consent?
    text avatar_path? filters=trim
  
    // czy user widoczny w leaderboard
    bool leaderbord_visible?=true
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "auth_sub", op: "desc"}]}
    {type: "btree|unique", field: [{name: "email", op: "asc"}]}
    {type: "gin", field: [{name: "xdo", op: "jsonb_path_op"}]}
  ]
}