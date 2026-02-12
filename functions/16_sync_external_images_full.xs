// Full sync: fetches ALL images from AktywAkcja API and inserts missing ones into external_image_cache.
function syncExternalImagesFull {
  input {
    // Images per page when fetching from external API
    int per_page?=50 filters=min:1|max:100
  }

  stack {
    var $api_headers {
      value = []
        |push:("X-API-Key: "
          |concat:$env.aktywakcja_token_v2:""
        )
        |push:"Content-Type: application/json"
    }
  
    db.add sync_log {
      data = {
        sync_type            : "full"
        status               : "in_progress"
        started_at           : "now"
        records_fetched      : 0
        records_inserted     : 0
        total_pages_processed: 0
      }
    } as $sync_log
  
    var $records_fetched {
      value = 0
    }
  
    var $records_inserted {
      value = 0
    }
  
    var $pages_processed {
      value = 0
    }
  
    var $max_ext_id {
      value = 0
    }
  
    try_catch {
      try {
        api.request {
          url = "https://aktywakcja.bielik.ai/api/v2/stats"
          method = "GET"
          headers = $api_headers
          timeout = 30
        } as $stats_response
      
        var $total_images {
          value = $stats_response.response.result.total_images
        }
      
        var $total_pages {
          value = (($total_images + $input.per_page - 1) / $input.per_page)|floor
        }
      
        var $current_page {
          value = 1
        }
      
        var $should_continue {
          value = true
        }
      
        while ($should_continue && $current_page <= $total_pages) {
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
          
            conditional {
              if ($images == null || ($images|count) == 0) {
                var $should_continue {
                  value = false
                }
              }
            
              else {
                var $records_fetched {
                  value = $records_fetched + ($images|count)
                }
              
                foreach ($images) {
                  each as $image {
                    db.get external_image_cache {
                      field_name = "external_id"
                      field_value = $image.id
                    } as $existing
                  
                    conditional {
                      if ($existing == null) {
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
                      
                        var $records_inserted {
                          value = $records_inserted + 1
                        }
                      }
                    }
                  
                    conditional {
                      if ($image.id > $max_ext_id) {
                        var $max_ext_id {
                          value = $image.id
                        }
                      }
                    }
                  }
                }
              
                var $pages_processed {
                  value = $pages_processed + 1
                }
              
                var $current_page {
                  value = $current_page + 1
                }
              }
            }
          }
        }
      
        db.edit sync_log {
          field_name = "id"
          field_value = $sync_log.id
          data = {
            status               : "success"
            finished_at          : "now"
            records_fetched      : $records_fetched
            records_inserted     : $records_inserted
            total_pages_processed: $pages_processed
            max_external_id      : $max_ext_id
          }
        } as $updated_log
      }
    
      catch {
        db.edit sync_log {
          field_name = "id"
          field_value = $sync_log.id
          data = {
            status               : "error"
            finished_at          : "now"
            error_message        : $error.message
            records_fetched      : $records_fetched
            records_inserted     : $records_inserted
            total_pages_processed: $pages_processed
          }
        } as $error_log
      }
    }
  
    db.get sync_log {
      field_name = "id"
      field_value = $sync_log.id
    } as $final_log
  }

  response = $final_log
}