


#### Install VS Code
https://code.visualstudio.com/download


#### Get an account at GITHUB
https://github.com/


#### Install VS Code extensions LOCAL
In VS Code, left panel, extensions button.
Search for SSH, install Remote - SSH from Microsoft


#### Create SSH connection to RACE image or other SAS Server
Click on green button, in left bottom corner of VS Code
Select SSH file configuration.
Select folder (in windows): c:\Users\your_userid\.ssh\config

The content of the file should look like this for RACE:

Host RACE_SERVER
    HostName azureuse030XXX.race.sas.com
    User sas
    Port 22

Give the hostname as provided in your RACE e-mail with server details. Make sure to pick the server hostname and not the hostname of the client.

When done, connect to server. Answer 'yes' if asked for, give username and password if asked for.
You should be connected to REMOTE.

To get rid of userid/password everytime you connect, you can provide an SSH key pair.

In terminal:
ssh-keygen -t rsa -b 4096

Just give ENTER (no secret, no special name). The key pair will be stored in c:\Users\your_userid\.ssh.
Public key: id_rsa.pub, private key: id_rsa.

The public key must be added to file  \home\sas\.ssh\authorized_keys 
You can open the file is VS Code with Open File if you're on the remote server. Just copy paste and save.
If the file/folder doesn't already exist, in bash give these commands to create them:
mkdir -p /home/sas/.ssh
touch /home.sas/.ssh/authorized_keys 

If correctly configured, next time you connect to remote server, VS Code should not ask you for credentials.

#### Install VS Code extensions REMOTE
In VS Code, left panel, extensions button.
Search for SAS, install SAS from SAS Insttute Inc.


#### Install GIT and setup GIT on REMOTE(!) machine
https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup

You need this (with your own user and email):
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com

#### Clone GIT repository
In VS Code on remote connection:
git remote add origin https://github.com/jangitje/viya_DataOps.git
git branch -M main
git push -u origin main

