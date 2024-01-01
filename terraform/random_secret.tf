resource "random_integer" "webhook_secret_length" {
  min = 12
  max = 50
}

resource "random_password" "webhook_secret" {
  length           = random_integer.webhook_secret_length.result
  special          = true
}
