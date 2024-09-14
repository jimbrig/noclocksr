---
editor_options: 
  markdown: 
    wrap: 72
---

# Configuration

> [!NOTE] This folder houses `yml` configuration files used by No
> Clocks, LLC.

## Files

-   `config.yml`: root configuration file used. This file is included in
    `.gitignore` so it must be created by decrypting
    `config.encrypted.yml` first via `noclocksr::decrypt_cfg_file()`
    (automatically handled via the pre-configured
    [git-hooks](./../templates/git-hooks/)).

-   `config.encrypted.yml`: encrypted version of `config.yml` to include
    in git.

-   `config.template.yml`: Template configuration file used as reference
    for setting up `config.yml`. Created via
    `noclocksr::create_cfg_template()`.

-   `config.schema.json`: JSON schema file used to validate `config.yml`
    via `noclocksr::validate_cfg_file()`.

-   `config.merged.yml`: Merged configuration file used to store the
    final configuration after merging the base `config.yml` with any
    extra configs under [config.d/](config.d/).

-   `config.merged.encrypted.yml`: Encrypted version of
    `config.merged.yml` to include in git.

-   `config.d/`: Folder to house extra configuration files to merge with
    `config.yml`. Files in this folder should be named with the
    following format: `config.<name>.yml`. These files are automatically
    merged with `config.yml` via `noclocksr::merge_cfg_files()`.

    -   `config.d/config.ai.yml`: Configuration file with secrets
        associated with `ai` services and tools.
    -   etc.
