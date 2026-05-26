import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

/// Parses a JSON string to a typed object on a background isolate.
/// Use for lists of 50+ items to avoid janking the UI thread.
Future<T> parseJsonInBackground<T>({
  required String jsonString,
  required T Function(dynamic json) parser,
}) async {
  return compute(_parseJsonEntry<T>, _ParseJsonArgs(jsonString, parser));
}

T _parseJsonEntry<T>(_ParseJsonArgs<T> args) {
  final decoded = jsonDecode(args.jsonString);
  return args.parser(decoded);
}

class _ParseJsonArgs<T> {
  const _ParseJsonArgs(this.jsonString, this.parser);
  final String jsonString;
  final T Function(dynamic) parser;
}

/// Decodes a JSON string to a raw [dynamic] value on a background isolate.
/// Use when you need raw access before further transformation.
Future<dynamic> decodeJsonInBackground(String jsonString) {
  return compute(_decodeJson, jsonString);
}

dynamic _decodeJson(String jsonString) => jsonDecode(jsonString);

/// Encodes an object to a JSON string on a background isolate.
Future<String> encodeJsonInBackground(dynamic value) {
  return compute(_encodeJson, value);
}

String _encodeJson(dynamic value) => jsonEncode(value);

/// Parses a list from a JSON array string on a background isolate.
/// [itemParser] is called once per list element.
Future<List<T>> parseJsonListInBackground<T>({
  required String jsonString,
  required T Function(Map<String, dynamic>) itemParser,
}) async {
  return compute(
    _parseJsonList<T>,
    _ParseListArgs(jsonString, itemParser),
  );
}

List<T> _parseJsonList<T>(_ParseListArgs<T> args) {
  final list = jsonDecode(args.jsonString) as List<dynamic>;
  return list
      .cast<Map<String, dynamic>>()
      .map(args.itemParser)
      .toList();
}

class _ParseListArgs<T> {
  const _ParseListArgs(this.jsonString, this.itemParser);
  final String jsonString;
  final T Function(Map<String, dynamic>) itemParser;
}

/// Runs a CPU-heavy synchronous operation on a background isolate.
/// [compute] cannot handle closures that capture external state.
/// This helper encapsulates the input/output contract.
Future<O> runInBackground<I, O>({
  required I input,
  required O Function(I) computation,
}) {
  return compute(computation, input);
}

/// Long-lived isolate pool for sustained heavy workloads.
/// Spawns a single persistent isolate; use [process] to send work.
class BackgroundWorker<I, O> {
  BackgroundWorker._(
    this._sendPort,
    this._receivePort,
    this._isolate,
  );

  final SendPort _sendPort;
  final ReceivePort _receivePort;
  final Isolate _isolate;
  final _pending = <int, Completer<O>>{};
  int _seq = 0;

  static Future<BackgroundWorker<I, O>> spawn<I, O>(
    O Function(I) handler,
  ) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _workerEntry<I, O>,
      _WorkerInit(receivePort.sendPort, handler),
    );

    final sendPort = await receivePort.first as SendPort;

    final worker = BackgroundWorker<I, O>._(sendPort, receivePort, isolate);
    receivePort.listen((msg) {
      if (msg is _WorkerResult<O>) {
        worker._pending[msg.id]?.complete(msg.value);
        worker._pending.remove(msg.id);
      }
    });
    return worker;
  }

  Future<O> process(I input) {
    final id = _seq++;
    final completer = Completer<O>();
    _pending[id] = completer;
    _sendPort.send(_WorkerTask<I>(id, input));
    return completer.future;
  }

  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
  }
}

void _workerEntry<I, O>(_WorkerInit<I, O> init) {
  final port = ReceivePort();
  init.callerPort.send(port.sendPort);
  port.listen((msg) {
    if (msg is _WorkerTask<I>) {
      final result = init.handler(msg.input);
      init.callerPort.send(_WorkerResult<O>(msg.id, result));
    }
  });
}

class _WorkerInit<I, O> {
  const _WorkerInit(this.callerPort, this.handler);
  final SendPort callerPort;
  final O Function(I) handler;
}

class _WorkerTask<I> {
  const _WorkerTask(this.id, this.input);
  final int id;
  final I input;
}

class _WorkerResult<O> {
  const _WorkerResult(this.id, this.value);
  final int id;
  final O value;
}
