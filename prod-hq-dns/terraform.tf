terraform {
  backend "remote"{
    hostname = "app.terraform.io"
    organization = "icurfer"

    workspaces {
      name = "tf-cloud-dns"
    }
  }
}