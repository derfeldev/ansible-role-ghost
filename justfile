# SPDX-FileCopyrightText: 2025 Pavel Dimov <@sagat79>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# mise (dev tool version manager)
mise_data_dir := env("MISE_DATA_DIR", justfile_directory() / "var/mise")
mise_trusted_config_paths := justfile_directory() / "mise.toml"
prek_home := env("PREK_HOME", justfile_directory() / "var/prek")

# show help by default
default:
    @{{ just_executable() }} --list --justfile {{ justfile() }}

lint:
    ansible-lint .

# Invokes mise with the project-local data directory
mise *args: _ensure_mise_data_directory
    #!/bin/sh
    export MISE_DATA_DIR="{{ mise_data_dir }}"
    export MISE_TRUSTED_CONFIG_PATHS="{{ mise_trusted_config_paths }}"
    export MISE_YES=1
    export PREK_HOME="{{ prek_home }}"
    mise {{ args }}

# Runs pre-commit hooks on staged files
prek-run-on-staged *args: _ensure_mise_tools_installed
    @{{ just_executable() }} --justfile {{ justfile() }} mise exec -- prek run {{ args }}

# Runs pre-commit hooks on all files
prek-run-on-all *args: _ensure_mise_tools_installed
    @{{ just_executable() }} --justfile {{ justfile() }} mise exec -- prek run --all-files {{ args }}

# Installs the git pre-commit hook
prek-install-git-hook: _ensure_mise_tools_installed
    @{{ just_executable() }} --justfile {{ justfile() }} mise exec -- prek install

# Internal - ensures var/mise and var/prek directories exist
_ensure_mise_data_directory:
    @mkdir -p "{{ mise_data_dir }}"
    @mkdir -p "{{ prek_home }}"

# Internal - ensures mise tools are installed
_ensure_mise_tools_installed: _ensure_mise_data_directory
    @{{ just_executable() }} --justfile {{ justfile() }} mise install --quiet
