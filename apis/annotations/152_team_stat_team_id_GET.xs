// Get team_stat record
query "team_stat/{team_id}" verb=GET {
  api_group = "Annotations"

  input {
    uuid team_id
  }

  stack {
    // 1. Pobierz statystyki konkretnego zespołu
    db.get team_stat {
      field_name = "team_id"
      field_value = $input.team_id
    } as $current_team
  
    // 2. Pobierz listę wszystkich statystyk posortowaną malejąco po zdjęciach
    db.query team_stat {
      sort = {team_stat.total_photos_annoted: "desc"}
      return = {type: "list"}
    } as $all_teams
  
    // 3. Znajdź pozycję (indeks) Twojego zespołu
    // W Xano find_index zwraca 0 dla pierwszego miejsca, więc ranking = index + 1
    array.find_index ($all_teams) if ($this.team_id == $input.team_id) as $my_index
  
    // 4. Oblicz dane rankingowe
    var $rank {
      value = $my_index + 1
    }
  
    conditional {
      if ($my_index > 0) {
        var $team_above {
          value = $all_teams[$my_index - 1]
        }
      
        var $photos_to_next {
          value = $team_above.total_photos_annoted - $current_team.total_photos_annoted + 1
        }
      }
    
      else {
        // 5. Oblicz ile brakuje do następnej pozycji
        var $photos_to_next {
          value = 0
        }
      }
    }
  
    db.get team {
      field_name = "id"
      field_value = $input.team_id
    } as $team1
  }

  response = {
    total_photos_annoted: $current_team.total_photos_annoted
    total_photos_added  : $current_team.total_photos_added
    rank_position       : $rank
    missing_to_next     : $photos_to_next
    team_id             : $input.team_id
    team_name           : $team1.name
  }
}