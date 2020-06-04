provider "kubernetes" {
  load_config_file = "false"
  host             = var.kubernetes_host
  token            = var.kubernetes_token
}

resource "kubernetes_role" "role" {
  count = length(var.kubernetes_role_namespaces)

  metadata {
    name      = "terraform-secret-admin"
    namespace = element(var.kubernetes_role_namespaces, count.index)
    labels = {
      created-by = "Terraform"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }
}

resource "kubernetes_service_account" "sa" {
  metadata {
    name      = "terraform-kubernetes-service-account"
    namespace = var.kubernetes_service_account_namespace
    labels = {
      created-by = "Terraform"
    }
  }
}

resource "kubernetes_role_binding" "binder" {
  count = length(var.kubernetes_role_namespaces)

  metadata {
    name      = "terraform-secret-admin-binder"
    namespace = element(var.kubernetes_role_namespaces, count.index)
    labels = {
      created-by = "Terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = split("/", kubernetes_role.role[count.index].id)[1]
  }

  subject {
    kind      = "ServiceAccount"
    name      = split("/", kubernetes_service_account.sa.id)[1]
    namespace = var.kubernetes_service_account_namespace
  }
}

data "kubernetes_secret" "example" {
  metadata {
    name      = kubernetes_service_account.sa.default_secret_name
    namespace = var.kubernetes_service_account_namespace
  }
}
