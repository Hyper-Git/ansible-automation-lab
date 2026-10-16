# Web app : read-only access to their own secret
path "secret/data/webapp" {
  capabilities = ["read"]
}