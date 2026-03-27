import 'package:audioplayers/audioplayers.dart' show PlayerState;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mate_player/data/repositories/database_repository.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/favorite_screen/favorite_screen_cubit.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/presentation/cubits/settings/settings_cubit.dart';
import 'package:mate_player/presentation/enums/list_type_enum.dart';
import 'package:mate_player/presentation/screens/main_screen.dart';
import 'package:mate_player/presentation/widgets/playlist_widget.dart';
import 'package:mate_player/presentation/widgets/track_grid_tile.dart';
import 'package:mate_player/shared/widgets/mobile_music_bar.dart';
import 'package:mate_player/shared/widgets/scroll_to_top_button.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      create: (context) =>
          FavoriteScreenCubit(context.read<DatabaseRepository>())..init(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 56,
          title: Text(
            AppLocalizations.of(context)!.favoriteScreen,
            style: textTheme.headlineMedium,
          ),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            double rightContentPadding = 16;
            double leftContentPadding = 16;

            Size screenSize = MediaQuery.of(context).size;
            if (screenSize.width < 600) {
              return FavoriteScreenMobileLayout(
                leftContentPadding: leftContentPadding,
                rightContentPadding: rightContentPadding,
              );
            }
            if (screenSize.width >= 1200) {
              rightContentPadding = 155.0;
              leftContentPadding = 75.0;
            }

            return FavoriteScreenLayout(
              leftContentPadding: leftContentPadding,
              rightContentPadding: rightContentPadding,
              isMobileLayout: false,
            );
          },
        ),
      ),
    );
  }
}

class FavoriteScreenMobileLayout extends StatelessWidget {
  const FavoriteScreenMobileLayout({
    super.key,
    required this.leftContentPadding,
    required this.rightContentPadding,
  });

  final double rightContentPadding;
  final double leftContentPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BlocBuilder<PlayerCubit, PlayerCubitState>(
        builder: (context, state) {
          if (state.audioPlayerState == PlayerState.playing ||
              state.audioPlayerState == PlayerState.paused ||
              state.audioPlayerState == PlayerState.completed) {
            return const MobileMusicBar();
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      body: FavoriteScreenLayout(
        leftContentPadding: leftContentPadding,
        rightContentPadding: rightContentPadding,
        isMobileLayout: true,
      ),
    );
  }
}

class FavoriteScreenLayout extends StatelessWidget {
  FavoriteScreenLayout({
    super.key,
    required this.leftContentPadding,
    required this.rightContentPadding,
    required this.isMobileLayout,
  });

  final double leftContentPadding;
  final double rightContentPadding;
  final bool isMobileLayout;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return BlocBuilder<FavoriteScreenCubit, FavoriteScreenState>(
      builder: (context, state) {
        if (state is FavoriteScreenLoadComplete) {
          return Builder(
            builder: (context) {
              if (state.favoritePlaylistData.isNotEmpty ||
                  state.favoriteTrackData.isNotEmpty) {
                return Stack(
                  children: [
                    CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.only(
                            top: 8,
                            left: leftContentPadding,
                            right: rightContentPadding,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Builder(
                              builder: (context) {
                                if (state.favoritePlaylistData.isNotEmpty) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 20,
                                          bottom: 16,
                                        ),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.favoritePlaylistsHeadline,
                                          style: isMobileLayout
                                              ? textTheme.headlineMedium
                                              : textTheme.headlineLarge,
                                        ),
                                      ),
                                      PlaylistWidget(
                                        playlistCatalog: state
                                            .favoritePlaylistData
                                            .reversed
                                            .toList(),
                                      ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(
                            top: 20,
                            left: leftContentPadding,
                            right: rightContentPadding,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Builder(
                              builder: (context) {
                                if (state.favoriteTrackData.isNotEmpty) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.favoriteTracksHeadline,
                                        style: isMobileLayout
                                            ? textTheme.headlineMedium
                                            : textTheme.headlineLarge,
                                      ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(
                            top: 20,
                            left: leftContentPadding,
                            right: rightContentPadding,
                          ),
                          sliver: BlocBuilder<SettingsCubit, SettingsState>(
                            builder: (context, settingsState) {
                              
                              if (settingsState.listType == ListTypeEnum.gridView) {
                                return TrackGridList(trackList: state.favoriteTrackData);
                              } else {
                                return TrackList(audioList: state.favoriteTrackData);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    ScrollToTopFloatingButton(scrollController: scrollController)
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
