fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios tests_app

```sh
[bundle exec] fastlane ios tests_app
```

Builds and tests iOS app

### ios tests_core

```sh
[bundle exec] fastlane ios tests_core
```

Builds and tests WalletCore

----


## Mac

### mac tests_server

```sh
[bundle exec] fastlane mac tests_server
```

Builds server and run unit tests

### mac test_integration

```sh
[bundle exec] fastlane mac test_integration
```

bulds Core library and does integration tests app

### mac tests_mac_app

```sh
[bundle exec] fastlane mac tests_mac_app
```

Builds and tests Mac app

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
