import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:vibyuk/core/error/exceptions.dart';

class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final results = await _connectivity.checkConnectivity();
    final hasConnection = results.any(
      (r) => r != ConnectivityResult.none,
    );

    if (!hasConnection) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const ConnectionException(),
          type: DioExceptionType.connectionError,
        ),
      );
      return;
    }

    handler.next(options);
  }
}
