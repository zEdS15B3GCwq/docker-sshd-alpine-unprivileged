# docker-sshd-alpine-unprivileged
*Alpine-based SSH server docker image that automatically creates an unprivileged user for access.*

Available on [Docker hub](https://hub.docker.com/repository/docker/tomzi/sshd-alpine-unprivileged) and [GitHub](https://github.com/zEdS15B3GCwq/docker-sshd-alpine-unprivileged).

The purpose of this image is to have a lightweight (Alpine-based) SSH server that can be accessed with an unprivileged (non-root) account and does most configuration steps automatically. Host and user keys (can) persist to avoid host key mismatch and other nuisances on container restart.

Example use case: deployed on a *TrueNAS Scale* server for some CLI activities that do not require root. Doing that through an unprivileged account feels safer, and the need for minimal configuration is also helpful. AFAIK, containers cannot be built from the TrueNAS UI, so I used an entrypoint script + environment variables for configuration.

## Main points

- Most configuration steps take place in the *Entrypoint* script.
- User `user` is created; default 2000:2000 unless changed by environment variables `USER_UID` and `USER_GID`.
- SSH Host keys, and RSA and ed25519 keys for `user` are generated.
- Host and user keys are copied to `$BACKUP_FOLDER` folder, if mounted in.
- If backup is present in `$BACKUP_FOLDER`, keys are copied to relevant locations instead of generating new ones.

## Basic usage

```
docker run --rm -d -p 2222:22 -v `pwd`/backup:/backup tomzi/sshd-alpine-unprivileged:latest
```

Creates host keys, a user named `user` with IDs 2000:2000, RSA and ED25519 keys for user, and stores keys in `/backup`. Container can be accessed via SSH on port 2222, with private keys in `backup/home/user/.ssh`. Password and Root access is disabled. Mounted backup folder can be a *volume*, *bind mount*, etc. Subsequent runs of the container can use the same command line; keys are not generated again but taken from the backup folder.

```
ssh user@localhost -p 2222 -i backup/home/user/.ssh/user_ed25519
```

Connects to SSH server using private key from backup folder. Note that the owner of the key files is *root* and it has access rights 600; change ownership etc. if above command is not run as *root*.

## Customisation:

### Runtime environment variables:

1. USER_UID, USER_GID: Create user `user` with these uid and gid.
2. BACKUP_DIR: where the backup target is mounted

These are used by the *entrypoint* script on the first run.

```
docker run --rm -d -p 2222:22 -v `pwd`/backup:/config tomzi/ -e USER_UID=3000 -e USER_GID=3000 -e BACKUP_FOLDER=/config sshd-alpine-unprivileged:latest
```

Specifies a different UID, GID and backup folder path.

### Runtime SSHd parameters

Parameters can be passed to `sshd` on run.

```
docker run --rm -d -p 2222:22 -v `pwd`/backup:/backup tomzi/sshd-alpine-unprivileged:latest -o LogLevel=DEBUG
```

## Develop:

Build:

```
docker build --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -t sshd-alpine-unprivileged:latest .
```

## Acknowledgments:

Based on https://github.com/trashpanda001/docker-alpine-sshd.