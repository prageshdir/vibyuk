import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/navigation/app_router.dart';
import 'package:vibyuk/core/theme/app_theme.dart';
import 'package:vibyuk/core/theme/theme_bloc.dart';
import 'package:vibyuk/l10n/l10n.dart';

class VibyukApp extends StatelessWidget {
  const VibyukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (_) => sl<ThemeBloc>(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'VIBYUK',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.mode,
            routerConfig: sl<AppRouter>().router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
