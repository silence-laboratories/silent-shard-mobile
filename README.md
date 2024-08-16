# Silent Shard

The Silent Shard mobile app is an MPC-based Threshold Signer app as a usable, secure, and truly decentralized support for digital wallets, exchanges and institutional asset enterprises. :coin: :closed_lock_with_key:

## Getting Started
### Prerequisites
- Dart
- Flutter
- [optional] IDE (VS Code with Flutter plugin)
- Obtain mix panel token
- Create `.env` file with obtained token (look on `.env.example` template) 

### Installation
- Clone the repository
- Navigate to the project directory
- Install dependencies: `flutter pub get`
- Run the app: `flutter run`

### Build
- Build the app:
    - Android: `./build_android.sh [stg|prod]`
    - iOS: `./build_ios.sh [stg|prod]`

- Before building the app using the scripts, make sure to update the version in `pubspec.yaml` and copy `GoogleService-Info_<environment>.plist` into `scripts` (iOS only), you could find the file in the [Firebase console](https://console.firebase.google.com/u/0/project/mobile-wallet-mm-snap-staging/settings/general/ios:com.silencelaboratories.silentshard).