
# CircleCI Utils


[![CircleCI Build Status](https://circleci.com/gh/kr-project/circleci-utils.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/kr-project/circleci-utils) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/coda/utils)](https://circleci.com/orbs/registry/orb/coda/utils) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/kr-project/circleci-utils/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

[Example Usage](src/examples/example.yml)

### How to Publish Dev Version

```
cd src
circleci orb pack .  > orb.yml
circleci orb publish orb.yml coda/utils@dev:<your_branch_name>
```