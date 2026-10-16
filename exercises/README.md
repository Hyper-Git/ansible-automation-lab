# Exercises

Short practice playbooks written from plain-English tickets, without a guide.
Each one was dry-run, run for real, verified with Linux commands, then re-run to confirm idempotency.

Target: `localhost` (WSL Ubuntu), using `become` for privileged tasks.

## setup-deploy.yaml

**Ticket:** Create a user `deploy` and make sure `/opt/app` exists, owned by `deploy`.

- Modules: `ansible.builtin.user`, `ansible.builtin.file`
- Verified with `id deploy` and `ls -ld /opt/app` (`deploy:deploy`)
- **Idempotency:** second run reports `changed=0`
- **Drift correction:** manually ran `sudo chown root /opt/app`; the next run reported `changed=1` on the file task only and restored `deploy` as owner
- Lesson: Ansible only manages what you declare. Without `group: deploy` the directory kept the `root` group it was created with under `become`

## remove-deploy.yaml

**Ticket:** Remove the `deploy` user and `/opt/app`.

- Tasks run in reverse order of creation (directory first, then user), so no files are left owned by a deleted user
- `remove: true` on the user module also deletes `/home/deploy`
- Verified: `id deploy` returns "no such user"; `/opt/app` and `/home/deploy` no longer exist
- **Idempotency:** second run reports `changed=0`
- Safety: destructive playbook targets a single host. Check scope with `--list-hosts` before running

## Run

```bash
ansible-playbook exercises/setup-deploy.yaml --check -K   # dry run
ansible-playbook exercises/setup-deploy.yaml -K
ansible-playbook exercises/remove-deploy.yaml --list-hosts
ansible-playbook exercises/remove-deploy.yaml -K
```

