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
- PostgreSQL database support via `ghost_database_type` variable
- Configurable database port based on database type (3306 for MySQL, 5432 for PostgreSQL)
- Database type validation in configuration validation tasks
- Mash-playbook integration documentation with PostgreSQL examples

### Changed
- Database client configuration is now dynamic based on `ghost_database_type`
- Default database port is now conditional (3306 for MySQL, 5432 for PostgreSQL)
- Documentation updated to reflect PostgreSQL support

### Migration Guide

#### From Previous Versions

**Breaking Change**: Database configuration has been updated to support both MySQL and PostgreSQL.

##### Old Configuration (MySQL only)
```yaml
ghost_database_hostname: 'localhost'
ghost_database_port: 3306
ghost_database_username: 'ghost'
ghost_database_password: 'password'
ghost_database_name: 'ghost'
```

##### New Configuration (MySQL)
```yaml
ghost_database_type: 'mysql'  # Required: specify database type
ghost_database_hostname: 'localhost'
ghost_database_port: 3306  # Optional: defaults to 3306 for MySQL
ghost_database_username: 'ghost'
ghost_database_password: 'password'
ghost_database_name: 'ghost'
```

##### New Configuration (PostgreSQL)
```yaml
ghost_database_type: 'postgres'  # Required: specify database type
ghost_database_hostname: 'localhost'
ghost_database_port: 5432  # Optional: defaults to 5432 for PostgreSQL
ghost_database_username: 'ghost'
ghost_database_password: 'password'
ghost_database_name: 'ghost'
```

##### Migration Steps

1. **Add the required `ghost_database_type` variable**:
   - For MySQL: `ghost_database_type: 'mysql'`
   - For PostgreSQL: `ghost_database_type: 'postgres'`

2. **Optional: Update port configuration**:
   - MySQL: `ghost_database_port: 3306` (default)
   - PostgreSQL: `ghost_database_port: 5432` (default)
   - The port will be automatically set based on `ghost_database_type` if not specified

3. **Test the configuration**:
   ```bash
   ansible-playbook your-playbook.yml --check
   ```

##### Backward Compatibility

- **MySQL configurations**: Add `ghost_database_type: 'mysql'` to maintain current behavior
- **Existing playbooks**: Will continue to work with MySQL after adding the database type variable
- **No data migration required**: This is a configuration change only

##### Mash-playbook Integration

For mash-playbook users, you can now use either:

**MySQL Integration**:
```yaml
- role: ghost
  vars:
    ghost_database_type: 'mysql'
    # ... other MySQL configuration
```

**PostgreSQL Integration** (with ansible-role-postgres):
```yaml
- role: ghost
  vars:
    ghost_database_type: 'postgres'
    # ... other PostgreSQL configuration
```

## [Previous Versions]

### [1.0.0] - Initial Release
- Initial Ghost role implementation
- MySQL database support
- Docker container deployment
- Systemd service integration
- Mash-playbook compatibility
