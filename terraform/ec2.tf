data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_key_pair" "k8s_cluster_nodes" {
  key_name = "k8s-cluster-nodes"
}

locals {
  worker_node_count         = 1
  master_node_instance_type = "t3.small"
  worker_node_instance_type = "t3.small"
}


resource "aws_security_group" "master_node" {
  name        = "${var.resource_tags["Project"]}-master-node-sg"
  description = "Control plane ports for kubeadm-managed Kubernetes cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from the internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Kubernetes API server from VPC only"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "etcd server client API from VPC only"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "Kubelet API (control plane) from VPC only"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "kube-scheduler from VPC only"
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "kube-controller-manager from VPC only"
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "BGP (Calico) from VPC only"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "VXLAN overlay from VPC only"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.resource_tags["Project"]}-master-node-sg"
    }
  )
}

resource "aws_security_group" "worker_node" {
  name        = "${var.resource_tags["Project"]}-worker-node-sg"
  description = "Worker node ports for kubeadm-managed Kubernetes cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from the internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Kubelet API — from control plane and other workers
  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "BGP (Calico) from VPC only"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "VXLAN overlay from VPC only"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # kube-proxy
  ingress {
    description = "kube-proxy"
    from_port   = 10256
    to_port     = 10256
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "NodePort Services (TCP) from VPC only"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "NodePort Services (UDP) from VPC only"
    from_port   = 30000
    to_port     = 32767
    protocol    = "udp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.resource_tags["Project"]}-worker-node-sg"
    }
  )
}


resource "aws_instance" "master_node" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.master_node_instance_type
  key_name                    = data.aws_key_pair.k8s_cluster_nodes.key_name
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.master_node.id]
  associate_public_ip_address = true

  tags = merge(
    var.resource_tags,
    {
      Name = "${var.resource_tags["Project"]}-master-node"
    }
  )
}


resource "aws_instance" "worker_node" {
  count                       = local.worker_node_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.worker_node_instance_type
  key_name                    = data.aws_key_pair.k8s_cluster_nodes.key_name
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.worker_node.id]
  associate_public_ip_address = true


  tags = merge(
    var.resource_tags,
    {
      Name = "${var.resource_tags["Project"]}-worker${count.index}"
    }
  )
}
