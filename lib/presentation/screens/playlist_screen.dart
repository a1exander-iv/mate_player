import 'dart:ui';

import 'package:audioplayers/audioplayers.dart' show PlayerState;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mate_player/domain/models/playlist_model.dart';
import 'package:mate_player/domain/models/track_model.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/favorite/favorite_cubit.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/presentation/cubits/playlist_screen/playlist_screen_cubit.dart';
import 'package:mate_player/presentation/cubits/settings/settings_cubit.dart';
import 'package:mate_player/presentation/enums/list_type_enum.dart';
import 'package:mate_player/presentation/widgets/playlist_appbar.dart';
import 'package:mate_player/presentation/widgets/track_grid_tile.dart';
import 'package:mate_player/presentation/widgets/track_tile.dart';
import 'package:mate_player/shared/utils/playlist_duration_info_calc.dart';
import 'package:mate_player/shared/widgets/image_placeholder.dart';
import 'package:mate_player/shared/widgets/mobile_music_bar.dart';
import 'package:mate_player/shared/widgets/music_bar.dart';
import 'package:mate_player/shared/widgets/play_and_pause_button.dart';
import 'package:mate_player/shared/widgets/scroll_to_top_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum PlaylistTrackTilePopupButtonValues { trackDetails, deleteFromPlaylist }

class PlaylistScreen extends StatefulWidget {
  final int playlistId;
  final int playlistNumber;

  const PlaylistScreen(
      {super.key, required this.playlistId, required this.playlistNumber});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late final PlaylistScreenCubit playlistScreenCubit;

  @override
  void initState() {
    playlistScreenCubit = context.read<PlaylistScreenCubit>();
    playlistScreenCubit.load(widget.playlistId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Builder(builder: (context) {
        var screenSize = MediaQuery.of(context).size;
        if (screenSize.width >= 600) {
          return PlaylistDesktopScreen(
            playlistNumber: widget.playlistNumber,
            playlistId: widget.playlistId,
          );
        } else {
          return PlaylistMobileScreen(
            playlistNumber: widget.playlistNumber,
            playlistId: widget.playlistId,
          );
        }
      }),
      bottomNavigationBar: Builder(builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        if (screenSize.width <= 600) {
          return const SizedBox.shrink();
        }
        return BlocBuilder<PlayerCubit, PlayerCubitState>(
          builder: (context, state) {
            switch (state.audioPlayerState) {
              case PlayerState.playing ||
                    PlayerState.paused ||
                    PlayerState.completed:
                return const MusicBar();
              default:
                return const SizedBox.shrink();
            }
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    playlistScreenCubit.cancelSubscription();
    super.dispose();
  }
}

class PlaylistDesktopScreen extends StatefulWidget {
  const PlaylistDesktopScreen(
      {super.key, required this.playlistNumber, required this.playlistId});

  final int playlistNumber;
  final int playlistId;
  @override
  State<PlaylistDesktopScreen> createState() => _PlaylistDesktopScreenState();
}

class _PlaylistDesktopScreenState extends State<PlaylistDesktopScreen> {
  final double rightContentPadding = 155.0;

  final double leftContentPadding = 75.0;
  late final PlaylistScreenCubit playlistScreenCubit;
  late final PlayerCubit playerCubit;
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    playlistScreenCubit = context.read<PlaylistScreenCubit>();
    playerCubit = context.read<PlayerCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    color: colorScheme.surfaceContainer,
                    child: SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16))),
                        height: 400,
                        child: BlocBuilder<PlaylistScreenCubit, PlaylistScreenState>(
                          builder: (context, state) {
                            if (state is PlaylistLoadComplete) {
                              final PlaylistModel playlistData = state.playlistData;
                    
                              final (int hours, int minutes, int seconds) =
                                  playlistDurationInfoCalc(state.playlistTrackList);
                    
                              if (playerCubit.getCurrentPlayingPlaylist != null &&
                                  playerCubit.getCurrentPlayingPlaylist ==
                                      playlistData.id) {
                                List<int> trackSequenceIdList = playerCubit
                                    .getTrackSequenceList
                                    .map((element) => element.id)
                                    .toList();
                    
                                if (!listEquals(
                                    trackSequenceIdList, state.playlistTrackList)) {
                                  context.read<PlayerCubit>().setTrackSequenceList =
                                      state.playlistTrackList;
                                }
                              }
                    
                              return Column(
                                children: [
                                  PlaylistScreenAppBar(
                                    playlistId: playlistData.id,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: leftContentPadding, top: 30),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Stack(
                                          children: [
                                            ImageFiltered(
                                              imageFilter: ImageFilter.blur(
                                                sigmaX: 100,
                                                sigmaY: 50,
                                              ),
                                              child: PlaylistImagePlaceholder(
                                                  width: 264,
                                                  height: 264,
                                                  cachedHeight: 264,
                                                  cachedWidth: 264,
                                                  imageFit: BoxFit.cover,
                                                  imagePath: playlistData.imagePath,
                                                  icon: Icons.library_music,
                                                  iconSize: 64),
                                            ),
                                            PlaylistImagePlaceholder(
                                                width: 264,
                                                height: 264,
                                                cachedHeight: 528,
                                                cachedWidth: 528,
                                                imageFit: BoxFit.cover,
                                                imagePath: playlistData.imagePath,
                                                icon: Icons.library_music,
                                                iconSize: 64),
                                          ],
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                            maxWidth: 700,
                                                            minWidth: 300,
                                                            maxHeight: 100),
                                                        child: Builder(
                                                            builder: (context) {
                                                          return Text(
                                                            playlistData.name ==
                                                                        null ||
                                                                    playlistData
                                                                        .name!.isEmpty
                                                                ? "${AppLocalizations.of(context)!.playlistDefaultName} ${widget.playlistNumber}"
                                                                : playlistData.name!,
                                                            style: textTheme
                                                                .headlineLarge
                                                                ?.copyWith(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .fade,
                                                                    height: 1),
                                                          );
                                                        })),
                                                    const Gap(8),
                                                    Builder(builder: (context) {
                                                      String playlistDurationString =
                                                          "";
                                                      playlistDurationString +=
                                                          "${state.playlistTrackList.length} ${AppLocalizations.of(context)?.nTracks(state.playlistTrackList.length)},";
                    
                                                      if (hours > 0) {
                                                        playlistDurationString +=
                                                            " $hours ${AppLocalizations.of(context)?.nHours(hours)}";
                                                      }
                    
                                                      playlistDurationString +=
                                                          " $minutes ${AppLocalizations.of(context)?.shortMinute}";
                                                      playlistDurationString +=
                                                          " $seconds ${AppLocalizations.of(context)?.shortSecond}";
                    
                                                      return Text(
                                                        playlistDurationString,
                                                        style: textTheme.titleMedium
                                                            ?.copyWith(
                                                                fontSize: 24,
                                                                overflow: TextOverflow
                                                                    .ellipsis),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(top: 32),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      PlaylistPlayAndPause(
                                                        playlistId: playlistData.id,
                                                        onPressed: () {
                                                          context
                                                              .read<PlayerCubit>()
                                                              .playlistPlayAndPause(
                                                                  state
                                                                      .playlistTrackList,
                                                                  state.playlistData
                                                                      .id);
                                                        },
                                                        iconSize: 48,
                                                      ),
                                                      const Gap(8),
                                                      LikeButtonPlaylist(
                                                        playlistId: playlistData.id,
                                                        size: 48,
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  PlaylistScreenAppBar(
                                    playlistId: widget.playlistId,
                                  ),
                                  Skeletonizer(
                                      child: PlaylistDesktopSkeleton(
                                          leftContentPadding: leftContentPadding)),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SliverPadding(
                padding:
                    EdgeInsets.only(left: leftContentPadding, right: 64, top: 8),
                sliver: PlaylistTrackList())
          ],
        ),
        ScrollToTopFloatingButton(scrollController: scrollController)
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class PlaylistDesktopSkeleton extends StatelessWidget {
  const PlaylistDesktopSkeleton({super.key, required this.leftContentPadding});

  final double leftContentPadding;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(left: leftContentPadding, top: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 264,
                height: 264,
                decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10)),
              ),
              Flexible(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: 700,
                                        minWidth: 300,
                                        maxHeight: 100),
                                    child: Builder(builder: (context) {
                                      return Text(
                                        "Playlist",
                                        style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold),
                                      );
                                    })),
                                const Gap(8),
                                Builder(builder: (context) {
                                  return Text(
                                    "0 min 0 sec",
                                    style: TextStyle(
                                      fontSize: 24,
                                    ),
                                  );
                                }),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  PlayAndPauseButton(
                                    onPressed: () {},
                                    iconSize: 48,
                                  ),
                                  const Gap(8),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.favorite,
                                    ),
                                    iconSize: 48,
                                  ),
                                ],
                              ),
                            ),
                          ]))),
            ],
          ))
    ]);
  }
}

class PlaylistMobileSkeleton extends StatelessWidget {
  const PlaylistMobileSkeleton(
      {super.key, required this.leftContentPadding, required this.playlistId});

  final double leftContentPadding;
  final int playlistId;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Column(children: [
      SafeArea(
          child: Container(
              decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16))),
              height: 220,
              child: Column(
                children: [
                  PlaylistScreenAppBar(
                    playlistId: playlistId,
                  ),
                  Skeletonizer(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: leftContentPadding,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: 400,
                                              minWidth: 200,
                                              maxHeight: 50),
                                          child: Builder(builder: (context) {
                                            return Text(
                                              "Playlist",
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                      overflow:
                                                          TextOverflow.fade,
                                                      height: 1,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            );
                                          })),
                                      const Gap(8),
                                      Builder(builder: (context) {
                                        return Text(
                                          "00:00",
                                          style: textTheme.titleSmall?.copyWith(
                                              overflow: TextOverflow.ellipsis),
                                        );
                                      }),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        PlayAndPauseButton(
                                          onPressed: () {},
                                          iconSize: 28,
                                        ),
                                        const Gap(8),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.favorite),
                                          iconSize: 24,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )))
    ]);
  }
}

class PlaylistTrackList extends StatelessWidget {
  const PlaylistTrackList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistScreenCubit, PlaylistScreenState>(
      builder: (context, playlistScreenState) {
         return BlocBuilder<SettingsCubit, SettingsState>(
            builder:(context, settingsState) {
              
             if (playlistScreenState is PlaylistLoadComplete) {
              PlaylistModel playlistData = playlistScreenState.playlistData;
              List<TrackModel> playlist = playlistScreenState.playlistTrackList;
               switch (settingsState.listType) {
                  case ListTypeEnum.gridView:
                    return PlaylistGridList(playlist: playlist, playlistId: playlistData.id,);
                  case ListTypeEnum.listView:
                    return PlaylistTileList(playlistId: playlistData.id, playlistTrackList: playlist);
                }
             } else {
                switch (settingsState.listType) {
                  case ListTypeEnum.gridView:
                    return SkeletonGridList();
                  case ListTypeEnum.listView:
                    return SkeletonTrackListTemplate();
                }
             }

            },);

      },
    );
  }
}

class PlaylistMobileScreen extends StatefulWidget {
  const PlaylistMobileScreen(
      {super.key, required this.playlistNumber, required this.playlistId});

  final int playlistNumber;
  final int playlistId;

  @override
  State<PlaylistMobileScreen> createState() => _PlaylistMobileScreenState();
}

class _PlaylistMobileScreenState extends State<PlaylistMobileScreen> {
  final double rightContentPadding = 16;

  final double leftContentPadding = 16;

  late final PlaylistScreenCubit playlistScreenCubit;
  late final PlayerCubit playerCubit;
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    playlistScreenCubit = context.read<PlaylistScreenCubit>();
    playerCubit = context.read<PlayerCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    color: colorScheme.surfaceContainer,
                    child: SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16))),
                        height: 220,
                        child:
                            BlocBuilder<PlaylistScreenCubit, PlaylistScreenState>(
                          builder: (context, state) {
                            if (state is PlaylistLoadComplete) {
                              final PlaylistModel playlistData =
                                  state.playlistData;
                    
                              final (int hours, int minutes, int seconds) =
                                  playlistDurationInfoCalc(
                                      state.playlistTrackList);
                    
                              if (playerCubit.getCurrentPlayingPlaylist != null &&
                                  playerCubit.getCurrentPlayingPlaylist ==
                                      playlistData.id) {
                                List<int> trackSequenceIdList = playerCubit
                                    .getTrackSequenceList
                                    .map((element) => element.id)
                                    .toList();
                    
                                if (!listEquals(trackSequenceIdList,
                                    state.playlistTrackList)) {
                                  context
                                          .read<PlayerCubit>()
                                          .setTrackSequenceList =
                                      state.playlistTrackList;
                                }
                              }
                    
                              return Column(
                                children: [
                                  PlaylistScreenAppBar(
                                    playlistId: widget.playlistId,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: leftContentPadding, top: 0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Stack(
                                          children: [
                                            ImageFiltered(
                                              imageFilter: ImageFilter.blur(
                                                sigmaX: 25,
                                                sigmaY: 25,
                                              ),
                                              child: PlaylistImagePlaceholder(
                                                  width: 140,
                                                  height: 140,
                                                  cachedHeight: 140,
                                                  cachedWidth: 140,
                                                  imageFit: BoxFit.cover,
                                                  imagePath:
                                                      playlistData.imagePath,
                                                  icon: Icons.library_music,
                                                  iconSize: 32),
                                            ),
                                            PlaylistImagePlaceholder(
                                                width: 140,
                                                height: 140,
                                                cachedHeight: 140,
                                                cachedWidth: 140,
                                                imageFit: BoxFit.cover,
                                                imagePath: playlistData.imagePath,
                                                icon: Icons.library_music,
                                                iconSize: 32),
                                          ],
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth: 400,
                                                                minWidth: 200,
                                                                maxHeight: 50),
                                                        child: Builder(
                                                            builder: (context) {
                                                          return Text(
                                                            playlistData.name ==
                                                                        null ||
                                                                    playlistData
                                                                        .name!
                                                                        .isEmpty
                                                                ? "${AppLocalizations.of(context)!.playlistDefaultName} ${widget.playlistNumber}"
                                                                : playlistData
                                                                    .name!,
                                                            style: textTheme
                                                                .titleMedium
                                                                ?.copyWith(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .fade,
                                                                    height: 1,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          );
                                                        })),
                                                    const Gap(8),
                                                    Builder(builder: (context) {
                                                      String
                                                          playlistDurationString =
                                                          "";
                                                      playlistDurationString +=
                                                          "${state.playlistTrackList.length} ${AppLocalizations.of(context)?.nTracks(state.playlistTrackList.length)},";
                    
                                                      if (hours > 0) {
                                                        playlistDurationString +=
                                                            " $hours ${AppLocalizations.of(context)?.nHours(hours)}";
                                                      }
                    
                                                      playlistDurationString +=
                                                          " $minutes ${AppLocalizations.of(context)?.shortMinute}";
                                                      playlistDurationString +=
                                                          " $seconds ${AppLocalizations.of(context)?.shortSecond}";
                    
                                                      return Text(
                                                        playlistDurationString,
                                                        style: textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 8),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      PlaylistPlayAndPause(
                                                        playlistId:
                                                            playlistData.id,
                                                        onPressed: () {
                                                          context
                                                              .read<PlayerCubit>()
                                                              .playlistPlayAndPause(
                                                                  state
                                                                      .playlistTrackList,
                                                                  state
                                                                      .playlistData
                                                                      .id);
                                                        },
                                                        iconSize: 28,
                                                      ),
                                                      LikeButtonPlaylist(
                                                        playlistId:
                                                            playlistData.id,
                                                        size: 24,
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return PlaylistMobileSkeleton(
                                  leftContentPadding: leftContentPadding,
                                  playlistId: widget.playlistId);
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            BlocBuilder<PlayerCubit, PlayerCubitState>(
              builder: (context, state) {
                double bottomPadding = 0;
                if (state.audioPlayerState == PlayerState.paused ||
                    state.audioPlayerState == PlayerState.playing) {
                  bottomPadding = 64;
                }
                return SliverPadding(
                    padding: EdgeInsets.only(
                        left: leftContentPadding,
                        right: rightContentPadding,
                        top: 8,
                        bottom: bottomPadding),
                    sliver: PlaylistTrackList());
              },
            )
          ],
        ),
        BlocBuilder<PlayerCubit, PlayerCubitState>(
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
        ScrollToTopFloatingButton(scrollController: scrollController, isMobilePlaylistScreen: true,)
      ],
    );
  }
}

class LikeButtonPlaylist extends StatelessWidget {
  const LikeButtonPlaylist({super.key, required this.playlistId, this.size});

  final int playlistId;
  final double? size;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<FavoriteCubit, FavoriteState>(
      builder: (context, state) {
        final bool favorite = state is FavoriteInfoLoadComplete &&
                state.playlistFavoriteMap.containsKey(playlistId)
            ? true
            : false;
        return IconButton(
          onPressed: () {
            context
                .read<FavoriteCubit>()
                .setFavoritePlaylist(playlistId, favorite);
          },
          icon: Icon(
            favorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            size: size,
            color: colorScheme.primary,
          ),
        );
      },
    );
  }
}

class ReorderableList extends StatefulWidget {
  const ReorderableList({super.key});

  @override
  State<ReorderableList> createState() => _ReorderableListState();
}

class _ReorderableListState extends State<ReorderableList> {
  final List<int> _items = List<int>.generate(50, (int index) => index);
  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
        itemBuilder: (context, index) {
          return ReorderableDragStartListener(
            index: index,
            key: Key('$index'),
            child: Material(
              child: ListTile(
                title: Text("${_items[index]}"),
              ),
            ),
          );
        },
        itemCount: _items.length,
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final int item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        });
  }
}
