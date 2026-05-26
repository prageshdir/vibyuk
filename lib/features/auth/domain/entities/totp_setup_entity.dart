import 'package:equatable/equatable.dart';

class TotpSetupEntity extends Equatable {
  const TotpSetupEntity({
    required this.secret,
    required this.qrCodeUri,
    this.recoveryCodes = const [],
  });

  final String secret;
  final String qrCodeUri;
  final List<String> recoveryCodes;

  @override
  List<Object?> get props => [secret, qrCodeUri, recoveryCodes];
}
