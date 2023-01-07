terraform {
  backend "remote"{
    hostname = "app.terraform.io"
    organization = "icurfer"

    workspaces {
      name = "tf-22shop-hq-efs"
    }
  }
}