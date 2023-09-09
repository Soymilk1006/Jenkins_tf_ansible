1. Copy the whole directory and place in the under the defualt /home/ec2-user
2. Execute the command: ansible-playbook -i hosts my-playbook.yml
3. the app will be start and expose the port 3000
4. access the app through the public ip address http://ipaddress:3000

###################################################
Execute Command:
ansible-playbook -i inventory_aws_ec2.yml ansible_deploy.yml

if host = inventory_aws_ec2.yml is set in ansible.cfg file , then direclty execute command
ansible-playbook ansible_deploy.yml
