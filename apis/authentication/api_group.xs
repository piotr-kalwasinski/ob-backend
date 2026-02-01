api_group Authentication {
  canonical = "S8fLcjZn"
  cors = {
    mode       : "custom"
    origins    : ["https://obywatel-bielik.web.app", "http://localhost:5173"]
    methods    : ["GET", "POST"]
    headers    : ["Authorization", "Content-Type"]
    credentials: false
    max_age    : 3600
  }
}