<!--
SPDX-FileCopyrightText: 2025 Pavel Dimov <@sagat79>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
