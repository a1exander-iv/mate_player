import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mate_player/data/repositories/audio_player_repository.dart';
import 'package:mate_player/data/repositories/database_repository.dart';
import 'package:mate_player/data/repositories/metadata_repository.dart';
import 'package:mate_player/data/repositories/settings_repository.dart';
import 'package:mate_player/data/sources/db.dart';
import 'package:mate_player/data/sources/prefs.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/audio_loader/audio_loader_cubit.dart';
import 'package:mate_player/presentation/cubits/favorite/favorite_cubit.dart';
import 'package:mate_player/presentation/cubits/listening_history/listening_history_cubit.dart';
import 'package:mate_player/presentation/cubits/music_bar_slider/slider_music_bar_cubit.dart';
import 'package:mate_player/presentation/cubits/permission/permission_cubit.dart';
import 'package:mate_player/presentation/cubits/picture/pictures_cubit.dart';
import 'package:mate_player/presentation/cubits/playback_speed/playback_speed_cubit.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/presentation/cubits/playlist/playlist_cubit.dart';
import 'package:mate_player/presentation/cubits/playlist_screen/playlist_screen_cubit.dart';
import 'package:mate_player/presentation/cubits/settings/settings_cubit.dart';
import 'package:mate_player/presentation/cubits/short_info/track_short_info_cubit.dart';
import 'package:mate_player/presentation/cubits/volume_slider/volume_slider_cubit.dart';
import 'package:mate_player/presentation/enums/list_type_enum.dart';
import 'package:mate_player/presentation/enums/select_sorting_enum.dart';
import 'package:mate_player/presentation/enums/select_theme_enum.dart';
import 'package:mate_player/presentation/intents/intents.dart';
import 'package:mate_player/presentation/screens/favorite_screen.dart';
import 'package:mate_player/presentation/screens/main_screen.dart';
import 'package:mate_player/presentation/screens/player_screen.dart';
import 'package:mate_player/presentation/screens/playlist_screen.dart';
import 'package:mate_player/presentation/screens/settings_screen.dart';
import 'package:mate_player/shared/widgets/navigation_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDatabase = AppDatabase();

  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  final Prefs prefs = Prefs(sharedPreferences: sharedPreferences)..initValues();
  final SettingsRepository settingsRepository = SettingsRepository(
    prefs,
    appDatabase,
  );
  final DatabaseRepository databaseRepository = DatabaseRepository(
    appDatabase,
    prefs,
  );
  final TrackMetadataRepository trackMetadataRepository =
      TrackMetadataRepository(database: appDatabase);
  final AudioPlayerRepository audioPlayerRepository = AudioPlayerRepository();
  final List<String> initialDirectoryPathList = settingsRepository
      .getDirectoryList();
  final SelectThemeEnum theme = settingsRepository.getTheme();
  final bool isSystemColor = settingsRepository.getSystemColor();
  final Color color = Color(settingsRepository.getColor());
  final SelectSortingEnum sortValue = settingsRepository.getSortingValue();
  final bool loadTrackImages = settingsRepository.getTrackImagesLoadValue();

  final String? languageCode = settingsRepository.getLocaleLanguageCode();
  final Locale? locale = languageCode != null ? Locale(languageCode) : null;

  final ListTypeEnum listType = settingsRepository.getListTypeValue();
  if (!Platform.isAndroid) {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    minimumSize: Size(300, 300),
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  }
  
  runApp(
    MusicApp(
      settingsRepository: settingsRepository,
      databaseRepository: databaseRepository,
      trackMetadataRepository: trackMetadataRepository,
      audioPlayerRepository: audioPlayerRepository,
      initialDirectoryPathList: initialDirectoryPathList,
      theme: theme,
      isSystemColor: isSystemColor,
      color: color,
      sortValue: sortValue,
      loadTrackImages: loadTrackImages,
      locale: locale,
      listType: listType,
    ),
  );
}

class MusicApp extends StatelessWidget {
  MusicApp({
    super.key,
    required this.settingsRepository,
    required this.trackMetadataRepository,
    required this.audioPlayerRepository,
    required this.databaseRepository,
    required this.initialDirectoryPathList,
    required this.theme,
    required this.isSystemColor,
    required this.color,
    required this.sortValue,
    required this.loadTrackImages,
    required this.locale,
    required this.listType,
  });

  final TrackMetadataRepository trackMetadataRepository;
  final DatabaseRepository databaseRepository;
  final AudioPlayerRepository audioPlayerRepository;
  final SettingsRepository settingsRepository;
  final List<String> initialDirectoryPathList;
  final SelectThemeEnum theme;
  final bool isSystemColor;
  final Color color;
  final SelectSortingEnum sortValue;
  final bool loadTrackImages;
  final Locale? locale;
  final ListTypeEnum listType;
  final router = GoRouter(
    initialLocation: "/",
    navigatorKey: _rootNavigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navShell) {
          return NavigationWrapper(bodyChild: navShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(  
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: MainScreen(),
                name: state.fullPath,
                key: state.pageKey,
              );
            },
            path: "/",
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                name: "playlist_screen",
                path: "playlist/:playlistId/:playlistNumber",
                pageBuilder: (context, state) {
                  int? playlistId = int.tryParse(
                    state.pathParameters["playlistId"] ?? "",
                  );
                  if (playlistId == null) {
                    throw Exception("no valid playlistId");
                  }

                  int? playlistNumber = int.tryParse(
                    state.pathParameters["playlistNumber"] ?? "",
                  );
                  if (playlistNumber == null) {
                    throw Exception("no valid playlistNumber");
                  }
                  return NoTransitionPage(
                    child: BlocProvider(
                      create: (context) => PlaylistScreenCubit(
                        context.read<DatabaseRepository>(),
                      ),
                      child: PlaylistScreen(
                        playlistId: playlistId,
                        playlistNumber: playlistNumber,
                      ),
                    ),
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: "player",
                name: "player_screen",
                pageBuilder: (context, state) {
                  return const NoTransitionPage(child: PlayerScreen());
                },
              ),
            ],
          ),
          ]),
          StatefulShellBranch(routes: [
             GoRoute(
            path: "/favorite",
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: const FavoriteScreen(),
                name: state.fullPath,
                key: state.pageKey,
              );
            },
          ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
            path: "/settings",
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: const SettingScreen(),
                name: state.fullPath,
                key: state.pageKey,
              );
            },
          ),
          ]),
          StatefulShellBranch(routes: [
          GoRoute(
            path: "/player",
            name: "player",
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: const PlayerScreen(),
                name: state.fullPath,
                key: state.pageKey,
              );
            },
          ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
            path: "/license",
            name: "license",
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: const LicensePage(applicationName: "Mate Player"),
                name: state.fullPath,
                key: state.pageKey,
              );
            },
          ),
          ])
          
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => databaseRepository),
        RepositoryProvider(create: (context) => settingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PlayerCubit(
              audioPlayerRepository,
              databaseRepository: databaseRepository,
            )..init(),
          ),
          BlocProvider(
            create: (context) => VolumeSliderCubit(
              audioPlayerRepository: audioPlayerRepository,
              initSliderValue: 100,
            ),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => SliderMusicBarCubit(
              audioPlayer: audioPlayerRepository.audioPlayer,
            )..init(),
          ),
          BlocProvider(
            create: (context) =>
                AudioLoaderCubit(trackMetadataRepository, databaseRepository)
                  ..init(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => TrackShortInfoCubit(
              audioPlayerRepository.audioPlayer,
              databaseRepository,
            )..init(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => ListeningHistoryCubit(
              audioPlayerRepository.audioPlayer,
              databaseRepository,
            )..init(),
          ),
          BlocProvider(
            create: (context) =>
                PlaylistCubit(databaseRepository)..loadPlaylistCatalog(),
          ),
          BlocProvider(
            create: (context) => SettingsCubit(
              color: color,
              isSystemColor: isSystemColor,
              theme: theme,
              settingsRepository: settingsRepository,
              databaseRepository: databaseRepository,
              directoryList: initialDirectoryPathList,
              sortValue: sortValue,
              loadTrackImages: loadTrackImages,
              locale: locale,
              listType: listType,
            ),
          ),
          BlocProvider(
            create: (context) => PicturesCubit(databaseRepository, settingsRepository)..init(),
          ),
          BlocProvider(
            create: (context) => FavoriteCubit(databaseRepository)..init(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => PermissionCubit()..checkPermissions(),
          ),
          BlocProvider(create: (context) => PlaybackSpeedCubit(audioPlayerRepository: audioPlayerRepository)),
        ],
        child: App(router: router),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key, required this.router});

  final GoRouter router;
  @override
  Widget build(BuildContext context) {
    SettingsCubit settingsCubit = context.read<SettingsCubit>();
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        ColorScheme lightColorScheme = ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        );
        ColorScheme darkColorScheme = ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        );

        if (state.isSystemColor == false) {
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: state.color,
            brightness: Brightness.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: state.color,
            brightness: Brightness.dark,
          );
        }

        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            if (lightDynamic != null &&
                darkDynamic != null &&
                state.isSystemColor) {
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: lightDynamic.primary,
                brightness: Brightness.light,
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: darkDynamic.primary,
                brightness: Brightness.dark,
              );
            }

            return MaterialApp.router(
              title: "Mate Player",
              actions: <Type, Action<Intent>>{
                ...WidgetsApp.defaultActions,
                NextButtonIntent: CallbackAction<NextButtonIntent>(
                  onInvoke: (intent) {
                    context.read<PlayerCubit>().onNextButtonPressed();
                    return null;
                  },
                ),
                PreviousButtonIntent: CallbackAction<PreviousButtonIntent>(
                  onInvoke: (intent) {
                    context.read<PlayerCubit>().onPreviousButtonPressed();
                    return null;
                  },
                ),
                PlayAndPauseButtonIntent:
                    CallbackAction<PlayAndPauseButtonIntent>(
                      onInvoke: (intent) {
                        context.read<PlayerCubit>().playAndPause();
                        return null;
                      },
                    ),
                MuteIntent: CallbackAction<MuteIntent>(
                  onInvoke: (intent) {
                    context
                        .read<VolumeSliderCubit>()
                        .onMuteVolumeButtonPressed();
                    return null;
                  },
                ),
                ShuffleIntent: CallbackAction<ShuffleIntent>(
                  onInvoke: (intent) {
                    context.read<PlayerCubit>().onShuffleButtonPressed();
                    return null;
                  },
                ),
                RepeatIntent: CallbackAction<RepeatIntent>(
                  onInvoke: (intent) {
                    context.read<PlayerCubit>().onRepeatButtonPressed();
                    return null;
                  },
                ),
                FullscreenIntent: CallbackAction<FullscreenIntent>(
                  onInvoke: (intent) {
                    if (!Platform.isAndroid) {
                    context.read<SettingsCubit>().setFullscreen();
                    }
                    return null;
                  },
                ),
              },
              shortcuts: <ShortcutActivator, Intent>{
                ...WidgetsApp.defaultShortcuts,
                const SingleActivator(
                  LogicalKeyboardKey.arrowRight,
                  control: true,
                ): NextButtonIntent(),
                const SingleActivator(
                  LogicalKeyboardKey.arrowLeft,
                  control: true,
                ): PreviousButtonIntent(),
                const SingleActivator(LogicalKeyboardKey.space):
                    PlayAndPauseButtonIntent(),
                const SingleActivator(LogicalKeyboardKey.keyM, alt: true):
                    MuteIntent(),
                const SingleActivator(LogicalKeyboardKey.keyS, alt: true):
                    ShuffleIntent(),
                const SingleActivator(LogicalKeyboardKey.keyR, alt: true):
                    RepeatIntent(),
                const SingleActivator(LogicalKeyboardKey.f11):
                    FullscreenIntent(),
              },
              locale: state.locale,
              localeResolutionCallback: (locale, supportedLocales) {
                
                Locale languageCodeLocale = locale != null ? Locale(locale.languageCode) : Locale("en");
                if (state.locale == null) {
                  if (supportedLocales.contains(languageCodeLocale)) {
                    settingsCubit.setLocale(languageCodeLocale);
                    return languageCodeLocale;
                  } else {
                    settingsCubit.setLocale(const Locale("en"));
                    return const Locale("en");
                  }
                }

                return state.locale!;
              },
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: switch (state.theme) {
                SelectThemeEnum.systemTheme => ThemeMode.system,
                SelectThemeEnum.lightTheme => ThemeMode.light,
                SelectThemeEnum.darkTheme => ThemeMode.dark,
              },
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                textTheme: const TextTheme(
                  titleMedium: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    height: 1.33,
                    letterSpacing: 0,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                  titleSmall: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 14,
                    height: 1.33,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                  headlineLarge: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                    height: 0.75,
                    overflow: TextOverflow.ellipsis,
                  ),
                  headlineMedium: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                    height: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              theme: ThemeData(
                colorScheme: lightColorScheme,
                textTheme: const TextTheme(
                  titleMedium: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 16,
                    height: 1.33,
                    letterSpacing: 0,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                  titleSmall: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 14,
                    height: 1.33,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                  headlineLarge: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                    height: 0.75,
                    overflow: TextOverflow.ellipsis,
                  ),
                  headlineMedium: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                    height: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              routerConfig: router,
            );
          },
        );
      },
    );
  }
}
