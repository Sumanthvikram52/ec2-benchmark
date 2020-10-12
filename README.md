# EC2-BenchMark

- The physical proximity of the EC2 instances. Instances in the same Availability Zone are geographically closest to each other. Instances in different Availability Zones in the same Region, instances in different Regions on the same continent, and instances in different Regions on different continents are progressively farther away from one another.
- The EC2 instance maximum transmission unit (MTU). The MTU of a network connection is the largest permissible packet size (in bytes) that your connection can pass. All EC2 instances types support 1500 MTU. All current generation Amazon EC2 instances support jumbo frames. In addition, the previous generation instances, C3, G2, I2, M3, and R3 also use jumbo frames. Jumbo frames allow more than 1500 MTU. However, there are scenarios where your instance is limited to 1500 MTU even with jumbo frames.
- The size of your EC2 instance. Larger instance sizes for an instance type typically provide better network performance than smaller instance sizes of the same type.
Amazon EC2 enhanced networking support for Linux, except for T2 and M3 instance types. For more information, see Enhanced networking on Linux. For information on enabling enhanced networking on your instance, see How do I enable and configure enhanced networking on my EC2 instances?
- Amazon EC2 high performance computing (HPC) support that uses placement groups. HPC provides full-bisection bandwidth and low latency, with support for up to 100-gigabit network speeds, depending on the instance type. To review network performance for each instance type, see Amazon Linux AMI instance type matrix.
- The instance is a burstable performance instance (T3, T3a, and T2 instances). When a burstable instance performs below its network throughput performance baseline, CPU credits accrue. These credits allow burstable performance instances to temporarily burst above their network throughput baseline.
- Try to use VPC Peering, VPN or Direct Connect for optimal performance as intermediate links can create bottlenecks.


### About Script.

Stack:
- Python3
- Terraform
- Ansible

### Base VM requirements and Installation

Script requires Python3 and ansible to run.

Install Python3 and Ansible

```sh
sudo apt update
sudo apt install python3 pip3 unzip
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

Install Terraform:

```sh
cd ~/
wget https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip
unzip -q terraform_0.13.4_linux_amd64.zip
mv terraform /bin/
```

### Script requirements and Execution.

Assuming the VM or Desktop will have full permission for EC2 and VPC.
Need to subscribe this in AWS Market place - https://aws.amazon.com/marketplace/pp/B07CQ33QKV/

Install the dependencies.

```sh
$ cd /opt
$ git clone <GIT URL>
$ cd ec2-benchmark
$ pip3 install -r requirements.txt
```
Execute -
```sh
$ python3 start_ec2_benchmark.py --region_name us-west-2 --cpu_count 1
```

- The Script will spin two EC2 VM with the given core count and region. 
- Opens SG rules as required.
- Install's required tools using ansible.(Playbook invoked from Terraform script).
- Does a throughput test using iPerf3 tool.
- Post completion, Teardown the setup using terraform destroy.
- Displays the iPerf3 Report at the end.



