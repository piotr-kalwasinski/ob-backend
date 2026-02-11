function getImagesFromAktywAkcja {
  input {
    // External API page number to start from
    int cursor?=1
  
    // How many unannotated images to collect
    int page_size?=10
  
    // Optional category UUID - if provided, filters by category_id in external API
    text category_uuid?
  
    // Safety limit on how many external API pages to fetch per request
    int max_iterations?=10
  
    // List of already-annotated external image IDs to exclude
    int[] annotation_ids
  }

  stack {
    // Initialize loop variables
    var $collected {
      value = []
    }
  
    var $current_page {
      value = $input.cursor
    }
  
    var $iterations {
      value = 0
    }
  
    var $has_more {
      value = true
    }
  
    // Optional category lookup
    var $category_bielik_id {
      value = null
    }
  
    conditional {
      if ($input.category_uuid != null) {
        db.get category {
          field_name = "id"
          field_value = $input.category_uuid
        } as $category_record
      
        var $category_bielik_id {
          value = $category_record.akty_bielik_id
        }
      }
    }
  
    // Fetch total image count from stats endpoint to calculate total pages
    api.request {
      url = "https://aktywakcja.bielik.ai/api/v2/stats"
      method = "GET"
      headers = []
        |push:("X-API-Key: "
          |concat:$env.aktywakcja_token_v2:""
        )
        |push:"Content-Type: application/json"
    } as $stats_response
  
    var $total_images {
      value = $stats_response.response.result.total_images
    }
  
    // ceil(total_images / page_size)
    var $total_pages {
      value = (($total_images + $input.page_size - 1) / $input.page_size)|floor
    }
  
    // Main pagination loop
    // Continues until we have enough images, hit max iterations, or run out of pages
    while (($collected|count) < $input.page_size && $iterations < $input.max_iterations && $has_more) {
      each {
        // Build request params
        var $request_params {
          value = {}
            |set:"page":$current_page
            |set:"per_page":$input.page_size
        }
      
        conditional {
          if ($category_bielik_id != null) {
            var $request_params {
              value = $request_params
                |set:"category_id":$category_bielik_id
            }
          }
        }
      
        // Call external API
        api.request {
          url = "https://aktywakcja.bielik.ai/api/v2/images"
          method = "GET"
          params = $request_params
          headers = []
            |push:("X-API-Key: "
              |concat:$env.aktywakcja_token_v2:""
            )
            |push:"Content-Type: application/json"
        } as $api_response
      
        // Extract images from response
        var $page_images {
          value = $api_response.response.result.images
        }
      
        // Check if we got any images
        conditional {
          if ($page_images == null || ($page_images|count) == 0) {
            // No more images available
            var $has_more {
              value = false
            }
          }
        
          else {
            // Filter and collect unannotated images
            foreach ($page_images) {
              each as $item {
                conditional {
                  // Check if image ID is NOT in the annotated list
                  if (($input.annotation_ids|find:$$ == $item.id) != $item.id) {
                    // Only add if we still need more
                    conditional {
                      if (($collected|count) < $input.page_size) {
                        array.push $collected {
                          value = $item
                        }
                      }
                    }
                  }
                }
              }
            }
          
            // Check if we've reached the last page
            conditional {
              if ($current_page >= $total_pages) {
                var $has_more {
                  value = false
                }
              }
            }
          }
        }
      
        // Advance page and iteration counter
        var $current_page {
          value = $current_page + 1
        }
      
        var $iterations {
          value = $iterations + 1
        }
      }
    }
  
    // Build next_cursor
    var $next_cursor {
      value = null
    }
  
    conditional {
      if ($has_more) {
        var $next_cursor {
          value = $current_page
        }
      }
    }
  }

  response = {
    images     : $collected
    next_cursor: $next_cursor
    has_more   : $has_more
  }
}