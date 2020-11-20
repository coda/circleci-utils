# scripts/

This is where any scripts you wish to include in your orb can be kept. This is encouraged to ensure your orb can have all aspects tested, and is easier to author, since we sacrifice most features an editor offers when editing scripts as text in YAML.

As a part of keeping things seperate, it is encouraged to use environment variables to pass through parameters, rather than using the `<< parameter. >>` syntax that CircleCI offers.

# Including Scripts

Utilizing the `circleci orb pack` CLI command, it is possible to import files (such as _shell scripts_), using the `<<include(scripts/script_name.sh)>>` syntax in place of any config key's value.

```yaml

# commands/notify.yml
description: >
  This command echos "Hello World" using file inclusion.
parameters:
  CODA_API_TOKEN:
    type: env_var
    default: STAGING_CODA_TOKEN
    description: "Token to fetch document data"
steps:
  - run:
      environment:
        CODA_API_TOKEN: <<parameters.CODA_API_TOKEN>
      name: Fetch the necessary user information
      command: <<include(scripts/get_lkg_hash.sh)>>

```

