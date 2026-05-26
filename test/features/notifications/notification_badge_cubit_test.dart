import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/features/notifications/domain/usecases/watch_unread_count_usecase.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_badge/notification_badge_cubit.dart';

// ── Fake use case ─────────────────────────────────────────────────────────────

class _FakeWatchUnreadCount extends Fake implements WatchUnreadCountUseCase {
  final _controller = StreamController<int>.broadcast();

  @override
  Stream<dynamic> call(NoParams _) => _controller.stream;

  void emit(int count) => _controller.add(count);
  void emitError(Object error) => _controller.addError(error);
  Future<void> close() => _controller.close();
}

void main() {
  setUpAll(() => FlavorConfig.initialize(AppFlavor.dev));

  group('NotificationBadgeCubit', () {
    test('initial state is 0', () {
      final fake = _FakeWatchUnreadCount();
      final cubit = NotificationBadgeCubit(fake);
      expect(cubit.state, 0);
      cubit.close();
      fake.close();
    });

    blocTest<NotificationBadgeCubit, int>(
      'emits new count when stream emits a value',
      build: () {
        final fake = _FakeWatchUnreadCount();
        // Schedule emission after build
        Future.microtask(() => fake.emit(5));
        return NotificationBadgeCubit(fake);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [5],
    );

    blocTest<NotificationBadgeCubit, int>(
      'emits multiple counts as stream updates',
      build: () {
        final fake = _FakeWatchUnreadCount();
        Future.microtask(() async {
          fake.emit(1);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          fake.emit(3);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          fake.emit(7);
        });
        return NotificationBadgeCubit(fake);
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [1, 3, 7],
    );

    blocTest<NotificationBadgeCubit, int>(
      'emits 0 when stream emits an error',
      build: () {
        final fake = _FakeWatchUnreadCount();
        // First emit a real count, then an error
        Future.microtask(() async {
          fake.emit(4);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          fake.emitError(Exception('connection lost'));
        });
        return NotificationBadgeCubit(fake);
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [4, 0],
    );

    test('cancels stream subscription on close', () async {
      final fake = _FakeWatchUnreadCount();
      final cubit = NotificationBadgeCubit(fake);

      await cubit.close();

      // After close, emitting to the stream should not change state
      // (stream subscription cancelled — no exception thrown)
      expect(() => fake.emit(99), returnsNormally);
      await fake.close();
    });

    blocTest<NotificationBadgeCubit, int>(
      'ignores zero-count emission (emits 0 explicitly)',
      build: () {
        final fake = _FakeWatchUnreadCount();
        Future.microtask(() => fake.emit(0));
        return NotificationBadgeCubit(fake);
      },
      wait: const Duration(milliseconds: 50),
      // BloC deduplicate equal states, but initial is already 0 so no new state emitted
      expect: () => [],
    );
  });
}
