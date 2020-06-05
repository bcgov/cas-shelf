output "service_account_name" {
  value = "${kubernetes_service_account.sa.id}"
}

output "service_account_token" {
  value = "${data.kubernetes_secret.secret.data.token}"
}
