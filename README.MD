


## Install VS Code
  https://code.visualstudio.com/download

  
## Get an account at GITHUB
  https://github.com


## Install VS Code extensions LOCAL 
  In VS Code, left panel, extensions button.  
  Search for SSH, install Remote - SSH from Microsoft  

## Create SSH connection to RACE image or other SAS Server
  Click on green button, in left bottom corner of VS Code.
  Select SSH file configuration.  
  Select folder (in windows): c:\Users\your_userid\.ssh\config.  
  The content of the file should look like this for RACE:

    Host RACE_SERVER  
    HostName azureuse030XXX.race.sas.com
    User sas
    Port 22

Give the hostname as provided in your RACE e-mail with server details.  
Make sure to pick the server hostname and not the hostname of the client.

When done, connect to server. Answer 'yes' if asked for,  
give username and password if asked for.  
You should be connected to REMOTE.  
  
To get rid of userid/password everytime you connect, you can provide an SSH key pair.

In terminal:

    ssh-keygen -t rsa -b 4096

Just give ENTER (no secret, no special name).  
The key pair will be stored in c:\Users\your_userid\.ssh.  
Public key: id_rsa.pub, private key: id_rsa.

The public key must be added to file  \home\sas\.ssh\authorized_keys.  
You can open the file is VS Code with Open File if you're on the remote server.  
Just copy paste and save.  
If the file/folder doesn't already exist, in bash give these commands to create them:

    mkdir -p /home/sas/.ssh
    touch /home.sas/.ssh/authorized_keys 

If correctly configured, next time you connect to remote server, VS Code should not ask you for credentials.

## Install VS Code extensions REMOTE
In VS Code, left panel, extensions button.  
Search for SAS, install SAS from SAS Institute Inc.


#### Install GIT and setup GIT on REMOTE(!) machine
https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup

You need this (with your own user and email):  

    git config --global user.name "John Doe"
    git config --global user.email johndoe@example.com

#### Clone GIT repository to VS Code
To clone repository from GITHUB, check CLONE REPOSITORY:  
https://learn.microsoft.com/en-us/azure/developer/javascript/how-to/with-visual-studio-code/clone-github-repository?tabs=create-repo-command-palette%2Cinitialize-repo-activity-bar%2Ccreate-branch-command-palette%2Ccommit-changes-command-palette%2Cpush-command-palette

Give the name of repository to clone: 
* /jangitje/viya_DataOpst
  
The location for the repository: 
* /data/sascode

## Initialize your own GIT repository in VS Code
To clone repository from GITHUB, check INITIALIZE NEW REPOSITORY:  
https://learn.microsoft.com/en-us/azure/developer/javascript/how-to/with-visual-studio-code/clone-github-repository?tabs=create-repo-command-palette%2Cinitialize-repo-activity-bar%2Ccreate-branch-command-palette%2Ccommit-changes-command-palette%2Cpush-command-palette

Copy the content of viya_DataOpst to your own repository folders.  
You can now change/update your content and publish this to your repository on GITHUB.  
  

## Getting started with SAS VS Code Extension
Once the extensdion is active, it will recognize SAS Code.  
Go to extension remote, SAS and click on properties to find out the ext4ension's features.  
To run a SAS job, open a .sas file and click on run bottom in the right top corner.  
The SAS extension will ask for server details.  
Example of details (taken from settings.json):

    "SAS.connectionProfiles": {
            "activeProfile": "sasserver",
            "profiles": {
                "sasserver": {
                    "endpoint": "https://azureuse030XXX.race.sas.com",
                    "clientId": "myclientid",
                    "clientSecret": "myclientsecret"
                }
            }
        }
For the profile you need to provide clientId and clientSecret.  
This normally will come from the SAS Administrator. In case of RACE this is you.  
In VS Code go to terminal and get admin rights with bash command: 
```
  su
```
Provide password.
Next your server, CHANGE THIS TO YOUR NEEDS:
```
export SERVER_URL="https://azureuse030xxx.race.sas.com"
export CLIENTID=vsmyclientid
export CLIENTSECRET=vsmyclientsecret

```

Next:
```
export CONSUL_TOKEN=$(kubectl -n viya get secret sas-consul-client -o jsonpath="{.data.CONSUL_TOKEN}" | echo "$(base64 -d)")
export TOKEN=$(curl -k -X POST "${SERVER_URL}/SASLogon/oauth/clients/consul?callback=false&serviceId=$CLIENTID" \
             -H  "X-Consul-Token: $CONSUL_TOKEN" | jq -r '.access_token')
curl -k -X POST "${SERVER_URL}/SASLogon/oauth/clients" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $TOKEN" \
     -d "{
      \"client_id\": \"$CLIENTID\", 
      \"client_secret\": \"$CLIENTSECRET\",
      \"scope\": \"*\",
      \"authorized_grant_types\": [\"authorization_code\",\"refresh_token\"],
      \"redirect_uri\": \"urn:ietf:wg:oauth:2.0:oob\"
     }"

```
You should now have a valid clientid that you can use together with the SAS Extension.  
You only have to do this once.


## Next time you start your RACE image
Assuming you use RACE and save your image, next time you use your RACE image, you will have a new address.  
Unfortunately you have to update a few configurations.

When connecting to your remote server with VS Code SSH update this configuration:  
-   c:\Users\your_userid\.ssh\config  

Once connected update your SAS Extension profile:
-   VS Code, Ctrl + shift + P (Command Palette): SAS: Update Connection Profile
  
## Install and configure SAS-VIYA CLI on remote
The SAS Viya CLI is used to run SAS jobs in batch using the Jenkins tool.  
How to install and configure the SAS-VIYA CLI:  
https://go.documentation.sas.com/doc/en/sasadmincdc/v_035/calcli/n01xwtcatlinzrn1gztsglukb34a.htm  

For RACE image you don't need to worry about certificates.  
Just get the tar and untar in your folder of choice:
```
tar -xvzf /CLI-directory/sas-viya-cli-version-download-linux.tgz  
```  
From the directory, make sure that the Execute permission is set:
```
chmod +x sas-viya
```

Next you have to install plugins.  For this purpose we only need batch plugin:
```
sas-viya plugins
sas-viya plugins list
sas-viya plugins list-repo-plugins
sas-viya plugins install --repo SAS batch
```

Next create a profile:
```
sas-viya profile init
```

Plugin and profile is stored in user folder, in case of RACE this is:
-   /root/.sas/  

## Install docker-compose
I assume you already have Docker installed, if not you have to install Docker.
With DOcker installed you can install Docker-compose.
https://docs.docker.com/compose/install/

## Create customized docker Jenkins image
We need a slightly modified Jenkins image, since we are going to use ZIP and the SAS CLI on the Jenkins image.
Create directories:
```
mkdir /opt/jenkins
mkdir /opt/jenkins/home
mkdir /opt/jenkins_plus
cp your_cli_location/sas-viya /opt/jenkins_plus
cp /root/.sas -R /opt/jenkins_plus
touch /opt/jenkins/jenkins_plus/Dockerfile
```
Make sure the config.json file in the .sas folder points to the correct RACE server.

Content of Dockerfile: 
```
FROM jenkins/jenkins
USER root

RUN  apt-get update  
RUN  apt-get install zip  
RUN  apt-get install uuid-runtime  
COPY .sas/ /root/.sas/  
COPY sas-viya /root  
```

Next prepare docker compose file
  
```  
touch /opt/jenkins/docker-compose.yml
```

Content of Docker-compose file:
```
version: '3'
services:
  jenkins:
    container_name: jenkins_plus
    image: jenkins_plus
    ports:
      - "8080:8080"
    build:
      context: jenkins_plus
    volumes:
      - "$PWD/jenkins_home:/var/jenkins_home"
    networks:
      - net
networks:
  net:
```
You should be now able to build the customized Jenkins image:
```
cd /opt/jenkins
docker-compose build
```
Finally you can start the image:
```
docker-compose up -d
```
After a few moments you can start the Jenkins applicatie. In the client image:
```
http://sasserver.demo.sas.com:8080/
```
You will have to provide the Jenkins admin password.
You can get the password from the initial log:
```
docker logs jenkins_plus
```


## Configure Jenkins

Set up credentials  


Setup pipeline project  


## Required updates when working with new RACE image 






