<!--
SPDX-FileCopyrightText: 2025 Pavel Dimov <@sagat79>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Ghost Ansible role

This is an [Ansible](https://www.ansible.com/) role which installs [Ghost](https://ghost.org/) to run as a [Docker](https://www.docker.com/) container wrapped in a systemd service.

This role *implicitly* depends on:

- [`com.devture.ansible.role.playbook_help`](https://github.com/devture/com.devture.ansible.role.playbook_help)
- [`com.devture.ansible.role.systemd_docker_base`](https://github.com/devture/com.devture.ansible.role.systemd_docker_base)

Check [defaults/main.yml](defaults/main.yml) for the full list of supported options.

## Mash-Playbook Integration

This role supports integration with the [mash-playbook](https://github.com/mother-of-all-self-hosting/mash-playbook) and includes exim-relay email functionality. See [docs/mash-playbook-integration.md](docs/mash-playbook-integration.md) for detailed integration instructions.

### Quick Start for Mash-Playbook

```yaml
- role: ghost
  vars:
    mash_playbook_enabled: true
    exim_relay_enabled: true
    exim_relay_smtp_host: 'localhost'
    exim_relay_smtp_username: 'ghost@yourdomain.com'
    exim_relay_smtp_password: '{{ vault_ghost_email_password }}'
    exim_relay_from_email: 'ghost@yourdomain.com'
    exim_relay_from_name: 'Ghost Blog'
    ghost_hostname: 'blog.yourdomain.com'
    ghost_database_hostname: 'localhost'
    ghost_database_password: '{{ vault_ghost_db_password }}'
```

## Development

You can optionally install [pre-commit](https://pre-commit.com/) so that simple mistakes are checked and noticed before changes are pushed to a remote branch. See [`.pre-commit-config.yaml`](./.pre-commit-config.yaml) for which hooks are to be executed.

See [this section](https://pre-commit.com/#usage) on the official documentation for usage.
