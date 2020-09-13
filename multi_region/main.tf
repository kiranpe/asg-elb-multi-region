############################################
# Launch configuration and autoscaling group
############################################

module "launch_asg" {
  
  source = "./autoscaling" 

  lc_name = "my-lc"
  instance_type   = "t2.micro"
  load_balancers  = [module.launch_elb.this_elb_id]

  ebs_block_device = [
    {
      device_name           = "/dev/sde"
      volume_type           = "gp2"
      volume_size           = "8"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "8"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  health_check_type         = "EC2"
  min_size                  = 2 
  max_size                  = 2 
  desired_capacity          = 2 
  wait_for_capacity_timeout = 0

}

######
# ELB
######
module "launch_elb" {
 
  source = "./elb"

  name = "elb-test"

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
  

  tags = {
   Name = "test-elb"
  }

}

##########
#Redis
##########
module "redis" {
  source = "./redis"
}
