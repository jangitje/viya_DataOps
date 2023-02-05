


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
You should be connected to REMOTE and have two VS Code Windows open. One local and one with remote SSH connection.  

#### Configure GIT on REMOTE(!) machine
Your RACE server with Centos Linux should already have GIT installed.  
Open a Terminal window (Terminal -> New Terminal ) if not already available.  
You can check installation:
```
    git --version
```

Just in you need/want to install GIT (for any OS):
https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup

Next, you need to configure GIT on REMOTE (with your own user and email):  
```
    git config --global user.name "John Doe"
    git config --global user.email johndoe@example.com0
```
You are now ready to clone GIT repository to your remote.
if no window opened in VS Code, VS code shows Clone Repository on your screen. Press this button. Then: Clone from Github -> jangitje/Viya_DataOps. Choose as location: /data/sascode.

if you already opened a window in VS Code and don't sdee button Clone Repository. Go to Command Palette (ctrl + shift + P): type GIT: Clone

Documentation:  
https://learn.microsoft.com/en-us/azure/developer/javascript/how-to/with-visual-studio-code/clone-github-repository?tabs=create-repo-command-palette%2Cinitialize-repo-activity-bar%2Ccreate-branch-command-palette%2Ccommit-changes-command-palette%2Cpush-command-palette


## Install SAS VS Code extensions REMOTE
In VS Code, left panel, extensions button.  
Search for SAS, install SAS from SAS Institute Inc.
Tip (if not already set): set SAS color theme: file -> prefrences -> Color Theme -> SAS Dark
You can't run SAS Code yet, as you first need a clientid and client secret on your machione


## Getting started with SAS VS Code Extension
Once the extensdion is active, it will recognize SAS Code.  
Go to extension remote, SAS and click on properties to find out the extension's features.  
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

This normally will be provided to you by the SAS Administrator. In case of RACE the administrator is you.  

In VS Code go to terminal and get admin rights with bash command: 
```
  su
```
Provide password.  
We need to install the small tool jq first:
```
sudo yum install jq -y
```
Next provide server details. Change it to your needs:
```
export SERVER_URL="https://azureuse030XXX.race.sas.com"
```
And your CLIENTID and SECRET. Again change it to your liking.
```
export CLIENTID=myclientid
export CLIENTSECRET=myclientsecret
echo $SERVER_URL
echo $CLIENTID
echo $CLIENTSECRET
```

Next:
```
export CONSUL_TOKEN=$(kubectl -n viya get secret sas-consul-client -o jsonpath="{.data.CONSUL_TOKEN}" | echo "$(base64 -d)")
echo $CONSUL_TOKEN
```
```
export TOKEN=$(curl -k -X POST "${SERVER_URL}/SASLogon/oauth/clients/consul?callback=false&serviceId=$CLIENTID" \
             -H  "X-Consul-Token: $CONSUL_TOKEN" | jq -r '.access_token')
echo $TOKEN
```
```            
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
You should now have a valid clientid and secret registered that you can use together with the SAS Extension.  
Your clientid is available for some time (normally at least a month). You can change this in SAS Environment Manager.  

At this point you should be ready to run SAS Code.
Go to SAS job run_main.sas and click on the running symbol up in the window.
Provide all the details to define a profile.  
Note: the SAS profile is stored on your local machine.  
When connecting, a SAS Window Logon screen should pop-up, you need to signon, then click a group (SAS Administrators will do) and then copy/paste the authorization code provided.


## Getting rid of providing password when connecting to remote in VS Code 
To get rid of userid/password everytime you connect, you can provide an SSH key pair.

In terminal in LOCAL VS Code connection (this is on your windows machine, the terminal will uses as a default Powershell):
```
ssh-keygen -t rsa -b 4096
```

Just give ENTER (no secret, no special name).  
The key pair will be stored in c:\Users\your_userid\.ssh.   
Indeed this is the same place where your connection config is stored.
Public key: id_rsa.pub, private key: id_rsa.

The public key must be added to file  \home\sas\.ssh\authorized_keys on the remote machine.  
Copy the content of the id_rsa.pub.  
On the remote machine (change this with your content, do't forget to quote):  
```
 export pubkey="ssh-rsa ***" 
 
```
Validate:
```
echo $pubkey
```
On remote (in no .ssh directory exists and no authorized_keys which is true for this image):
```
mkdir -p /home/sas/.ssh
echo $pubkey >> /home/sas/.ssh/authorized_keys
chmod 700 /home/sas/.ssh && chmod 600 /home/sas/.ssh/authorized_keys 

```
If correctly configured, next time you connect to remote server, VS Code should not ask you anymore for credentials.

## Initialize your own GIT repository in VS Code
Copy the content of viya_DataOpst to a new repository folder.  
You can now change/update your content and publish this to your own repository on GITHUB.  
  

## Next time you start your RACE image
Assuming you use RACE and save your image, next time you use your RACE image, you will have a new address.  
Unfortunately you have to update a few configurations.

When connecting to your remote server with VS Code SSH update this configuration:  
-   c:\Users\your_userid\.ssh\config  

Once connected update your SAS Extension profile:
-   VS Code, Ctrl + shift + P (Command Palette): SAS: Update Connection Profile


# Following part is to enable batch processing on your server, using SAS-VIYA CLI and Jenkins  
 
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
With Docker installed you can install Docker-compose.
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

### Set up credentials  
In Jenkins, go to Manage Jenkins -> Manage Credentials -> Domians -> Global -> Add Credentials.
ID sasdemo_pw
Password: password of sasdemo


### Setup pipeline project  
Go Jenkins dashboard:
Click: + New Item -> Pipeline project -> provide name.



Configure pipeline:
- Pipeline
  -  Definition: 'Pipeline script from SCM'
  -  SCM: 
     -  Git
  -  Repositories
     -  Repository URL:
        -  https://github.com/jangitje/viya_DataOps.git
        -  Credentials: 
           - -none- (this repository is public, for a private one you will need credentials) 
         - Brach Specifier:
           - origin/main
        - Save


Run your project by clicking Build (with Parameters if indicated)

If successfully the build Stage View will be green. 
After running the first time and making a successfull connection to GIT you will notice that the pipeline has changed. This is because Jenkins will take the properies from the Jenkins file in the repository. 


## Updates you need to make next time (new RACE image, new name)
- In VS Code, click left corner in bottom to connect to remote. Open SSH COnfiguration. Open your .\ssh\config file and update the host name.
- Connect to remote server
- Go to command palette (Ctrl + Shift + P). Type SAS: Update Connection Profile. Update your profile (just the name of the server).
- Run some code, you will be asked to provide new authorization code.
- In VS Code terminal (alternatively use MobaXterm to browse through directories in Linux and make changes to files):
```
su
vi /opt/jenkins/jenkins_plus/.sas/config.json
```
In VI editor:
- press I 
- edit your text
- press escape
- press :wq!
- enter 
  
To exit su mode:
``` 
exit
```  

Next we build and start Docker Jenkins Image:
```
cd /opt/jenkins
docker-compose build
docker-compose up-d
```
After a few moments Jenkins should be up and running on port 8080.


## Update you need working with new RACE image
- In VS Code terminal (alternatively use MobaXterm to browse through directories in Linux and make changes to files):
```
su
vi /opt/jenkins/jenkins_plus/.sas/config.json
```
In VI editor:
- press I 
- edit your text
- press escape
- press :wq!
- enter 
  
To exit su mode:
``` 
exit
```  

Next we build and start Docker Jenkins Image:
```
cd /opt/jenkins
docker-compose build
docker-compose up-d
```
After a few moments Jenkins should be up and running on port 8080.




