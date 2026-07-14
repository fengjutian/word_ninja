import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/logger/logger.dart';
import 'package:core/storage/sqlite/sqlite_init.dart';
import 'package:core/storage/sqlite/chat_repository.dart';
import 'package:ai/ai.dart';
import 'package:vocabulary/data/datasource/isar_local_datasource.dart';

/// 分析状态
class AnalysisState {
  final List<WordFrequency> topWords;
  final int sessionCount;
  final String? report;        // AI 分析报告
  final String? quickInsight;  // 一句话洞察
  final bool isLoading;
  final String? error;
  /// AI 识别的重点强化词
  final List<FocusWord> focusWords;
  /// 已执行分析的次数（支持多次分析）
  final int analysisCount;

  const AnalysisState({
    this.topWords = const [],
    this.sessionCount = 0,
    this.report,
    this.quickInsight,
    this.isLoading = false,
    this.error,
    this.focusWords = const [],
    this.analysisCount = 0,
  });

  AnalysisState copyWith({
    List<WordFrequency>? topWords,
    int? sessionCount,
    String? report,
    String? quickInsight,
    bool? isLoading,
    String? error,
    List<FocusWord>? focusWords,
    int? analysisCount,
  }) {
    return AnalysisState(
      topWords: topWords ?? this.topWords,
      sessionCount: sessionCount ?? this.sessionCount,
      report: report ?? this.report,
      quickInsight: quickInsight ?? this.quickInsight,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      focusWords: focusWords ?? this.focusWords,
      analysisCount: analysisCount ?? this.analysisCount,
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

  /// 生成 AI 分析报告（支持多次调用）
  Future<void> generateReport(AiAnalysisService aiService) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 每次分析前刷新统计数据
      try {
        await loadStats();
      } catch (_) {}

      // 分别 await，避免一个失败导致全部丢弃
      String? report;
      String? insight;
      List<FocusWord> focusWords = [];
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
      try {
        focusWords = await aiService.extractFocusWords();
        if (focusWords.isNotEmpty) {
          final scores = <String, int>{};
          for (final fw in focusWords) {
            scores[fw.word.toLowerCase()] = fw.score;
          }
          await IsarVocabularyLocalDataSource.persistFocusScores(scores);
        }
      } catch (e) {
        log.w('AI focus words extraction failed', e);
      }
      state = state.copyWith(
        report: report,
        quickInsight: insight,
        focusWords: focusWords,
        isLoading: false,
        analysisCount: state.analysisCount + 1,
        error: (report == null && insight == null && focusWords.isEmpty)
            ? 'AI 分析生成失败'
            : null,
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
