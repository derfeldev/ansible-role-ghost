<!--
SPDX-FileCopyrightText: 2025 Pavel Dimov <@sagat79>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Database connection-pool sizing (`ghost_database_pool_min`/`ghost_database_pool_max`)
- Mail "well-known service" shorthand (`ghost_mail_options_service`, e.g. `Mailgun`/`SES`)
- Separate Admin panel URL (`ghost_admin_url`)
- Storage adapter selection for custom-built images (`ghost_storage_active`/`_media`/`_files`)
- Logging level, transports, and rotation configuration (`ghost_logging_*`)
- Built-in Redis cache adapter support (`ghost_cache_redis_*`)
- Image optimization/responsive srcset toggles (`ghost_image_optimization_*`)
- Response compression toggle (`ghost_compress_enabled`)
- Privacy "tinfoil mode" toggle (`ghost_privacy_enabled`)
- Staff device verification toggle (`ghost_security_staff_device_verification_enabled`)
- Self-hosted Portal/Comments/Search front-end script overrides (`ghost_portal_url`, `ghost_comments_url`/`_styles`, `ghost_sodo_search_url`/`_styles`)
- `mise.toml` and `just prek-*` recipes, matching mash-playbook's own dev tooling conventions
- mash-playbook wiring example (systemd_service_manager, MariaDB, exim-relay, redis) in `docs/mash-playbook-integration.md`
- Documented that mash-playbook only ships a `mariadb` role (no real MySQL option), and that MariaDB is
  wire-compatible but not officially supported/tested by the Ghost team — README.md and
  `docs/mash-playbook-integration.md` now call this out explicitly next to the database requirement

### Fixed

- `tasks/validate_config.yml`: the database-password and mail-config checks were accidentally
  outdented out of the validation block, and always ran instead of being scoped along with the
  rest of the config validation
- CI: `deploy-galaxy.yml` (triggered on tag push) never actually ran automatically, because
  `autotag.yml` pushed its tags using the default `GITHUB_TOKEN`, and GitHub Actions doesn't
  re-trigger other workflows for `GITHUB_TOKEN`-authored pushes. `autotag.yml` now checks out
  and pushes using `secrets.PERSONAL_ACCESS_TOKEN` so the tag push correctly fires
  `deploy-galaxy.yml`. Removed `autotag-deploy.yml`, which duplicated `autotag.yml`'s tagging
  logic (risking a tag-name race on every push to `main`) and also published to Ansible Galaxy
  unconditionally on every push, independent of tagging.

### Changed

- **BREAKING**: Removed PostgreSQL support - Ghost officially supports only MySQL 8
- Database configuration simplified to MySQL-only
- Updated documentation to reflect MySQL-only support
- Removed `ghost_database_type` variable (no longer needed)

### Migration Guide

#### From Previous Versions with PostgreSQL Support

**Breaking Change**: PostgreSQL support has been removed as Ghost CMS officially supports only MySQL 8 for production environments.

##### Previous Configuration (with PostgreSQL support)

```yaml
ghost_database_type: 'postgres'  # ← This is no longer supported
ghost_database_hostname: 'localhost'
ghost_database_port: 5432
ghost_database_username: 'ghost'
ghost_database_password: 'password'
ghost_database_name: 'ghost'
```

##### New Configuration (MySQL only)

```yaml
ghost_database_hostname: 'localhost'
ghost_database_port: 3306  # Optional: defaults to 3306
ghost_database_username: 'ghost'
ghost_database_password: 'password'
ghost_database_name: 'ghost'
```

##### Migration Steps

1. **Remove `ghost_database_type` variable** - it's no longer needed
2. **Update database port** to 3306 (MySQL default) if using PostgreSQL
3. **Migrate data** from PostgreSQL to MySQL if needed
4. **Test the configuration**:

   ```bash
   ansible-playbook your-playbook.yml --check
   ```

##### Important Notes

- **Ghost CMS officially supports only MySQL 8** for production environments
- PostgreSQL support was dropped in Ghost 1.0 (2017)
- This change aligns the Ansible role with Ghost's official database support
- **Data migration required**: If you were using PostgreSQL, you'll need to migrate your data to MySQL

##### Mash-playbook Integration

For mash-playbook users, use MySQL integration:

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

## [Previous Versions]

### [1.0.0] - Initial Release

- Initial Ghost role implementation
- MySQL database support
- Docker container deployment
- Systemd service integration
- Mash-playbook compatibility
