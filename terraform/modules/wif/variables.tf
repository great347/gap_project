variable "wif_pool_id" {
    default ="llyod action pool"
    type = string
}

variable "wif_provider_id" {
    default = "llyod-github"
    type = string
}

variable "wif_oidc_issuer" {
    default = "https://token.actions.githubusercontent.com"
    type = string
}
