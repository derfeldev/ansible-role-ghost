<!--
SPDX-FileCopyrightText: 2025 Pavel Dimov <@sagat79>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Ghost Role for Mash-Playbook

This Ghost Ansible role has been adapted for integration with the [mash-playbook](https://github.com/mother-of-all-self-hosting/mash-playbook) and supports email functionality.

## This service requires the following other services:

- **Database Service**: A MySQL or PostgreSQL database is required for storing Ghost content and configuration data.
- **Reverse Proxy**: A reverse proxy server (such as Nginx or Traefik) is recommended for serving web requests and handling SSL termination.
- **SMTP Service**: An SMTP server is needed for sending emails when mail functionality is enabled.

## Mash-Playbook Integration

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
ghost_mail_options_auth_user: 'ghost@yourdomain.com'
ghost_mail_options_auth_pass: 'your_password'
ghost_mail_from: 'ghost@yourdomain.com'
ghost_mail_from_name: 'Ghost Blog'
```

### Email Integration

When `ghost_mail_enabled` is set to `true`, the role automatically configures Ghost to use SMTP for sending emails. This includes:

- SMTP configuration
- Authentication settings
- TLS/SSL settings
- From email and name configuration

### Usage in Mash-Playbook

Add this role to your mash-playbook configuration:

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

### Email Configuration

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
