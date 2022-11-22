
# CircleCI Utils


[![CircleCI Build Status](https://circleci.com/gh/coda/circleci-utils.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/coda/circleci-utils) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/coda/utils)](https://circleci.com/orbs/registry/orb/coda/utils) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/coda/circleci-utils/main/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

[Example Usage](src/examples/example.yml)
### How to Publish
* Create and push a branch with your new features.
* When ready to publish a new production version, create a Pull Request from from _feature branch_ to `main`.
* When your branch is merged into `main` create a new release version off of `main`. This can be achieved by going to [circleci-utils](https://github.com/coda/circleci-utils/releases/new) release page and clicking on `Draft a new release`. 
Make sure the release version is in the format of `vX.X.X`. This is version number that will match the new orb version.

### How to Publish Dev Version

Push your branch and CI will trigger dev published version of orb with the commit hash as the version.

### How to Publish Dev Version Manually

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
- coda
