import 'package:audioplayers/audioplayers.dart' show PlayerState;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mate_player/domain/models/track_model.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/audio_loader/audio_loader_cubit.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/presentation/cubits/playlist/playlist_cubit.dart';
import 'package:mate_player/presentation/cubits/settings/settings_cubit.dart';
import 'package:mate_player/presentation/enums/list_type_enum.dart';
import 'package:mate_player/presentation/enums/select_sorting_enum.dart';
import 'package:mate_player/presentation/widgets/playlist_widget.dart';
import 'package:mate_player/presentation/widgets/track_grid_tile.dart';
import 'package:mate_player/presentation/widgets/track_tile.dart'
    show SkeletonTrackListTemplate, MainListTile;
import 'package:mate_player/shared/utils/folder_selection.dart';
import 'package:mate_player/shared/widgets/add_button.dart';
import 'package:mate_player/shared/widgets/mobile_music_bar.dart';
import 'package:mate_player/shared/widgets/scroll_to_top_button.dart';
import 'package:mate_player/shared/widgets/track_list_type_selection.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (previous, current) {
          return previous.directoryList != current.directoryList;
        }, builder: (context, state) {
          if (state.directoryList.isNotEmpty) {
            return LayoutBuilder(builder: (context, constraints) {
              Size screenSize = MediaQuery.of(context).size;
              if (screenSize.width >= 600) {
                double rightContentPadding = 16;
                double leftContentPadding = 16;
                if (screenSize.width >= 1200) {
                  rightContentPadding = 155.0;
                  leftContentPadding = 75.0;
                }
        
                return MainScreenLayout(
                  leftContentPadding: leftContentPadding,
                  rightContentPadding: rightContentPadding,
                  isMobileLayout: false,
                );
              } else {
                const double rightContentPadding = 16;
                const double leftContentPadding = 16;
        
                return const MobileMainScreenLayout(
                    leftContentPadding: leftContentPadding,
                    rightContentPadding: rightContentPadding);
              }
            });
          } else {
            return EmptyFolderList();
          }
        }));
  }
}

class MainScreenLayout extends StatelessWidget {
  MainScreenLayout({
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
    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: leftContentPadding, right: rightContentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchBarWidget(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: leftContentPadding, right: rightContentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<PlaylistCubit, PlaylistState>(
                          builder: (context, state) {
                        if (state is PlaylistCatalogLoadComplete &&
                            state.playlistCatalog.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20, bottom: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.playlistsHeadline,
                                      style: isMobileLayout
                                          ? textTheme.headlineMedium
                                          : textTheme.headlineLarge,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: PlaylistWidget(
                                  playlistCatalog: state.playlistCatalog,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.tracksHeadline,
                                style: isMobileLayout
                                    ? textTheme.headlineMedium
                                    : textTheme.headlineLarge,
                              ),
                            ),
                            Row(children: [
                            TrackListTypeSelection(),
                            SortMainListMenu(),
                            ],)
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: leftContentPadding,
              right: rightContentPadding,
              top: 20,
            ),
            sliver: BlocBuilder<AudioLoaderCubit, AudioLoaderState>(
              builder: (context, audioLoaderState) {
                return BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settingsState) {
                  
                  if (audioLoaderState is AudioLoadComplete) {
        
                    switch (settingsState.listType) {
                      case ListTypeEnum.gridView:
                        return TrackGridList(trackList: audioLoaderState.audioList);
                      case ListTypeEnum.listView:
                        return TrackList(audioList: audioLoaderState.audioList);
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
            ),
          ),
        ]),
        ScrollToTopFloatingButton(scrollController: scrollController)
        ],
    );
  }
}

class EmptyFolderList extends StatelessWidget {
  const EmptyFolderList({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.folder,
                    size: 72,
                    color: colorScheme.primary,
                  )),
              Text(
                AppLocalizations.of(context)!.emptyFolderListTitle,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium
                    ?.copyWith(overflow: TextOverflow.visible),
              ),
              const Gap(8),
              Text(
                AppLocalizations.of(context)!.emptyFolderListSubtitle,
                textAlign: TextAlign.center,
                style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.secondary,
                    overflow: TextOverflow.visible),
              ),
              const Gap(8),
              OutlinedButton(
                  onPressed: () async {
                    await folderSelection(context);
                  },
                  child: Text(AppLocalizations.of(context)!.chooseFolderButton)),
            ],
          ),
        )
      ],
    );
  }
}

class TrackList extends StatelessWidget {
  const TrackList({
    super.key,
    required this.audioList,
  });

  final List<TrackModel> audioList;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: audioList.length,
      itemBuilder: (context, index) {
        TrackModel track = audioList[index];
        return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MainListTile(
              onTap: () async {
                context
                    .read<PlayerCubit>()
                    .mainListTilePlay(track: track, audioList: audioList);
              },
              track: track,
            ));
      },
    );
  }
}

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final FocusNode _buttonFocusNode = FocusNode();

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(builder: (context) {
                Size screenSize = MediaQuery.of(context).size;
                if (screenSize.width < 600) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FloatingAddButton(),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
              Flexible(
                child: Focus(
                  skipTraversal: true,
                  child: BlocBuilder<AudioLoaderCubit, AudioLoaderState>(
                    builder: (context, state) {
                      return SearchAnchor.bar(
                        viewBuilder: (suggestions) {
                          return CustomScrollView(
                            slivers: [
                              SliverList.builder(
                                itemCount: suggestions.length,
                                itemBuilder: (context, index) {
                                  return suggestions.toList()[index];
                                },
                              ),
                            ],
                          );
                        },
                        suggestionsBuilder: (context, controller) {
                          final String inputValue =
                              controller.value.text.toLowerCase();
                          List<Widget> searchList = [];
                          if (state is AudioLoadComplete) {
                            searchList = state.audioList.where((track) {
                              if (track.trackTitle != null &&
                                  track.trackTitle!
                                      .toLowerCase()
                                      .contains(inputValue)) {
                                return true;
                              }

                              if (track.fileBaseName
                                  .toLowerCase()
                                  .contains(inputValue)) {
                                return true;
                              }

                              if (track.trackArtist != null &&
                                  track.trackArtist!
                                      .toLowerCase()
                                      .contains(inputValue)) {
                                return true;
                              }

                              return false;
                            }).map((track) {
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: MainListTile(
                                      track: track,
                                      onTap: () {
                                        context
                                                .read<PlayerCubit>()
                                                .setTrackSequenceList =
                                            state.audioList;
                                        context.read<PlayerCubit>().tilePlay(
                                              track: track,
                                            );
                                      }));
                            }).toList();
                          }

                          if (searchList.isNotEmpty) {
                            return searchList;
                          } else {
                            return [];
                          }
                        },

                        barLeading: const Icon(Icons.search),
                        barHintText: AppLocalizations.of(context)!.searchHint,
                        barBackgroundColor: WidgetStateProperty.resolveWith(
                            (states) => Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh),

                        barHintStyle: WidgetStateProperty.resolveWith(
                            (states) => const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0)),
                        
                        barElevation:
                            WidgetStateProperty.resolveWith((states) => 0),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class SortMainListMenu extends StatefulWidget {
  const SortMainListMenu({super.key});

  @override
  State<SortMainListMenu> createState() => _SortMainListMenuState();
}

class _SortMainListMenuState extends State<SortMainListMenu> {
  @override
  Widget build(BuildContext context) {
    final SettingsCubit settingsCubit = context.read<SettingsCubit>();
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MenuAnchor(
            alignmentOffset: Offset.zero,
            builder: (BuildContext context, MenuController controller,
                Widget? child) {
              return TextButton.icon(
                icon: state.sortValue == SelectSortingEnum.withoutSorting
                    ? const Icon(Icons.filter_list_off)
                    : const Icon(Icons.filter_list),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                label: Text(appLocalizations.sortLabel),
              );
            },
            menuChildren: [
              RadioMenuButton(
                  value: SelectSortingEnum.byDurationAscending,
                  groupValue: state.sortValue,
                  onChanged: (value) {
                    settingsCubit.setSortValue(value!);
                    context.read<AudioLoaderCubit>().sort(value);
                  },
                  child: Text(appLocalizations.sortByDurationAscending)),
              RadioMenuButton(
                  value: SelectSortingEnum.byDurationDescending,
                  groupValue: state.sortValue,
                  onChanged: (value) {
                    settingsCubit.setSortValue(value!);
                    context.read<AudioLoaderCubit>().sort(value);
                  },
                  child: Text(appLocalizations.sortByDurationDescending)),
              RadioMenuButton(
                  value: SelectSortingEnum.byDateAddedAscending,
                  groupValue: state.sortValue,
                  onChanged: (value) {
                    settingsCubit.setSortValue(value!);
                    context.read<AudioLoaderCubit>().sort(value);
                  },
                  child: Text(appLocalizations.sortByDateAddedAscending)),
              RadioMenuButton(
                  value: SelectSortingEnum.byDateAddedDescending,
                  groupValue: state.sortValue,
                  onChanged: (value) {
                    settingsCubit.setSortValue(value!);
                    context.read<AudioLoaderCubit>().sort(value);
                  },
                  child: Text(appLocalizations.sortByDateAddedDescending)),
              RadioMenuButton(
                  value: SelectSortingEnum.byTitleAscending,
                  groupValue: state.sortValue,
                  onChanged: (value) {
                    settingsCubit.setSortValue(value!);
                    context.read<AudioLoaderCubit>().sort(value);
                  },
                  child: Text(appLocalizations.sortByTitleAscending)),
              RadioMenuButton(
                  value: SelectSortingEnum.byTitleDescending,
                  groupValue: state.sortValue,
                  onChanged: (value) {
                    settingsCubit.setSortValue(value!);
                    context.read<AudioLoaderCubit>().sort(value);
                  },
                  child: Text(appLocalizations.sortByTitleDescending)),
              RadioMenuButton(
                  value: SelectSortingEnum.byFileNameAscending,
                  groupValue: state.sortValue,
                  onChanged: (value) {
                    settingsCubit.setSortValue(value!);
                    context.read<AudioLoaderCubit>().sort(value);
                  },
                  child: Text(appLocalizations.sortByFileNameAscending)),
              RadioMenuButton(
                  value: SelectSortingEnum.byFileNameDescending,
                  groupValue: state.sortValue,
                  onChanged: (value) {
                    settingsCubit.setSortValue(value!);
                    context.read<AudioLoaderCubit>().sort(value);
                  },
                  child: Text(appLocalizations.sortByFileNameDescending)),
              RadioMenuButton(
                  value: SelectSortingEnum.withoutSorting,
                  groupValue: state.sortValue,
                  onChanged: (value) {
                    settingsCubit.setSortValue(value!);
                    context.read<AudioLoaderCubit>().sort(value);
                  },
                  child: Text(appLocalizations.withoutSortingMainList)),
            ]);
      },
    );
  }
}

class MobileMainScreenLayout extends StatelessWidget {
  const MobileMainScreenLayout({
    super.key,
    required this.leftContentPadding,
    required this.rightContentPadding,
  });

  final double leftContentPadding;
  final double rightContentPadding;

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
        body: MainScreenLayout(
          leftContentPadding: leftContentPadding,
          rightContentPadding: rightContentPadding,
          isMobileLayout: true,
        ));
  }
}

