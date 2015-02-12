FROM centos:centos6

MAINTAINER Tim Mahoney <tim@timothymahoney.com>

# Add some basic packages; CentOS doesn't ship with much, but pare this down if you don't want it.
RUN yum -y update ; yum clean all
RUN yum -y install vim make epel-release tar wget unzip gcc git ; yum clean all

# Install Ansible
RUN yum -y install ansible

# Add an ansible inventory that just points locally, naming it "container" for use in our playbooks.
COPY ansible_hosts /etc/ansible/hosts

# Adding a github key to your box
COPY readonly_github_key /root/.ssh/id_rsa
RUN chmod 0600 /root/.ssh/id_rsa

# Set github to use the key you just added 
COPY ssh_config /root/.ssh/config
RUN chmod 0600 /root/.ssh/config

# Add github to your known hosts
RUN ssh-keyscan -H github.com > /root/.ssh/known_hosts

# I put repo checkouts in /opt. Feel free to change it to something else.
RUN mkdir /opt/ansible

# Copy the src/ directory containing your ansible playbook into the container
COPY src/ /opt/ansible/

### OR ###

# Check out the repo with your ansible playbooks
# RUN git clone git@github.com:your_username/your_ansible_repo.git .

# CD over to our ansible scripts
WORKDIR /opt/ansible

# Run the playbook. No need for inventory, but set any extra-vars you might need. 
RUN ansible-playbook playbook.yml 

# Expose the ports your container needs
EXPOSE 80

# Set up what begins when your container starts
CMD /usr/sbin/httpd -D FOREGROUND
