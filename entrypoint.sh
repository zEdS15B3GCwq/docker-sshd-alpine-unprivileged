#!/bin/ash

# Create user if necessary
if ! id user &>/dev/null; then
  echo creating user:user
  addgroup --gid $USER_GID user
  adduser --uid $USER_UID  --ingroup user --disabled-password user
  passwd -u user
fi

# make sure user has an .ssh folder
if [[ ! -d /home/user/.ssh ]]; then
  mkdir -p /home/user/.ssh &>/dev/null
  chown user:user /home/user/.ssh
  chmod 700 /home/user/.ssh
fi

# If backup exists, copy from there, otherwise create new
if [[ -d $BACKUP_DIR/etc/ssh ]] && [[ -d $BACKUP_DIR/home/user/.ssh ]]; then
  echo copying keys from backup
  cp --force $BACKUP_DIR/etc/ssh/ssh_host_*_key* /etc/ssh/
  cp --force $BACKUP_DIR/home/user/.ssh/* /home/user/.ssh/
  chown user:user /home/user/.ssh/*

else
  echo no backup found, generating keys

  # generate host keys if not present
  ssh-keygen -A

  # generate user keys
  ssh-keygen -q -f /home/user/.ssh/user_rsa -t rsa -N "" -C "RSA for container user"
  ssh-keygen -q -f /home/user/.ssh/user_ed25519 -t ed25519 -N "" -C "ED25519 for container user"
  cat /home/user/.ssh/user_rsa.pub > /home/user/.ssh/authorized_keys
  cat /home/user/.ssh/user_ed25519.pub >> /home/user/.ssh/authorized_keys
  chown user:user /home/user/.ssh/*
  chmod 600 /home/user/.ssh/*
  chmod 644 /home/user/.ssh/*.pub

  # make backup if possible
  if [[ -d $BACKUP_DIR ]] && [[ -w $BACKUP_DIR ]]; then
    echo copying keys to backup
    mkdir -p $BACKUP_DIR/etc/ssh $>/dev/null
    mkdir -p $BACKUP_DIR/home/user/.ssh $>/dev/null
    cp --force /etc/ssh/ssh_host_*_key* $BACKUP_DIR/etc/ssh/
    cp --force /home/user/.ssh/* $BACKUP_DIR/home/user/.ssh/
  fi

fi

# Start SSH service; do not detach (-D), log to stderr (-e), passthrough other arguments
echo starting SSH server
exec /usr/sbin/sshd -D -e "$@"
