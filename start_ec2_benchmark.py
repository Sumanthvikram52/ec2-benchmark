#!/usr/bin/env python3
import click
import logging
from sys import stdout
from subprocess import Popen, PIPE, CalledProcessError, STDOUT
from os import chdir, path, chmod, mkdir, makedirs
from pathlib import Path
from Crypto.PublicKey import RSA
from pathlib import Path
from time import sleep

logging.basicConfig(stream=stdout, level=logging.INFO, format='%(asctime)s - %(name)s - '
                                                              '%(levelname)s - %(funcName)s - %(message)s')

'''
Choose the Core count to launch the VM.
1  => "t2.small"
2  => "t2.medium"
4  => "t2.xlarge"
8  => "t2.2xlarge"
'''

_home = str(Path.home())
_output_file_name = '/tmp/iperf.log'
_terraform_mod_path = '/opt/ec2-benchmark/Sub-Terraform-Modules/ec2-benchmark/'
_terraform_cmd = 'AWS_DEFAULT_REGION={0} terraform apply -var="instance_core={1}" --auto-approve'
_terraform_plan_cmd = 'AWS_DEFAULT_REGION={0} terraform plan -var="instance_core={1}"'
_terraform_destroy_cmd = 'AWS_DEFAULT_REGION={0} terraform destroy -var="instance_core={1}" --auto-approve'



def run_cmd(cmd):
    """
    This func will inject the raw linux commands in the shell.
    :param cmd: cmd to be executed.
    :return: output of the command.
    """
    try:
        cmd_output_raw = Popen(cmd, shell=True, stdout=PIPE, stderr=STDOUT)
        while True:
            output = cmd_output_raw.stdout.readline()
            if output.decode('utf-8') == '' and cmd_output_raw.poll() is not None:
                break
            if output:
                print(output.decode('utf-8').strip())
        rc = cmd_output_raw.poll()
        logging.info('CMD return code: {0}'.format(str(rc)))
        return rc
    except (CalledProcessError, OSError) as err:
        logging.exception(err)
        logging.critical('Failed when running this command -- {0}'.format(cmd))
        return False


@click.command()
@click.option('--region_name', help='Name of the region')
@click.option('--cpu_count', help='Number of vCPU.')
def run_terraform(cpu_count, region_name):
    """
    This Func will call terraform script.\n
    Choose the Core count to launch the VM.\n
    1  => t2.small \n
    2  => t2.medium \n
    4  => t2.xlarge \n
    8  => t2.2xlarge \n
    :param cpu_count: vCPU count to tbe provided for the VM. \n
    :param region_name: Name of the region to launch the VM. \n
    :return: None.
    """
    global _terraform_destroy_cmd
    chdir(_terraform_mod_path)
    run_cmd('terraform init')
    run_cmd(_terraform_plan_cmd.format(region_name, cpu_count))
    run_cmd(_terraform_cmd.format(region_name, cpu_count))
    cleanup(cpu_count, region_name)
    return None


def gen_rsa():
    """
    This Func will generate RSA keys.
    :return: None
    """
    key = RSA.generate(2048)
    if not path.isdir('{}/.ssh'.format(_home)):
        mkdir('{}/.ssh'.format(_home), 0o700)
    if not path.isfile("{0}/.ssh/private.key".format(_home)) and not path.isfile("{0}/.ssh/public.key".format(_home)):
        with open("{0}/.ssh/private.key".format(_home), 'wb') as content_file:
            chmod("{0}/.ssh/private.key".format(_home), 0o600)
            content_file.write(key.exportKey('PEM'))
        pubkey = key.publickey()
        with open("{0}/.ssh/public.key".format(_home), 'wb') as content_file:
            content_file.write(pubkey.exportKey('OpenSSH'))


def setup_ansible_provisioner():
    """
    This setup's ansible opensource terraform provisioner
    :return:
    """
    _url = 'https://github.com/radekg/terraform-provisioner-ansible/releases/download/v2.3.3/terraform-provisioner-ansible-linux-amd64_v2.3.3'
    try:
        logging.info("Installing terraform ansible provisioner")
        if not path.exists('{0}/.terraform.d/plugins/'.format(_home)):
            makedirs('{0}/.terraform.d/plugins/'.format(_home))
            _url_cmd = 'wget -O {0}/terraform-provisioner-ansible_v2.3.3 {1} > /dev/null 2>&1'.\
                format('{0}/.terraform.d/plugins'.format(_home), _url)
            run_cmd(_url_cmd)
            chmod('{0}/terraform-provisioner-ansible_v2.3.3'.format('{0}/.terraform.d/plugins'.format(
                _home)), 0o755)
        logging.info("Installation of terraform ansible provisioner completed")
    except Exception as err:
        logging.exception(err)
        logging.error("Unable to install terraform ansible provisioner")


def cleanup(cpu_count, region_name):
    """
    This Func will cleanup the deployment
    :return: None
    """
    sleep(10)
    chdir(_terraform_mod_path)
    run_cmd(_terraform_destroy_cmd.format(region_name, cpu_count))
    if path.isfile(_output_file_name):
        with open(_output_file_name, 'r') as file:
            iperf_output = file.read()
            print(iperf_output)
    else:
        logging.error('Iperf output file missing')

if __name__ == '__main__':
    gen_rsa()
    setup_ansible_provisioner()
    run_terraform()
