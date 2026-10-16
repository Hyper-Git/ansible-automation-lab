# webserver role

Installs and configures nginx on Ubuntu, creates a service user and working directory, deploys a simple homepage and hides the nginx version from response headers.

## What it does

1. Installs nginx (apt cache refreshed only if older than one hour)
2. Ensures nginx is running and enabled at boot
3. Ensures the service user exists, with a bash shell and a home directory
4. Ensures the working directory exists, owned by the service user, mode `0755`
5. Writes `/var/www/html/index.html` showing which host was configured
6. Sets `server_tokens off` in `/etc/nginx/nginx.conf` with `lineinfile`, validated with `nginx -t` before the file is written
7. Reloads nginx through a handler, only when the config changed

## Requirements

- Ubuntu target (uses `apt`)
- Privilege escalation (`become: true`)

## Role variables

Defined in `defaults/main.yml`, so they can be overridden from inventory or the playbook:

| Variable | Default | Purpose |
|---|---|---|
| `web_package` | `nginx` | Package and service name |
| `ops_user` | `opsbot` | Service user |
| `ops_dir` | `/opt/ops-lab` | Working directory owned by `ops_user` |

## Handlers

- `Reload nginx`: reloads the service when notified

## Example playbook

```yaml
- name: Configure Web Servers
  hosts: webservers
  become: true
  roles:
    - webserver
```

## Author

Cornel Bacanu. Part of [ansible-automation-lab](../../README.md).
