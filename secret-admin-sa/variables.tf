variable "kubernetes_host" {
  description = "The hostname of the OCP cluster"
}

variable "kubernetes_token" {
  description = "The authentication token of the OCP cluster"
}

variable "kubernetes_role_namespaces" {
  type        = list(string)
  description = "The OCP namespaces to create new roles"
}

variable "kubernetes_service_account_namespace" {
  description = "The OCP namespace to create new service account"
}
