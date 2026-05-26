import 'package:equatable/equatable.dart';

class BankAccountEntity extends Equatable {
  final String? id;
  final String accountHolderName;
  final String accountNumberLast4;
  final String ifscCode;
  final String bankName;
  final bool isVerified;

  const BankAccountEntity({
    this.id,
    required this.accountHolderName,
    required this.accountNumberLast4,
    required this.ifscCode,
    required this.bankName,
    this.isVerified = false,
  });

  @override
  List<Object?> get props =>
      [id, accountHolderName, accountNumberLast4, ifscCode, bankName, isVerified];
}
