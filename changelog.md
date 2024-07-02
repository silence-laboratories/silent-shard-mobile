# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Show wrong timezone screen in scanner screen if the date time on device is different from server [`2310d17`](https://github.com-sl/silence-laboratories/silent-shard-mobile/commit/2310d17e2942e4240937b8358a07f89ed73406f5)
- Check time consistency when app is opened or resumed [`07ca2c4`](https://github.com-sl/silence-laboratories/silent-shard-mobile/commit/07ca2c4945aec1baf81845ff6841cd30c19ad97d)

## [Android 1.2.5, iOS 1.2.4]
### Added
- Multi-Account support [`#32`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/32), [`#45`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/45), [`#44`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/44), [`#42`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/42), [`#41`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/41), [`#40`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/40), [`#39`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/39), [`#38`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/38)
- Mixpanel for multi accounts [`#43`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/43)
- Force update [`#33`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/33), [`#34`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/34)
- Use backup listener for metamask [`#49`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/49), [`#51`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/51)
- Verify broken encrypted backup based on size [`#50`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/50)

### Changed
- Migrate to uid [`#26`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/26)

### Fixed
- Show error screen if keygen failed in last round [`#47`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/47)

## [Android 1.2.4, iOS 1.2.3]
### Added

- Identify user and set public key to user profile Mixpanel [`#20`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/20)
- Create adaptive icons for newer Android versions [`#17`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/17)
- Repairing flow handling [`#8`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/8), [`#16`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/16)

### Changed

- Added wrong timezone error screen, backup done popup on Android [`#14`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/14)

### Fixed

- Hotfix/prevent fail over while handling loading chain info [`#13`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/13)

## [Android 1.2.3, iOS 1.2.2]
### Added

- MM-325, Moving away from social sign in [`#6`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/6)
- MM-324, Better error handling for pairing [`#11`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/11)
- MM-355, UX improvements [`#4`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/4)
- MM-366, Add distributed_keys_generated MixPanel event [`#7`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/7)
- MM-370, Add error message on phone when the user tries to backup to a wrong MetaMask wallet
- MM-372, Add logs for firebase crashlytics [`#18`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/18)

### Fixed

- MM-334, Incorrect backup status after recovery
- MM-302, Handle the case of denying creating a backup
- MM-371, Fix wrong Mixpanel events tracking on mobile [`#9`](https://github.com-sl/silence-laboratories/silent-shard-mobile/pull/9)

## [Android 1.2.2, iOS 1.2.1]
### Added

- Upgraded UX: Dive into our ultra-sleek designs - a visual treat!
- Improved Transaction Screens: Know exactly what you're signing - clarity at its best.
- Swipe to Approve: Swipe right to security; it's that easy!
- Backup Status & Health Check: Always be in the know about your data's safety.
- Device Lock: Extra layer of security, because your peace of mind matters.


### First release with basic functionality:

- Pairing with remote counterpart
- Key generation
- Signature generation
- Backups
