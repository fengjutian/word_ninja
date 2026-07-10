import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/logger/logger.dart';
import 'package:core/storage/sqlite/sqlite_init.dart';
import 'package:core/storage/sqlite/chat_repository.dart';
import 'package:ai/services/ai_analysis_service.dart';

/// 分析状态
class AnalysisState {
  final List<WordFrequency> topWords;
  final int sessionCount;
  final String? report;        // AI 分析报告
  final String? quickInsight;  // 一句话洞察
  final bool isLoading;
  final String? error;

  const AnalysisState({
    this.topWords = const [],
    this.sessionCount = 0,
    this.report,
    this.quickInsight,
    this.isLoading = false,
    this.error,
  });

  AnalysisState copyWith({
    List<WordFrequency>? topWords,
    int? sessionCount,
    String? report,
    String? quickInsight,
    bool? isLoading,
    String? error,
  }) {
    return AnalysisState(
      topWords: topWords ?? this.topWords,
      sessionCount: sessionCount ?? this.sessionCount,
      report: report ?? this.report,
      quickInsight: quickInsight ?? this.quickInsight,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 分析 Provider
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  AnalysisNotifier() : super(const AnalysisState());

  ChatRepository get _repo => SqliteDb.repository;

  /// 加载基础统计数据（不含 AI 分析）
  Future<void> loadStats() async {
    try {
      final words = await _repo.topWords(limit: 20);
      final sessions = await _repo.getAllSessions();
      state = state.copyWith(
        topWords: words,
        sessionCount: sessions.length,
      );
    } catch (e) {
      state = state.copyWith(error: '加载数据失败');
    }
  }

  /// 生成 AI 分析报告
  Future<void> generateReport(AiAnalysisService aiService) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 分别 await，避免一个失败导致全部丢弃
      String? report;
      String? insight;
      try {
        report = await aiService.generateReport();
      } catch (e) {
        log.w('AI report generation failed', e);
      }
      try {
        insight = await aiService.quickInsight();
      } catch (e) {
        log.w('AI quick insight failed', e);
      }
      state = state.copyWith(
        report: report,
        quickInsight: insight,
        isLoading: false,
        error: (report == null && insight == null) ? 'AI 分析生成失败' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'AI 分析生成失败：$e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier();
});
