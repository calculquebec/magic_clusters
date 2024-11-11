For this workshops, participants needs to have an ssh key created before the workshop happens.

From the main account, on the login node, run:
```bash

for TMP_USER in user{01..50} helper{1..4} instructor;
do
  echo $TMP_USER:
  sudo su - $TMP_USER -c 'ssh-keygen -t ed25519 -C $USER@$USER.org -N "" -f ~/.ssh/id_ed25519'
done
```
