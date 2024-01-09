import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';

class SignRequestViewModel {
  static final oneEth = BigInt.from(10).pow(18);

  final SignRequest signRequest;

  SignRequestViewModel(this.signRequest);

  String get displayMessage => signRequest.readableMessage;

  String? get recipient => signRequest.to;

  SignType get signType => signRequest.signType;

  String? get amount {
    if (signRequest.value == null) return null;

    final whole = signRequest.value! ~/ oneEth;
    final remainder = signRequest.value!.remainder(oneEth);
    final fraction = remainder / oneEth;

    return whole.toString() + fraction.toString().substring(1);
  }

  String get createdAt => signRequest.createdAt.toString();
}
