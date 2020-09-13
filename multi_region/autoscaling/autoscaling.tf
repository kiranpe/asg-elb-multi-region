#######################
# Launch configuration
#######################
resource "aws_launch_configuration" "this" {
  count = var.create_lc ? 1 : 0

  name                        = var.lc_name
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile
  key_name                    = var.key_name
  security_groups             = [data.aws_security_group.default.id]
  associate_public_ip_address = var.associate_public_ip_address
  user_data_base64            = var.user_data_base64
  enable_monitoring           = var.enable_monitoring
  spot_price                  = var.spot_price
  ebs_optimized               = var.ebs_optimized
  
  user_data                   = file("${path.module}/install_docker_httpd.sh")

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      no_device             = lookup(ebs_block_device.value, "no_device", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

####################
# Autoscaling group
####################
 
resource "aws_autoscaling_group" "this" {
  count = var.create_asg && length(data.aws_subnet_ids.private.ids) > 0 ? length(data.aws_subnet_ids.private.ids) : 0
 
  name                 = element(var.asg_name, count.index)
  launch_configuration = var.create_lc ? element(concat(aws_launch_configuration.this.*.name, [""]), 0) : var.launch_configuration
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier       = [data.aws_subnet.selected[count.index].id] 
  load_balancers            = var.load_balancers
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  min_elb_capacity          = var.min_elb_capacity
  wait_for_elb_capacity     = var.wait_for_elb_capacity
  target_group_arns         = var.target_group_arns
  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  placement_group           = var.placement_group
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn
  max_instance_lifetime     = var.max_instance_lifetime

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = element(var.asg_name, count.index)
        "propagate_at_launch" = true
      },
    ]
  )

  lifecycle {
    create_before_destroy = true
  }
}
