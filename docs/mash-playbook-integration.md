# Ghost Role for Mash-Playbook

This Ghost Ansible role has been adapted for integration with the [mash-playbook](https://github.com/mother-of-all-self-hosting/mash-playbook) and supports exim-relay email functionality.

## Mash-Playbook Integration

When used as part of the mash-playbook, this role integrates with the `exim_relay` role to provide email functionality for Ghost.

### Configuration

To enable mash-playbook integration, set the following variables:

```yaml
# Enable mash-playbook integration
mash_playbook_enabled: true
mash_playbook_role_name: 'exim_relay'

# Enable exim-relay integration
exim_relay_enabled: true
exim_relay_smtp_host: 'localhost'
exim_relay_smtp_port: 587
exim_relay_smtp_username: 'ghost@yourdomain.com'
exim_relay_smtp_password: 'your_password'
exim_relay_smtp_tls: true
exim_relay_from_email: 'ghost@yourdomain.com'
exim_relay_from_name: 'Ghost Blog'
```

### Exim-Relay Integration

When `exim_relay_enabled` is set to `true`, the role automatically configures Ghost to use the exim-relay service for sending emails. This includes:

- SMTP configuration
- Authentication settings
- TLS/SSL settings
- From email and name configuration

### Dependencies

This role depends on the following mash-playbook roles when `mash_playbook_enabled` is `true`:

- `exim_relay` - For email relay functionality

### Usage in Mash-Playbook

Add this role to your mash-playbook configuration:

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

### Email Configuration

The role automatically configures Ghost's email settings when exim-relay is enabled:

- **Transport**: SMTP
- **Host**: Uses `exim_relay_smtp_host`
- **Port**: Uses `exim_relay_smtp_port` (default: 587)
- **Security**: Uses `exim_relay_smtp_tls` (default: true)
- **Authentication**: Uses `exim_relay_smtp_username` and `exim_relay_smtp_password`
- **From**: Uses `exim_relay_from_email` and `exim_relay_from_name`

### Validation

The role includes validation for exim-relay configuration:

- Ensures SMTP host is set when exim-relay is enabled
- Ensures SMTP username is set when exim-relay is enabled
- Ensures SMTP password is set when exim-relay is enabled
- Ensures from email is set when exim-relay is enabled

### Standalone Usage

When `mash_playbook_enabled` is `false` (default), the role functions as a standalone Ghost role without exim-relay integration, maintaining backward compatibility with existing configurations.
