// Incremental sync: checks stats, skips if no new images, otherwise fetches only new ones.
function syncExternalImagesIncremental {
  input {
    // Images per page when fetching from external API
    int per_page?=50 filters=min:1|max:100
  }

  stack {
    // Auth headers reused for all API calls
    var $api_headers {
      value = []
        |push:("X-API-Key: "
          |concat:$env.aktywakcja_token_v2:""
        )
        |push:"Content-Type: application/json"
    }
  
    try_catch {
      try {
        // Step 1: Quick check via stats
        api.request {
          url = "https://aktywakcja.bielik.ai/api/v2/stats"
          method = "GET"
          headers = $api_headers
          timeout = 30
        } as $stats_response
      
        var $total_images {
          value = $stats_response.response.result.total_images
        }
      
        // Count cached images
        db.query external_image_cache {
          return = {type: "list"}
          output = ["id"]
        } as $cache_all
      
        var $cache_count {
          value = `$cache_all|count`
        }
      
        // If counts match — skip
        conditional {
          if ($total_images == $cache_count) {
            db.add sync_log {
              data = {
                sync_type            : "incremental"
                status               : "skipped"
                started_at           : "now"
                finished_at          : "now"
                records_fetched      : 0
                records_inserted     : 0
                total_pages_processed: 0
              }
            } as $skip_log
          
            return {
              value = $skip_log
            }
          }
        }
      
        // Step 2: Get max known external_id
        db.query external_image_cache {
          sort = {external_id: "desc"}
          return = {type: "list", paging: {page: 1, per_page: 1}}
        } as $max_result
      
        var $max_known_id {
          value = 0
        }
      
        conditional {
          if (($max_result.items|count) > 0) {
            var $max_known_id {
              value = $max_result.items|first|get:"external_id":0
            }
          }
        }
      
        // If cache is empty, fall back to full sync
        conditional {
          if ($max_known_id == 0) {
            function.run syncExternalImagesFull as $full_result
            return {
              value = $full_result
            }
          }
        }
      
        // Step 2c: Calculate expected new count
        var $new_count {
          value = $total_images - $cache_count
        }
      
        // Create in-progress log
        db.add sync_log {
          data = {
            sync_type            : "incremental"
            status               : "in_progress"
            started_at           : "now"
            records_fetched      : 0
            records_inserted     : 0
            total_pages_processed: 0
            max_external_id      : $max_known_id
          }
        } as $sync_log
      
        // Step 3: Fetch new images page by page
        var $current_page {
          value = 1
        }
      
        var $inserted_count {
          value = 0
        }
      
        var $fetched_count {
          value = 0
        }
      
        var $pages_done {
          value = 0
        }
      
        var $final_max_id {
          value = $max_known_id
        }
      
        var $keep_fetching {
          value = true
        }
      
        while ($keep_fetching) {
          each {
            api.request {
              url = "https://aktywakcja.bielik.ai/api/v2/images"
              method = "GET"
              params = {}
                |set:"page":$current_page
                |set:"per_page":$input.per_page
              headers = $api_headers
              timeout = 30
            } as $page_response
          
            var $images {
              value = $page_response.response.result.images
            }
          
            // Empty response — stop
            conditional {
              if ($images == null || ($images|count) == 0) {
                var $keep_fetching {
                  value = false
                }
              }
            
              else {
                var $fetched_count {
                  value = $fetched_count + ($images|count)
                }
              
                // Process each image
                foreach ($images) {
                  each as $image {
                    // Only insert if external_id > max_known_id
                    conditional {
                      if ($image.id > $max_known_id) {
                        db.add external_image_cache {
                          data = {
                            external_id        : $image.id
                            image_url          : $image.image_url
                            category_id        : $image.category.id
                            category_name      : $image.category.name
                            external_created_at: $image.created_at
                            synced_at          : "now"
                            raw_data           : $image
                          }
                        } as $new_record
                      
                        var $inserted_count {
                          value = $inserted_count + 1
                        }
                      
                        // Track max ID
                        conditional {
                          if ($image.id > $final_max_id) {
                            var $final_max_id {
                              value = $image.id
                            }
                          }
                        }
                      }
                    }
                  }
                }
              
                var $pages_done {
                  value = $pages_done + 1
                }
              
                // Stop conditions: inserted enough or last page
                conditional {
                  if ($inserted_count >= $new_count) {
                    var $keep_fetching {
                      value = false
                    }
                  }
                
                  elseif (($images|count) < $input.per_page) {
                    // Partial page = last page
                    var $keep_fetching {
                      value = false
                    }
                  }
                }
              
                var $current_page {
                  value = $current_page + 1
                }
              }
            }
          }
        }
      
        // Step 4: Finalize sync_log
        db.edit sync_log {
          field_name = "id"
          field_value = $sync_log.id
          data = {
            status               : "success"
            finished_at          : "now"
            records_fetched      : $fetched_count
            records_inserted     : $inserted_count
            total_pages_processed: $pages_done
            max_external_id      : $final_max_id
          }
        } as $updated_log
      }
    
      catch {
        // Try to update existing log
        conditional {
          if ($sync_log != null) {
            db.edit sync_log {
              field_name = "id"
              field_value = $sync_log.id
              data = {
                status       : "error"
                finished_at  : "now"
                error_message: $error.message
              }
            } as $error_log
          }
        
          else {
            db.add sync_log {
              data = {
                sync_type    : "incremental"
                status       : "error"
                started_at   : "now"
                finished_at  : "now"
                error_message: $error.message
              }
            } as $error_log
          }
        }
      }
    }
  
    // Return final sync_log
    conditional {
      if ($sync_log != null) {
        db.get sync_log {
          field_name = "id"
          field_value = $sync_log.id
        } as $final_log
      }
    }
  }

  response = $final_log
}