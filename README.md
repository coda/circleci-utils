
# CircleCI Utils


[![CircleCI Build Status](https://circleci.com/gh/kr-project/circleci-utils.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/kr-project/circleci-utils) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/coda/utils)](https://circleci.com/orbs/registry/orb/coda/utils) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/kr-project/circleci-utils/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

[Example Usage](src/examples/example.yml)
### How to Publish
* Create and push a branch with your new features.
* When ready to publish a new production version, create a Pull Request from fore _feature branch_ to `master`.
* The title of the pull request must contain a special semver tag: `[semver:<segement>]` where `<segment>` is replaced by one of the following values.

| Increment | Description|
| ----------| -----------|
| major     | Issue a 1.0.0 incremented release|
| minor     | Issue a x.1.0 incremented release|
| patch     | Issue a x.x.1 incremented release|
| skip      | Do not issue a release|

Example: `[semver:major]`

* Squash and merge. Ensure the semver tag is preserved and entered as a part of the commit message.
* On merge, after manual approval, the orb will automatically be published to the Orb Registry.
### How to Publish Dev Version

Push your branch and CI will trigger dev published version of orb with the commit hash as the version.

### How to Publish Dev VersionManually

To manually pack your `orb.yml`, you can run `circleci orb pack .  > orb.yml` at the `@orb.yml` level.

```
cd src
circleci orb pack .  > orb.yml
circleci orb publish orb.yml coda/utils@dev:<your_branch_name>
```


## Testing
Using [bats](https://github.com/sstephenson/bats#installing-bats-from-source) to test bash scripts under src/tests.
Individually testing for each command is done in `config.yml`.

## Used in Following Repos:
- infra
- headless-chrome
- experimental
