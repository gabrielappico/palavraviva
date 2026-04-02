import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/settings_provider.dart';

class PalavraVivaApp extends ConsumerStatefulWidget {
  const PalavraVivaApp({super.key});

  @override
  ConsumerState<PalavraVivaApp> createState() => _PalavraVivaAppState();
}

class _PalavraVivaAppState extends ConsumerState<PalavraVivaApp> {
  late final Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = Supabase.instance.client.auth.onAuthStateChange;
    _authStream.listen((event) {
      if (event.event == AuthChangeEvent.passwordRecovery) {
        appRouter.go('/reset-password');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);

    double textScale = 1.0;
    switch (settings.fontSize) {
      case AppFontSize.small:
        textScale = 0.85;
        break;
      case AppFontSize.medium:
        textScale = 1.0;
        break;
      case AppFontSize.large:
        textScale = 1.25;
        break;
    }

    return MaterialApp.router(
      title: 'Palavra Viva',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        );
      },
    );
  }
}

