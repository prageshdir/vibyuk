import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';
import 'package:vibyuk/features/events/domain/usecases/verify_ticket_usecase.dart';

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class TicketScannerState extends Equatable {
  const TicketScannerState();
}

final class TicketScannerIdle extends TicketScannerState {
  const TicketScannerIdle();

  @override
  List<Object?> get props => [];
}

final class TicketScannerScanning extends TicketScannerState {
  const TicketScannerScanning();

  @override
  List<Object?> get props => [];
}

final class TicketScannerVerifying extends TicketScannerState {
  final String qrData;
  const TicketScannerVerifying({required this.qrData});

  @override
  List<Object?> get props => [qrData];
}

final class TicketScannerValid extends TicketScannerState {
  final TicketVerificationResult result;
  const TicketScannerValid({required this.result});

  @override
  List<Object?> get props => [result];
}

final class TicketScannerInvalid extends TicketScannerState {
  final TicketVerificationResult result;
  const TicketScannerInvalid({required this.result});

  @override
  List<Object?> get props => [result];
}

final class TicketScannerAlreadyUsed extends TicketScannerState {
  final TicketVerificationResult result;
  const TicketScannerAlreadyUsed({required this.result});

  @override
  List<Object?> get props => [result];
}

final class TicketScannerError extends TicketScannerState {
  final String message;
  const TicketScannerError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class TicketScannerCubit extends BaseCubit<TicketScannerState> {
  TicketScannerCubit({required VerifyTicketUseCase verifyTicket})
      : _verifyTicket = verifyTicket,
        super(const TicketScannerIdle());

  final VerifyTicketUseCase _verifyTicket;

  void startScanning() => emit(const TicketScannerScanning());

  Future<void> processQrCode(String eventId, String qrData) async {
    if (state is TicketScannerVerifying) return;
    emit(TicketScannerVerifying(qrData: qrData));

    final result = await _verifyTicket(
      VerifyTicketParams(eventId: eventId, qrData: qrData),
    );

    result.fold(
      (failure) => emit(TicketScannerError(message: failure.message)),
      (verification) {
        if (!verification.isValid) {
          emit(TicketScannerInvalid(result: verification));
        } else if (verification.ticketStatus == TicketStatus.used) {
          emit(TicketScannerAlreadyUsed(result: verification));
        } else {
          emit(TicketScannerValid(result: verification));
        }
      },
    );
  }

  void reset() => emit(const TicketScannerIdle());
}
