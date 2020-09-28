locals {
  certificates_names = ["client-ca", "server-ca", "request-header-key-ca"]
  certificates_types = { for s in local.certificates_names : index(local.certificates_names, s) => s }
  certificates_by_type = { for s in local.certificates_names : s =>
    tls_self_signed_cert.kubernetes_ca_certs[index(local.certificates_names, s)].cert_pem
  }
  certificates_files = flatten(
    [for s in local.certificates_names :
      [
        { "/var/lib/rancher/k3s/server/tls/${s}.key" = tls_private_key.kubernetes_ca[index(local.certificates_names, s)].private_key_pem },
        { "/var/lib/rancher/k3s/server/tls/${s}.crt" = tls_self_signed_cert.kubernetes_ca_certs[index(local.certificates_names, s)].cert_pem }
      ]
    ]
  )
  cluster_ca_certificate = local.certificates_by_type["server-ca"]
  client_certificate     = tls_locally_signed_cert.master_user.cert_pem
  client_key             = tls_private_key.master_user.private_key_pem
}

# Keys
resource "tls_private_key" "kubernetes_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
  count       = 3
}

# certs
resource "tls_self_signed_cert" "kubernetes_ca_certs" {
  for_each              = local.certificates_types
  key_algorithm         = "ECDSA"
  validity_period_hours = 876600 # 100 years
  allowed_uses          = ["critical", "digitalSignature", "keyEncipherment", "keyCertSign"]
  private_key_pem       = tls_private_key.kubernetes_ca[each.key].private_key_pem
  is_ca_certificate     = true

  subject {
    common_name = "kubernetes-${each.value}"
  }
}

# master-login cert
resource "tls_private_key" "master_user" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "master_user" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.master_user.private_key_pem

  subject {
    common_name  = "master-user"
    organization = "system:masters"
  }
}

resource "tls_locally_signed_cert" "master_user" {
  cert_request_pem   = tls_cert_request.master_user.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = tls_private_key.kubernetes_ca[0].private_key_pem
  ca_cert_pem        = tls_self_signed_cert.kubernetes_ca_certs[0].cert_pem

  validity_period_hours = 876600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth"
  ]
}
