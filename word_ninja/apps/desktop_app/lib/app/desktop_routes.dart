part of 'desktop_app.dart';

/// Desktop route paths
class DesktopRoutes {
  static const String home = '/';
  static const String vocabulary = '/vocabulary';
  static const String wordDetail = '/vocabulary/detail/:id';
  static const String addWord = '/vocabulary/add';
  static const String review = '/vocabulary/review';
  static const String wordTest = '/vocabulary/test';
  static const String wordGraph = '/vocabulary/graph';
  static const String reading = '/reading';
  static const String aiTutor = '/ai-tutor';
  static const String aiAnalysis = '/ai-analysis';
  static const String modelConfig = '/model-config';
  static const String writing = '/writing';
  static const String studyPlan = '/study-plan';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String listening = '/listening';
  static const String speaking = '/speaking';
}

GoRouter createDesktopRouter() {
  return GoRouter(
    initialLocation: DesktopRoutes.home,
    routes: [
      ShellRoute(
        builder: (ctx, state, child) => DesktopShell(child: child),
        routes: [
          GoRoute(
            path: DesktopRoutes.home,
            builder: (ctx, state) => const _DesktopHome(),
          ),
          GoRoute(
            path: DesktopRoutes.vocabulary,
            builder: (ctx, state) => const VocabularyPage(),
          ),
          GoRoute(
            path: DesktopRoutes.wordGraph,
            builder: (ctx, state) => Consumer(
              builder: (context, ref, _) {
                final words = ref.watch(wordListProvider);
                if (words.words.isEmpty && !words.isLoading) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref
                        .read(wordListProvider.notifier)
                        .loadWords(refresh: true);
                  });
                }
                if (words.isLoading && words.words.isEmpty) {
                  return const Center(child: mt.CircularProgressIndicator());
                }
                return WordGraphPage(words: words.words);
              },
            ),
          ),
          GoRoute(
            path: DesktopRoutes.reading,
            builder: (ctx, state) => const ReaderPage(),
          ),
          GoRoute(
            path: DesktopRoutes.aiTutor,
            builder: (ctx, state) => const TutorChatPage(),
          ),
          GoRoute(
            path: DesktopRoutes.aiAnalysis,
            builder: (ctx, state) => const AnalysisPage(),
          ),
          GoRoute(
            path: DesktopRoutes.modelConfig,
            builder: (ctx, state) => const ModelConfigPage(),
          ),
          GoRoute(
            path: DesktopRoutes.writing,
            builder: (ctx, state) => const WritingPage(),
          ),
          GoRoute(
            path: DesktopRoutes.studyPlan,
            builder: (ctx, state) => const StudyPlanPage(),
          ),
          GoRoute(
            path: DesktopRoutes.profile,
            builder: (ctx, state) => const ProfilePage(),
          ),
          GoRoute(
            path: DesktopRoutes.settings,
            builder: (ctx, state) => const SettingsPage(),
          ),
          GoRoute(
            path: DesktopRoutes.listening,
            builder: (ctx, state) => const ListeningPage(),
          ),
          GoRoute(
            path: DesktopRoutes.speaking,
            builder: (ctx, state) => const SpeakingPage(),
          ),
        ],
      ),
      // ─── 全屏子页面 ───
      GoRoute(
        path: DesktopRoutes.wordDetail,
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return mt.MaterialPage(
            key: state.pageKey,
            child: WordDetailPage(
              word: Word(id: id, userId: '', word: '', meaning: ''),
            ),
          );
        },
      ),
      GoRoute(
        path: DesktopRoutes.addWord,
        pageBuilder: (ctx, state) =>
            mt.MaterialPage(key: state.pageKey, child: const AddWordPage()),
      ),
      GoRoute(
        path: DesktopRoutes.review,
        pageBuilder: (ctx, state) {
          final extra = state.extra;
          if (extra is List<Word> && extra.isNotEmpty) {
            return mt.MaterialPage(
              key: state.pageKey,
              child: ReviewPage(words: extra),
            );
          }
          return mt.MaterialPage(
            key: state.pageKey,
            child: ReviewPage(words: []),
          );
        },
      ),
      GoRoute(
        path: DesktopRoutes.wordTest,
        pageBuilder: (ctx, state) {
          final extra = state.extra;
          if (extra is List<Word> && extra.length >= 2) {
            return mt.MaterialPage(
              key: state.pageKey,
              child: WordTestPage(words: extra),
            );
          }
          return mt.MaterialPage(
            key: state.pageKey,
            child: WordTestPage(words: []),
          );
        },
      ),
    ],
  );
}

/// Desktop shell — fluent_ui NavigationView replaces old NavigationRail
