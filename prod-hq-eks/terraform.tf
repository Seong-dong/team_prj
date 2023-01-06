terraform {
  backend "remote"{
    hostname = "app.terraform.io"
    organization = "22shop"

    workspaces {
      name = "tf-cloud-eks"
    }
  }
}