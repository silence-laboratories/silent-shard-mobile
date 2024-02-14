import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';

import '../../screens/sign/sign_request_view_model.dart';

class DemoSignRequestViewModel implements SignRequestViewModel {
  @override
  String? get amount => "1 ETH";

  @override
  String get createdAt => DateTime.now().toString();

  @override
  String get displayMessage => "Demo transaction";

  @override
  String? get recipient => "0xDemoAccount";

  @override
  SignType get signType => SignType.ethSign;

  @override
  // TODO: implement signRequest
  SignRequest get signRequest => throw UnimplementedError();

  @override
  Chain? get chain => Chain(id: 1, code: 'Eth', name: 'Ethereum Mainnet');
}
