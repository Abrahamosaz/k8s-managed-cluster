output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "ec2_instances_ips" {
  value = {
    master = {
      private_ip = aws_instance.master_node.private_ip
      public_ip  = aws_instance.master_node.public_ip
    }
    workers = [for w in aws_instance.worker_node : {
      private_ip = w.private_ip
      public_ip  = w.public_ip
    }]
  }
}
