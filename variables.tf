variable "vpc" {
  type = object({
    name = string
  })
  default = {
    name = "management-ipfs-elastic"
  }
}

variable "profile" {
  type = string
}

variable "region" {
  type = string
}

variable "accountId" {
  type = string
}

variable "repo" {
  type = string
}

variable "token" {
  type = string
}

variable "runner_name" {
  type = string
}