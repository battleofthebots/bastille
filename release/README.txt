Bastille
==================

Go directly to jail, do not pass go, do not collect $200!

Can you get out?

Running Bastille
==================

To run a simple, local-copy of bastille, create a jail directory with the script provides and then run the jail

    bash build_jail.sh
    JAIL_PATH=./bin ./bastile


To run a full bastille setup in docker with ssh, simple build and run the provided dockerfile

    docker build -t bastille .
    docker run --rm -p 127.0.0.1:2222:22 -it bastille
    ssh -p 2222 user@127.0.0.1 # The password is password