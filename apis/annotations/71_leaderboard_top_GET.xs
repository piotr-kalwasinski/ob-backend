// Get a top 3 users of the leaderboard
query leaderboard_top verb=GET {
  api_group = "Annotations"

  input {
  }

  stack {
    var $top_3 {
      value = []
    }
  
    api.request {
      url = "https://xe7h-ziuu-timf.n7e.xano.io/api:DjZ_rwGx/leaderboard"
      method = "GET"
      timeout = 5
    } as $response
  
    var $leaderboard {
      value = $var.response.response.result
    }
  
    object.entries {
      value = $leaderboard.leaderboard
    } as $leaderboard_entries
  
    for (3) {
      each as $index {
        array.find ($leaderboard_entries) if ($this.key == $var.index) as $top
        array.shift $leaderboard_entries
        array.push $top_3 {
          value = $top
        }
      }
    }
  }

  response = $top_3
}