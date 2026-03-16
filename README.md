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

# Development Updates

This project uses https://github.com/silence-laboratories/silent-shard-flutter-sdk as a dependency.

Please refer to the README.md file in the silent-shard-flutter-sdk repository for more details on the development updates.

## Configure firebase 

Download the google-services.json file from the Firebase console and place it in the android/app directory.
Download the GoogleService-Info.plist file from the Firebase console and place it in the ios/Runner directory.

run the `flutterfire configure` command to configure the firebase project.

prod - https://console.firebase.google.com/project/mobile-wallet-mm-snap/overview
staging - https://console.firebase.google.com/project/mobile-wallet-mm-snap-staging/overview