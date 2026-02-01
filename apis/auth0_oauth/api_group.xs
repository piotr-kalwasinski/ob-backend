api_group "auth0-oauth" {
  canonical = "zszBAomk"
  cors = {
    mode       : "custom"
    origins    : ["https://obywatel-bielik.web.app"]
    methods    : ["GET", "POST"]
    headers    : ["Authorization", "Content-Type"]
    credentials: false
    max_age    : 3600
  }
}