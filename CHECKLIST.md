# Born2beRoot Defense Checklist

## Preliminary Tests

- [ ] Git repo cloned successfully.

## General Instructions

- [ ] Git repo contains a signature.txt file.
- [ ] Check whether signature is identical to `.vdi` file. 
- [ ] Clone VM || create a snapshot && open VM.

## Mandatory Part

- [ ] How does a virtual machine work and what is its purpose?
- [ ] The basic differences between CentOS and Debian?
- [ ] Their choice of operating system?
- [ ] If CentOS: what SELinux and DNF are.
- [ ] If Debian: the difference between aptitude, apt and what APPArmor is.
- [ ] A script must display all information every 10 minutes. Its operation will be checked in detail later.
- [ ] All explanations are satisfactory (else evaluation stops here).

## Simple Setup

- [ ] Ensure that the machine does not have a graphical environment at launch.
- [ ] Connect to VM as a created user.
- [ ] Ensure password follows specs (2 days min, 7, 30 days max).
	`sudo chage -l username`
- [ ] Check UFW service is started.
	`sudo ufw status`
- [ ] Check SSH service is started.
	`sudo systemctl status ssh`
- [ ] Check the chosen operating system (Debian or CentOS).
	`lsb_release -a || cat /etc/os-release`

## User

- [ ] Check that 42 login user has been added and belongs to “sudo” and “user42” groups.
	```
	getent group sudo
	getent group user42
	```

## Password Policies

- [ ] Create new user (e.g. user42).
	`sudo adduser new_username`
- [ ] Assign a password of your choice, according to specs.
	`getent group sudo`
- [ ] Explain how to implement the password policy. 
- [ ] There should be 1-2 modified files. (else evaluation stops here).
- [ ] Create a group named “evaluating” and assign it to new user.
	```
	sudo groupadd evaluating
	sudo usermod -aG evaluating new_username
	```
- [ ] Check if new user belongs to “evaluating” group.
	`getent group evaluating`
- [ ] Explain advantages of the password policy.
- [ ] Explain advantages/disadvantages of the policy implementation.

## Hostname & Partitions

If on restart, the hostname has not been updated, the evaluation stops here.

- [ ] Check if hostname is correctly formatted: login42.
	`hostnamectl`
- [ ] Modify this hostname by replacing it with yours, then restart VM.
	```
	sudo hostnamectl set-hostname new_hostname
	sudo reboot
	```
- [ ] Restore to the original hostname, then restart VM.
	```
	sudo hostnamectl set-hostname new_hostname
	sudo reboot
	```
- [ ] Explain how to view the partitions for the VM.
	`lsblk`
- [ ] Compare the output with the example in PDF.
- [ ] Explain LVM and how it works.

## Sudo

- [ ] Check “sudo” program is properly installed.
	`dpkg -l | grep sudo`
- [ ] Demo assigning a new user to the “sudo” group.
- [ ] Explain the value and operation of sudo using examples.
	`sudo visudo ls`
- [ ] Show implementation, according to specs.
- [ ] Verify that `/var/log/sudo/` folder exists and has a file. The file content should have a history of sudo commands.
- [ ] Run a command via sudo. See if the file has been updated.

## UFW

- [ ] Check “UFW” program is installed and works.
	`sudo ufw status numbered`
- [ ] Ask for basic explanation of UFW and why use it.
- [ ] List active rules in UFW. A rule must exist for port 4242.
- [ ] Add a new rule to open port 8080. Then, list the active rules.
	`sudo ufw allow 8080`
- [ ] Delete this new rule.
	```
	sudo ufw delete 4
	sudo ufw delete 2
	```

## SSH

- [ ] Check that SSH service is installed and works.
	`sudo service ssh status`
- [ ] Explain what SSH is and why use it.
- [ ] Verify that SSH service only uses port 4242.
- [ ] Use SSH to log in with newly created user.
	`ssh jin-tan@127.0.0.1 -p 4242`
- [ ] Make sure you cannot use SSH with the “root” user.
	`ssh jin-tan42@127.0.0.1 -p 4242`

## Monitoring Script

- [ ] Ask how script works and inspect the code.
- [ ] Script content is in monitoring .sh
	`cd /usr/local/bin && nano monitoring.sh`
- [ ] What is cron?
- [ ] How does the script run every 10 minutes from when the server starts?
- [ ] Make sure the script runs with dynamic values.
	`sudo crontab -u root -e (change 10 to 1)`
- [ ] Make the script stop running without modifying the script. To check, restart VM.
	```
	sudo cronstop
	sudo cronstart
	```
- [ ] At startup, check if the script still exists, permission unchanged, and file unmodified.
	```
	sudo reboot
	sudo crontab -u root -e
	```

## Commands Dump

```
sudo ufw status
sudo systemctl status ssh
getent group sudo
getent group user42
sudo adduser new username
sudo groupadd groupname
sudo usermod -aG groupname username
sudo chage -l username - check password expire rules
hostnamectl
hostnamectl set-hostname new_hostname - to change the current hostname
Restart your Virtual Machine.
sudo nano /etc/hosts - change current hostname to new hostname
lsblk to display the partitions
dpkg -l | grep sudo – to show that sudo is installed
sudo ufw status numbered
sudo ufw allow port-id
sudo ufw delete rule number
ssh your_user_id@127.0.0.1 -p 4242 - do this in terminal to show that SSH to port 4242 is working
```
