<!--
SPDX-FileCopyrightText: 2025 Pavel Dimov <@sagat79>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Ghost role for the MASH playbook

This Ghost Ansible role has been adapted for integration with the [mash-playbook](https://github.com/mother-of-all-self-hosting/mash-playbook) and supports email functionality.

**Important**: See [CHANGELOG.md](../CHANGELOG.md) for migration guide and breaking changes.

## This service requires the following other services

- **Database Service**: A MySQL 8 database is required for storing Ghost content and configuration data. Ghost officially supports only MySQL 8 for production environments.
- **Reverse Proxy**: A reverse proxy server (such as Nginx or Traefik) is recommended for serving web requests and handling SSL termination.
- **SMTP Service**: An SMTP server is needed for sending emails when mail functionality is enabled.

## MASH playbook integration

When used as part of the mash-playbook, this role integrates with email services to provide email functionality for Ghost.

### Configuration

To enable mash-playbook integration, set the following variables:

```yaml
# Enable mail functionality
ghost_mail_enabled: true
ghost_mail_transport: 'SMTP'
ghost_mail_options_host: 'localhost'
ghost_mail_options_port: 587
ghost_mail_options_secure: true
ghost_mail_options_auth_user: 'ghost@mta.example.com'
ghost_mail_options_auth_pass: 'your_password'
ghost_mail_from: 'ghost@mta.example.com'
ghost_mail_from_name: 'Ghost Blog'
```

### Email integration

When `ghost_mail_enabled` is set to `true`, the role automatically configures Ghost to use SMTP for sending emails. This includes:

- SMTP configuration
- Authentication settings
- TLS/SSL settings
- From email and name configuration

### Usage with the MASH playbook

Add this role to your mash-playbook configuration:

```yaml
- role: ghost
  vars:
    ghost_mail_enabled: true
    ghost_mail_options_host: 'localhost'
    ghost_mail_options_auth_user: 'ghost@mta.example.com'
    ghost_mail_options_auth_pass: '{{ vault_ghost_email_password }}'
    ghost_mail_from: 'ghost@mta.example.com'
    ghost_mail_from_name: 'Ghost Blog'
    ghost_hostname: 'blog.example.com'
    ghost_database_hostname: 'localhost'
    ghost_database_password: '{{ vault_ghost_db_password }}'
```

### Email configuration

The role automatically configures Ghost's email settings when mail is enabled:

- **Transport**: SMTP
- **Host**: Uses `ghost_mail_options_host`
- **Port**: Uses `ghost_mail_options_port` (default: 587)
- **Security**: Uses `ghost_mail_options_secure` (default: true)
- **Authentication**: Uses `ghost_mail_options_auth_user` and `ghost_mail_options_auth_pass`
- **From**: Uses `ghost_mail_from` and `ghost_mail_from_name`

### Validation

The role includes validation for mail configuration:

- Ensures SMTP host is set when mail is enabled
- Ensures SMTP username is set when mail is enabled
- Ensures SMTP password is set when mail is enabled
- Ensures from email is set when mail is enabled

### Standalone Usage

When `ghost_mail_enabled` is `false` (default), the role functions as a standalone Ghost role without email integration, maintaining backward compatibility with existing configurations.

## Wiring this role into mash-playbook's `templates/group_vars_mash_servers`

This role is not (yet) part of the official mash-playbook `supported-services.md` list. To use it with
mash-playbook, add it locally under `templates/` (not the generated root-level files) following
[mash-playbook's developer documentation](https://github.com/mother-of-all-self-hosting/mash-playbook/blob/master/docs/developer-documentation.md):

1. Add an entry to `templates/requirements.yml`:

   ```yaml
   - src: git+https://github.com/derfeldev/ansible-role-ghost.git
     version: 6.52.1-0  # use the latest tag; mash-playbook role tags don't use a "v" prefix here
     name: ghost
     activation_prefix: ghost_
   ```

2. Add a role entry to `templates/setup.yml`:

   ```yaml
   # role-specific:ghost
   - when: ghost_enabled | bool
     role: galaxy/ghost
     tags:
       - setup-ghost
       - setup-all
       - install-ghost
       - install-all
   # /role-specific:ghost
   ```

3. Wire it in `templates/group_vars_mash_servers` — register with `systemd_service_manager`, MariaDB,
   optionally `exim-relay` for mail, and optionally the bundled `redis` role for the Redis cache adapter:

   > [!WARNING]
   > mash-playbook only ships a `mariadb` role — there is no real-MySQL option in this playbook. Ghost
   > officially supports only MySQL 8 in production; MariaDB is wire-compatible (this role sets
   > `database.client=mysql`) and works for most installs, but isn't tested or supported by the Ghost team,
   > and has known edge cases (JSON columns, full-text search, some generated SQL). Wiring to `mariadb` below
   > is what most self-hosters do, but it's an accepted risk, not an officially blessed setup. If you want a
   > guaranteed-supported database, run MySQL 8 yourself outside the playbook and point
   > `ghost_database_hostname` at it instead of `mariadb_connection_hostname`.

   ```yaml
   # role-specific:systemd_service_manager
   mash_playbook_devture_systemd_service_manager_services_list_auto_itemized:
     [...]
     # role-specific:ghost
     - |-
       {{ ({'name': (ghost_identifier + '.service'), 'priority': 2000, 'groups': ['mash', 'ghost']} if ghost_enabled else omit) }}
     # /role-specific:ghost
   # /role-specific:systemd_service_manager

   # role-specific:mariadb
   mash_playbook_mariadb_managed_databases_auto_itemized:
     [...]
     # role-specific:ghost
     - |-
       {{
         ({
           'name': ghost_database_name,
           'username': ghost_database_username,
           'password': ghost_database_password,
         } if ghost_enabled else omit)
       }}
     # /role-specific:ghost
   # /role-specific:mariadb

   # role-specific:ghost
   ghost_uid: "{{ mash_playbook_uid }}"
   ghost_gid: "{{ mash_playbook_gid }}"

   ghost_systemd_required_services_list_auto: |
     {{
       ([mariadb_identifier ~ '.service'] if mariadb_enabled and ghost_database_hostname == mariadb_connection_hostname else [])
       +
       ([redis_identifier ~ '.service'] if redis_enabled and ghost_cache_redis_enabled and ghost_cache_redis_host == redis_connection_hostname else [])
     }}

   ghost_container_additional_networks_auto: |
     {{
       ([mariadb_container_network] if mariadb_enabled and ghost_database_hostname == mariadb_connection_hostname and ghost_container_network != mariadb_container_network else [])
       +
       ([redis_container_network] if redis_enabled and ghost_cache_redis_enabled and ghost_cache_redis_host == redis_connection_hostname and ghost_container_network != redis_container_network else [])
     }}

   # role-specific:mariadb
   ghost_database_hostname: "{{ mariadb_connection_hostname if mariadb_enabled else '' }}"
   ghost_database_port: "{{ mariadb_connection_port if mariadb_enabled else 3306 }}"
   ghost_database_username: "{{ ghost_identifier }}"
   ghost_database_password: "{{ (mash_playbook_generic_secret_key + ':db.ghost') | hash('sha512') | to_uuid }}"
   # /role-specific:mariadb

   # role-specific:redis (optional, for ghost_cache_redis_enabled)
   ghost_cache_redis_host: "{{ redis_connection_hostname if (redis_enabled and ghost_cache_redis_enabled) else '' }}"
   ghost_cache_redis_port: "{{ redis_connection_port if redis_enabled else 6379 }}"
   # /role-specific:redis

   # role-specific:exim_relay (optional, for ghost_mail_enabled)
   ghost_mail_enabled: "{{ exim_relay_enabled | default(false) }}"
   ghost_mail_options_host: "{{ exim_relay_identifier if exim_relay_enabled | default(false) else '' }}"
   ghost_mail_options_port: 8025
   ghost_mail_options_secure: false
   ghost_mail_from: "{{ exim_relay_sender_address if exim_relay_enabled | default(false) else '' }}"
   ghost_mail_from_name: "Ghost"
   ghost_systemd_wanted_services_list_auto: |
     {{
       ([exim_relay_identifier ~ '.service'] if exim_relay_enabled | default(false) else [])
     }}
   # /role-specific:exim_relay
   # /role-specific:ghost
   ```

   Note: `exim-relay` doesn't require SMTP authentication, so `ghost_mail_options_auth_user`/`_auth_pass`
   would need to stay unset in that case — adjust `tasks/validate_config.yml`'s mail checks accordingly if
   you rely purely on `exim-relay`, or keep using a real SMTP provider's credentials instead.

4. Add `docs/services/ghost.md` and a row in `docs/supported-services.md` if you plan to upstream this role.
