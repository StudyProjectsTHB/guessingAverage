resource "random_integer" "webhook_secret_length" {
  min = 12
  max = 50
}

resource "random_password" "webhook_secret" {
  length           = random_integer.webhook_secret_length.result
  special          = true
}

resource "random_password" "db_secret_name" {
  length           = 6
  special          = false
}
