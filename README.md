# Bastille

Bastille is a retro style shell escape vulnerability. The user is dropped into a restricted shell and must escape to get access to features that they wouldnt normally have.


For BSIDEs, Bastille is run behind an SSH server that is using a top password from rockyou. The competitors must brute force their way onto the server and then escape the shell to plant the flag.


## Running
To run the server in the competition environment, use the following docker-compose file
```yaml
version: '3'
services:
  bastile:
    build: .
    user: user
    restart: always
```