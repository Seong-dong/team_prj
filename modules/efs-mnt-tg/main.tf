resource "aws_efs_mount_target" "mount" {
  file_system_id  = var.fs_id
  subnet_id       = var.subnet_id

  security_groups = var.sg_list
}