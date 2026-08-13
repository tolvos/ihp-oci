# IHP via OCI
Get started using [IHP](https://github.com/digitallyinduced/ihp) by creating an isolated dev container for your
coding environment. This OCI image does most of the Nix setup, you just need to login to the `developer` user account,
and start your first project with: `ihp-new <projectname>`

Complete and official IHP guide is found here: https://ihp.digitallyinduced.com/Guide/index.html

I am not affiliated with Digitally Induced or IHP in any way, but I thought I'd learn IHP by first creating this 
isolated environment to work in.

## Some background

Working in containers is a personal preference of mine, as it makes it easy to sandbox technologies from your host
system. It feels a bit more secure having the ability to create Access Control Rules (ACLs) that say what all an 
application/container environment can touch rather than just diving right in to installing something on your personal or
work computer. That's why this repo exists: to let people have an easy way to scaffold IHP projects without having to
worry about how their host might interact with Nix or IHP.

## Declarative configurations

You can use something like `docker compose` or `incus-apply` to consistently create and update your container. I 
personally use `incus-apply` for Incus, but I've attempted to write a `docker compose` config you can reference here.

<details>
<summary>Docker (using `docker compose`)</summary>

```yaml
services:
  ihp:
    image: ghcr.io/tolvos/ihp-oci:latest
    container_name: ihp
    stdin_open: true
    tty: true

    ports:
      - "8000:8000" # Preview/live-update of the IHP app.
      - "8001:8001" # IHP IDE page.
      - "8002:8002" # Hoogle, the Haskell API search engine.

    # Optional: persistent storate such as an existing IHP app, or your nix store folder so you don't need to download
    # nix/IHP dependencies each time you update your container.
    volumes:
      - /path/to/app:/home/developer/app
      - /path/to/nix:/nix
```

</details>

<details>
<summary>Incus (using `incus-apply`)</summary>

```yaml
kind: instance
name: ihp
image: ghcr.io:tolvos/ihp-oci:latest
profiles:
  - default
devices:
  preview-proxy:
    listen: tcp:0.0.0.0:8000
    connect: tcp:127.0.0.1:8000
    type: proxy
  ide-proxy:
    listen: tcp:0.0.0.0:8001
    connect: tcp:127.0.0.1:8001
    type: proxy
  hoogle-proxy:
    listen: tcp:0.0.0.0:8002
    connect: tcp:127.0.0.1:8002
    type: proxy

  # Optional: an existing project that you want to save your progress with on the host.
  project:
    path: /home/developer/app
    source: /path/to/app
    type: disk

  # Optional: the /nix directory so you don't need to re-download nix or the project dependencies when updating your
  # container.
  nix:
    path: /nix
    source: /path/to/nix
    type: disk
```

</details>

## Usage

### Logging in

After getting the container up and running, login to the container instance as the `developer` user. Probably more than
a few different ways to do that depending on what container manager you're using, but here's a couple different ways 
I'm aware of (where `ihp` is the name of your container):

- Docker: `docker exec -it --user developer ihp bash --login`
- Incus: `incus exec ihp -- su - developer`

### Creating an IHP app, or reusing an existing project.

Once you're logged in, you can start a new project by doing `ihp-new <project-name>`, or reuse an existing project that
you mounted to the `~/app` folder by just entering the directory normally: `cd app/`.

If you're going the existing project directory route, you'll probably need to do `direnv allow` as prompted before
being able to spin up your environment.

### Updating the OCI container

If you persist your `/nix` folder like in one of the declarative configs above, you may want to do `update-nix` after
logging in as the `developer` user to keep your Nix store updated to the latest flake. This is just a Bash alias that
lives in the `.bash_profile` file that makes it a bit easier.
