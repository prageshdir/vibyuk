import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/features/business/data/dtos/update_booking_status_dto.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';

abstract interface class BookingRemoteDataSource {
  Future<Map<String, dynamic>> getBookings(
      {BookingStatus? status, required int page, required int pageSize});
  Future<Map<String, dynamic>> getBookingDetail(String bookingId);
  Future<Map<String, dynamic>> updateBookingStatus(
      String bookingId, UpdateBookingStatusDto dto);
  Future<void> cancelBooking(String bookingId, {String? reason});
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  BookingRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  Map<String, dynamic> _data(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  @override
  Future<Map<String, dynamic>> getBookings(
      {BookingStatus? status, required int page, required int pageSize}) async {
    final response = await _dio.get(ApiEndpoints.bookings, queryParameters: {
      if (status != null) 'status': status.name,
      'page': page,
      'page_size': pageSize,
    });
    return _data(response);
  }

  @override
  Future<Map<String, dynamic>> getBookingDetail(String bookingId) async {
    final response = await _dio.get(ApiEndpoints.booking(bookingId));
    return _data(response);
  }

  @override
  Future<Map<String, dynamic>> updateBookingStatus(
      String bookingId, UpdateBookingStatusDto dto) async {
    final response = await _dio.patch(
      '${ApiEndpoints.booking(bookingId)}/status',
      data: dto.toJson(),
    );
    return _data(response);
  }

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    await _dio.post(
      ApiEndpoints.cancelBooking(bookingId),
      data: reason != null ? {'reason': reason} : null,
    );
  }
}
