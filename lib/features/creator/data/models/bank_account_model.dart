import 'package:vibyuk/features/creator/domain/entities/bank_account_entity.dart';

class BankAccountModel {
  final String? id;
  final String accountHolderName;
  final String accountNumberLast4;
  final String ifscCode;
  final String bankName;
  final bool isVerified;

  const BankAccountModel({
    this.id,
    required this.accountHolderName,
    required this.accountNumberLast4,
    required this.ifscCode,
    required this.bankName,
    required this.isVerified,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) =>
      BankAccountModel(
        id: json['id'] as String?,
        accountHolderName: json['account_holder_name'] as String? ?? '',
        accountNumberLast4: json['account_number_last4'] as String? ?? '****',
        ifscCode: json['ifsc_code'] as String? ?? '',
        bankName: json['bank_name'] as String? ?? '',
        isVerified: json['is_verified'] as bool? ?? false,
      );

  BankAccountEntity toEntity() => BankAccountEntity(
        id: id,
        accountHolderName: accountHolderName,
        accountNumberLast4: accountNumberLast4,
        ifscCode: ifscCode,
        bankName: bankName,
        isVerified: isVerified,
      );
}
