import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/presentation/blocs/ticket_scanner/ticket_scanner_cubit.dart';
import 'package:vibyuk/features/events/presentation/widgets/scan_overlay_widget.dart';

class TicketScannerScreen extends StatefulWidget {
  final String eventId;
  const TicketScannerScreen({super.key, required this.eventId});

  @override
  State<TicketScannerScreen> createState() => _TicketScannerScreenState();
}

class _TicketScannerScreenState extends State<TicketScannerScreen> {
  final _mobileScannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketScannerCubit>().startScanning();
    });
  }

  @override
  void dispose() {
    _mobileScannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Ticket Scanner'),
        elevation: 0,
      ),
      body: BlocBuilder<TicketScannerCubit, TicketScannerState>(
        builder: (context, state) {
          final isScanning = state is TicketScannerScanning;
          final statusText = switch (state) {
            TicketScannerIdle() => 'Initializing...',
            TicketScannerScanning() => 'Scan a QR code',
            TicketScannerVerifying() => 'Verifying...',
            TicketScannerValid() => 'Valid ticket',
            TicketScannerInvalid() => 'Invalid ticket',
            TicketScannerAlreadyUsed() => 'Already used',
            TicketScannerError() => 'Error',
          };

          return Stack(
            children: [
              // Camera preview
              MobileScanner(
                controller: _mobileScannerController,
                onDetect: (capture) {
                  if (state is! TicketScannerScanning) return;
                  final barcode = capture.barcodes.firstOrNull;
                  if (barcode?.rawValue != null) {
                    context.read<TicketScannerCubit>().processQrCode(
                          widget.eventId,
                          barcode!.rawValue!,
                        );
                  }
                },
              ),

              // Scan overlay
              ScanOverlayWidget(
                statusText: statusText,
                isScanning: isScanning,
              ),

              // Verifying indicator
              if (state is TicketScannerVerifying)
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),

              // Result panel
              if (state is! TicketScannerIdle &&
                  state is! TicketScannerScanning &&
                  state is! TicketScannerVerifying)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ResultPanel(
                    state: state,
                    onScanAgain: () {
                      context.read<TicketScannerCubit>().reset();
                      context.read<TicketScannerCubit>().startScanning();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final TicketScannerState state;
  final VoidCallback onScanAgain;

  const _ResultPanel({required this.state, required this.onScanAgain});

  @override
  Widget build(BuildContext context) {
    final (color, icon, title, subtitle) = switch (state) {
      TicketScannerValid(result: final r) => (
          Colors.green,
          Icons.check_circle,
          'Valid Ticket',
          '${r.ownerName ?? 'Guest'} · ${r.ticketTypeName ?? ''}',
        ),
      TicketScannerInvalid(result: final r) => (
          Colors.red,
          Icons.cancel,
          'Invalid Ticket',
          r.errorMessage ?? 'This ticket is not valid for this event.',
        ),
      TicketScannerAlreadyUsed(result: final r) => (
          Colors.orange,
          Icons.warning,
          'Already Used',
          '${r.ownerName ?? 'Guest'} already checked in.',
        ),
      TicketScannerError(message: final m) => (
          Colors.red,
          Icons.error,
          'Error',
          m,
        ),
      _ => (Colors.grey, Icons.help, '', ''),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: color,
            ),
            onPressed: onScanAgain,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }
}
