import 'package:flutter_test/flutter_test.dart';
import 'package:vibyuk/core/utils/compute_utils.dart';

void main() {
  group('parseJsonInBackground', () {
    test('parses a JSON object to a typed result', () async {
      final result = await parseJsonInBackground<String>(
        jsonString: '{"name":"Alice"}',
        parser: (json) => (json as Map<String, dynamic>)['name'] as String,
      );
      expect(result, 'Alice');
    });

    test('parses a JSON array to a list', () async {
      final result = await parseJsonInBackground<List<int>>(
        jsonString: '[1,2,3]',
        parser: (json) => (json as List).cast<int>(),
      );
      expect(result, [1, 2, 3]);
    });
  });

  group('parseJsonListInBackground', () {
    test('parses a JSON array of objects to typed list', () async {
      const json = '[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]';
      final result = await parseJsonListInBackground<Map<String, dynamic>>(
        jsonString: json,
        itemParser: (m) => m,
      );
      expect(result.length, 2);
      expect(result.first['name'], 'Alice');
      expect(result.last['id'], 2);
    });

    test('returns empty list for empty JSON array', () async {
      final result = await parseJsonListInBackground<Map<String, dynamic>>(
        jsonString: '[]',
        itemParser: (m) => m,
      );
      expect(result, isEmpty);
    });
  });

  group('decodeJsonInBackground', () {
    test('decodes a JSON object', () async {
      final result = await decodeJsonInBackground('{"key":"value"}');
      expect((result as Map)['key'], 'value');
    });

    test('decodes a JSON number', () async {
      final result = await decodeJsonInBackground('42');
      expect(result, 42);
    });
  });

  group('encodeJsonInBackground', () {
    test('encodes a map to JSON string', () async {
      final result = await encodeJsonInBackground({'a': 1, 'b': true});
      expect(result, contains('"a":1'));
      expect(result, contains('"b":true'));
    });

    test('encodes a list to JSON string', () async {
      final result = await encodeJsonInBackground([1, 2, 3]);
      expect(result, '[1,2,3]');
    });
  });

  group('runInBackground', () {
    test('runs a computation on a background isolate', () async {
      final result = await runInBackground<int, int>(
        input: 10,
        computation: (n) => n * n,
      );
      expect(result, 100);
    });

    test('handles string transformation', () async {
      final result = await runInBackground<String, String>(
        input: 'hello',
        computation: (s) => s.toUpperCase(),
      );
      expect(result, 'HELLO');
    });
  });

  group('BackgroundWorker', () {
    test('processes a single task and returns result', () async {
      final worker = await BackgroundWorker.spawn<int, int>((n) => n * 2);
      final result = await worker.process(21);
      expect(result, 42);
      worker.dispose();
    });

    test('processes multiple tasks concurrently', () async {
      final worker = await BackgroundWorker.spawn<int, int>((n) => n + 1);
      final results = await Future.wait([
        worker.process(1),
        worker.process(2),
        worker.process(3),
      ]);
      results.sort();
      expect(results, [2, 3, 4]);
      worker.dispose();
    });

    test('processes tasks sequentially maintaining order with awaited calls',
        () async {
      final worker = await BackgroundWorker.spawn<String, int>((s) => s.length);
      final r1 = await worker.process('hi');
      final r2 = await worker.process('hello');
      expect(r1, 2);
      expect(r2, 5);
      worker.dispose();
    });
  });
}
