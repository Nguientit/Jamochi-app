// 📁 JAMOCHI_APP/lib/data/providers/memories_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import 'app_providers.dart'; // ✅ dùng dioClientProvider từ đây

class MemoryDay {
  final String? photoUrl;
  final String? specialEmoji;
  const MemoryDay({this.photoUrl, this.specialEmoji});
}

class MemoriesState {
  final bool isLoading;
  final String? error;
  final Map<String, Map<int, MemoryDay>> data;

  const MemoriesState({
    this.isLoading = false,
    this.error,
    this.data = const {},
  });

  MemoriesState copyWith({
    bool? isLoading,
    String? error,
    Map<String, Map<int, MemoryDay>>? data,
  }) {
    return MemoriesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}

class MemoriesNotifier extends StateNotifier<MemoriesState> {
  final Ref _ref;

  MemoriesNotifier(this._ref) : super(const MemoriesState()) {
    fetchMemories();
  }

  Future<void> fetchMemories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // ✅ Dùng DioClient chung — token được attach tự động qua interceptor
      final dio = _ref.read(dioClientProvider).dio;
      final res = await dio.get('/messages/memories');

      if (res.data['success'] == true) {
        final rawData = res.data['data'] as Map<String, dynamic>;
        final Map<String, Map<int, MemoryDay>> parsedData = {};

        rawData.forEach((monthKey, daysMap) {
          final Map<int, MemoryDay> monthData = {};
          (daysMap as Map<String, dynamic>).forEach((dayKey, dayValue) {
            monthData[int.parse(dayKey)] = MemoryDay(
              photoUrl: dayValue['photoUrl']?.toString(),
              specialEmoji: dayValue['specialEmoji']?.toString(),
            );
          });
          parsedData[monthKey] = monthData;
        });

        state = state.copyWith(isLoading: false, data: parsedData);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? e.message;
      state = state.copyWith(isLoading: false, error: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final memoriesProvider = StateNotifierProvider<MemoriesNotifier, MemoriesState>((ref) {
  return MemoriesNotifier(ref);
});