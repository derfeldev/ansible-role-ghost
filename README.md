<!--
SPDX-FileCopyrightText: 2025 Pavel Dimov <@sagat79>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Ghost Ansible role

This is an [Ansible](https://www.ansible.com/) role which installs [Ghost](https://ghost.org/) to run as a [Docker](https://www.docker.com/) container wrapped in a systemd service.

## This service requires the following other services

- **Database Service**: A MySQL-protocol database is required for storing Ghost content and configuration data.
  Ghost officially supports only **MySQL 8** for production — MariaDB is *not* an officially supported or
  tested substitute. It works in practice for most installs (MariaDB is wire-compatible, and this role sets
  `database.client=mysql`), but Ghost's team doesn't test against it, and there are known edge cases (JSON
  column handling, full-text search, some generated SQL assuming genuine MySQL 8 semantics) where MariaDB can
  diverge. If you're wiring this role into [mash-playbook](https://github.com/mother-of-all-self-hosting/mash-playbook),
  note that it only ships a `mariadb` role — there's no real-MySQL option there — so you're accepting that
  risk unless you run your own MySQL 8 instance outside the playbook and point `ghost_database_hostname` at
  it directly.
- **Reverse Proxy**: A reverse proxy server (such as Nginx or Traefik) is recommended for serving web requests and handling SSL termination.
- **SMTP Service**: An SMTP server is needed for sending emails when mail functionality is enabled.
- **Redis** (optional): Only needed if you enable the Redis cache adapter (`ghost_cache_redis_enabled`).

This role *implicitly* depends on:

- [`com.devture.ansible.role.playbook_help`](https://github.com/devture/com.devture.ansible.role.playbook_help)
- [`com.devture.ansible.role.systemd_docker_base`](https://github.com/devture/com.devture.ansible.role.systemd_docker_base)

Check [defaults/main.yml](defaults/main.yml) for the full list of supported options.

See [CHANGELOG.md](CHANGELOG.md) for migration guide and breaking changes.

## Supported Ghost functionality

Besides the core install (database, mail, Traefik-ready reverse-proxy labels, HSTS/CSP headers),
this role exposes the following parts of [Ghost's configuration surface](https://ghost.org/docs/config/):

- Database connection-pool sizing (`ghost_database_pool_min`/`ghost_database_pool_max`)
- Mail via generic SMTP or a nodemailer "well-known service" shorthand (`ghost_mail_options_service`, e.g. `Mailgun`/`SES`)
- A separate Admin panel URL (`ghost_admin_url`)
- Storage adapter selection (`ghost_storage_active`/`_media`/`_files`) for custom-built images that ship a non-local storage adapter (e.g. S3-compatible)
- Logging level, transports, and rotation (`ghost_logging_*`)
- The built-in Redis cache adapter (`ghost_cache_redis_*`), useful for multi-instance setups
- Image optimization/responsive srcset generation toggles (`ghost_image_optimization_*`)
- Response compression (`ghost_compress_enabled`)
- "Tinfoil mode" privacy (`ghost_privacy_enabled`), disabling external calls (update checks, Gravatar, etc.)
- Staff sign-in device verification (`ghost_security_staff_device_verification_enabled`)
- Self-hosting the Portal/Comments/Search front-end scripts instead of loading them from the jsdelivr CDN (`ghost_portal_url`, `ghost_comments_url`/`_styles`, `ghost_sodo_search_url`/`_styles`)

Anything not covered by a dedicated variable (e.g. `spam`, `caching`, `klipy`, `opensea`, `twitter`, milestones)
can still be set via `ghost_environment_variables_additional_variables`, using Ghost's `__`-separated env var
naming convention documented at <https://ghost.org/docs/config/>.

## Mash-Playbook Integration

This role supports integration with the [mash-playbook](https://github.com/mother-of-all-self-hosting/mash-playbook) and includes email functionality. See [docs/mash-playbook-integration.md](docs/mash-playbook-integration.md) for detailed integration instructions.

### Quick Start for Mash-Playbook

```yaml
- role: ghost
  vars:
    ghost_mail_enabled: true
    ghost_mail_options_host: 'localhost'
    ghost_mail_options_auth_user: 'ghost@yourdomain.com'
    ghost_mail_options_auth_pass: '{{ vault_ghost_email_password }}'
    ghost_mail_from: 'ghost@yourdomain.com'
    ghost_mail_from_name: 'Ghost Blog'
    ghost_hostname: 'blog.yourdomain.com'
    ghost_database_hostname: 'localhost'
    ghost_database_password: '{{ vault_ghost_db_password }}'
```

## Development

You can optionally install [pre-commit](https://pre-commit.com/) so that simple mistakes are checked and noticed before changes are pushed to a remote branch. See [`.pre-commit-config.yaml`](./.pre-commit-config.yaml) for which hooks are to be executed.

See [this section](https://pre-commit.com/#usage) on the official documentation for usage.
