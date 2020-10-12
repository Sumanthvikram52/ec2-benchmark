ingress_rules = [
    {
        type        = "ingress"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
        description = "SSH Rule"
    },
    {
        type        = "ingress"
        from_port   = 5201
        to_port     = 5201
        protocol    = "tcp"
        cidr_block  = "172.31.0.0/16"
        description = "Iperf3 Rule"
    }
]