// 📁 JAMOCHI_APP/lib/data/providers/special_dates_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../network/dio_client.dart';
import '../../models/special_date.dart';
import 'app_providers.dart';

class SpecialDatesState {
  final bool isLoading;
  final List<SpecialDate> dates;
  final String? error;

  const SpecialDatesState({
    this.isLoading = false,
    this.dates = const [],
    this.error,
  });

  SpecialDatesState copyWith({
    bool? isLoading,
    List<SpecialDate>? dates,
    String? error,
  }) {
    return SpecialDatesState(
      isLoading: isLoading ?? this.isLoading,
      dates: dates ?? this.dates,
      error: error,
    );
  }
}

class SpecialDatesNotifier extends StateNotifier<SpecialDatesState> {
  final DioClient _dioClient;

  SpecialDatesNotifier(this._dioClient) : super(const SpecialDatesState()) {
    fetchDates();
  }

  Future<void> fetchDates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _dioClient.dio.get(ApiConstants.specialDates);
      if (res.data['success'] == true) {
        final List<dynamic> data = res.data['data'] ?? [];
        final dates = data
            .map((e) => SpecialDate.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(isLoading: false, dates: dates);
      }
    } on DioException catch (e) {
      final serverMessage = e.response?.data;
      state = state.copyWith(
        isLoading: false,
        error: serverMessage?.toString() ?? e.message,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addDate(String title, DateTime date) async {
    try {
      final res = await _dioClient.dio.post(
        ApiConstants.specialDates,
        data: {
          'title': title,
          'date': date.toIso8601String().split('T')[0], // DATEONLY "2025-02-14"
        },
      );
      if (res.data['success'] == true) {
        await fetchDates();
        return true;
      }
      return false;
    } on DioException catch (e) {
      return false;
    }
  }

  Future<bool> updateDate(String id, String title, DateTime date) async {
    try {
      final res = await _dioClient.dio.put(
        ApiConstants.specialDate(id),
        data: {'title': title, 'date': date.toIso8601String().split('T')[0]},
      );
      if (res.data['success'] == true) {
        await fetchDates();
        return true;
      }
      return false;
    } on DioException catch (e) {
      return false;
    }
  }

  Future<bool> deleteDate(String id) async {
    try {
      final res = await _dioClient.dio.delete(ApiConstants.specialDate(id));
      if (res.data['success'] == true) {
        await fetchDates();
        return true;
      }
      return false;
    } on DioException catch (e) {
      return false;
    }
  }
}

final specialDatesProvider =
    StateNotifierProvider<SpecialDatesNotifier, SpecialDatesState>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return SpecialDatesNotifier(dioClient);
    });
