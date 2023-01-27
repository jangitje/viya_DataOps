


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









