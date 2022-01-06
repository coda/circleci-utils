# CircleCI Utils

[![CircleCI Build Status](https://circleci.com/gh/coda/circleci-utils.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/coda/circleci-utils) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/coda/utils)](https://circleci.com/orbs/registry/orb/coda/utils) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/coda/circleci-utils/main/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

[Example Usage](src/examples/example.yml)

### How to Publish

- Create and push a branch with your new features.
- When ready to publish a new production version, create a Pull Request from fore _feature branch_ to `main`.
- The title of the pull request must contain a special semver tag: `[semver:<segement>]` where `<segment>` is replaced by one of the following values.

| Increment | Description                       |
| --------- | --------------------------------- |
| major     | Issue a 1.0.0 incremented release |
| minor     | Issue a x.1.0 incremented release |
| patch     | Issue a x.x.1 incremented release |
| skip      | Do not issue a release            |

Example: `[semver:major]`

- Squash and merge. Ensure the semver tag is preserved and entered as a part of the commit message.
- On merge, after manual approval, the orb will automatically be published to the Orb Registry.

### How to Publish Dev Version

Push your branch and CI will trigger dev published version of orb with the commit hash as the version.

### How to Publish Dev VersionManually

To manually pack your `orb.yml`, you can run `circleci orb pack . > orb.yml` at the `@orb.yml` level.

```
cd src
circleci orb pack .  > orb.yml
circleci orb publish orb.yml coda/utils@dev:<your_branch_name> --token <orb publishing token>
```

## Orb Authoring Tips:

- scripts are files that can be inlined into the yaml file using the following format `command: <<include(scripts/greet.sh)>>`. scripts must be logical code that can be executed in a CircleCI YAML file.
  -- commands[https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands] may only be used as part of the sequence under steps in a job. commands must use the same

## Used in Following Repos:


- infra
- headless-chrome
- coda
* pipenv, curl, jq required