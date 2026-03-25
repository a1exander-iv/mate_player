import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mate_player/domain/models/track_model.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/favorite/favorite_cubit.dart';
import 'package:mate_player/presentation/cubits/picture/pictures_cubit.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/shared/utils/parse_track_image.dart';
import 'package:mate_player/shared/utils/path_parser_from_source.dart';
import 'package:mate_player/shared/utils/seconds_to_string.dart';
import 'package:mate_player/shared/widgets/image_placeholder.dart';
import 'package:mate_player/shared/widgets/tile_menu.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum TrackTilePopupButtonValues { trackDetails, deleteFromList }

class TrackTileTemplate extends StatelessWidget {
  const TrackTileTemplate({
    super.key,
    required this.track,
    this.isSequenceList = false,
    this.onTap,
    this.menu,
    this.showLikeIcon = true,
    this.showTrackDuration = true,
  });

  final TrackModel track;
  final bool isSequenceList;
  final Function()? onTap;
  final Widget? menu;
  final bool showLikeIcon;
  final bool showTrackDuration;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<PlayerCubit, PlayerCubitState>(
      builder: (context, state) {
        bool isPlaying = false;

        if (pathFromPlayerSource(source: state.source) == track.filePath &&
            (state.audioPlayerState == PlayerState.playing ||
                state.audioPlayerState == PlayerState.paused)) {
          isPlaying = true;
        }
        return Card(
          margin: EdgeInsets.zero,
          borderOnForeground: false,
          elevation: 0,
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16, right: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            selected: isPlaying,
            tileColor: track.playbackError ? colorScheme.errorContainer : null,
            selectedTileColor: colorScheme.secondaryContainer,
            leading: BlocBuilder<PicturesCubit, PicturesState>(
              builder: (context, state) {
                String? imagePath = state is PicturesLoadComplete
                    ? parseTrackImagePath(state.picturesDataMap, track.filePath)
                    : null;
                return ImagePlaceholder(
                  imagePath: imagePath,
                  imageFit: BoxFit.contain,
                  icon: Icons.music_note,
                  height: 48,
                  width: 48,
                  cachedHeight: 48,
                  cachedWidth: 48,
                );
              },
            ),
            title: Text(
              track.trackTitle != null && track.trackTitle!.isNotEmpty
                  ? track.trackTitle!
                  : track.fileBaseName,
              style: textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              track.trackArtist != null && track.trackArtist!.isNotEmpty
                  ? track.trackArtist!
                  : AppLocalizations.of(context)!.unknownArtist,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () {
              if (onTap != null) {
                onTap!();
              }
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BlocBuilder<FavoriteCubit, FavoriteState>(
                  builder: (context, state) {
                    final bool favorite =
                        state is FavoriteInfoLoadComplete &&
                            state.tracksFavoriteMap.containsKey(track.id)
                        ? true
                        : false;
                    return Builder(
                      builder: (context) {
                        if (favorite && showLikeIcon) {
                          return SizedBox(
                            width: 24,
                            height: 24,
                            child: Icon(
                              Icons.favorite,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    if (showTrackDuration) {
                      return SizedBox(
                        width: 50,
                        child: Builder(
                          builder: (context) {
                            if (track.trackDurationInMilliseconds != null) {
                              return Text(
                                secondsToString(
                                  Duration(
                                    milliseconds: track
                                        .trackDurationInMilliseconds!
                                        .toInt(),
                                  ).inSeconds,
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                Builder(
                  builder: (context) {
                    return menu != null ? menu! : const SizedBox.shrink();
                  },
                ),
                Builder(
                  builder: (context) {
                    if (isSequenceList) {
                      return const Icon(Icons.drag_handle);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MainListTile extends StatelessWidget {
  const MainListTile({super.key, required this.track, required this.onTap});

  final TrackModel track;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return TrackTileTemplate(
      track: track,
      onTap: onTap,
      menu: TrackTileMenu(track: track),
    );
  }
}

class SequenceListTile extends StatelessWidget {
  const SequenceListTile({super.key, required this.track});

  final TrackModel track;
  @override
  Widget build(BuildContext context) {
    return TrackTileTemplate(
      track: track,
      showLikeIcon: false,
      showTrackDuration: true,
      onTap: () {
        context.read<PlayerCubit>().tilePlay(track: track);
      },
    );
  }
}

class PlaylistTrackTile extends StatelessWidget {
  const PlaylistTrackTile({
    super.key,
    required this.track,
    this.onTap,
    required this.playlistId,
  });

  final TrackModel track;
  final Function()? onTap;
  final int playlistId;

  @override
  Widget build(BuildContext context) {
    return TrackTileTemplate(
      track: track,
      onTap: onTap,
      menu: PlaylistTrackTileMenu(track: track, playlistId: playlistId),
    );
  }
}

class CheckboxTrackTile extends StatelessWidget {
  const CheckboxTrackTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.track,
  });

  final bool value;
  final void Function(bool?)? onChanged;
  final TrackModel track;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      selected: value,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BlocBuilder<PicturesCubit, PicturesState>(
            builder: (context, state) {
              String? imagePath = state is PicturesLoadComplete
                  ? parseTrackImagePath(state.picturesDataMap, track.filePath)
                  : null;

              return ImagePlaceholder(
                imagePath: imagePath,
                imageFit: BoxFit.contain,
                icon: Icons.music_note,
                height: 48,
                width: 48,
                cachedHeight: 48,
                cachedWidth: 48,
              );
            },
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.trackTitle != null && track.trackTitle!.isNotEmpty
                      ? track.trackTitle!
                      : track.fileBaseName,
                  style: textTheme.titleMedium,
                ),
                Text(
                  track.trackArtist != null && track.trackArtist!.isNotEmpty
                      ? track.trackArtist!
                      : AppLocalizations.of(context)!.unknownArtist,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.only(left: 16, right: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class ReorderableSequenceTrackTile extends StatelessWidget {
  const ReorderableSequenceTrackTile({super.key, required this.track});
  final TrackModel track;

  @override
  Widget build(BuildContext context) {
    return TrackTileTemplate(
      track: track,
      isSequenceList: true,
      showLikeIcon: false,
    );
  }
}

class ReorderableTrackTile extends StatelessWidget {
  const ReorderableTrackTile({
    super.key,
    required this.index,
    required this.track,
    required this.trackImagePath,
  });

  final TrackModel track;
  final int index;
  final String? trackImagePath;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      borderOnForeground: false,
      elevation: 0,
      child: ListTile(
        leading: Text("$index"),
        title: Row(
          children: [
            ImagePlaceholder(
              imagePath: trackImagePath,
              imageFit: BoxFit.contain,
              icon: Icons.music_note,
              height: 48,
              width: 48,
              cachedHeight: 48,
              cachedWidth: 48,
            ),
            const Gap(8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.trackTitle != null && track.trackTitle!.isNotEmpty
                        ? track.trackTitle!
                        : track.fileBaseName,
                    style: textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    track.trackArtist != null && track.trackArtist!.isNotEmpty
                        ? track.trackArtist!
                        : AppLocalizations.of(context)!.unknownArtist,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              child: Builder(
                builder: (context) {
                  if (track.trackDurationInMilliseconds != null) {
                    return Text(
                      secondsToString(
                        Duration(
                          milliseconds: track.trackDurationInMilliseconds!
                              .toInt(),
                        ).inSeconds,
                      ),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonTrackListTemplate extends StatelessWidget {
  const SkeletonTrackListTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.sliver(
      child: SliverList.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text("Track Title"),
              subtitle: Text("Artist"),
              leading: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 48,
                height: 48,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PlaylistTileList extends StatelessWidget {
  const PlaylistTileList({
    super.key,
    required this.playlistId,
    required this.playlistTrackList,
  });

  final List<TrackModel> playlistTrackList;
  final int playlistId;
  @override
  Widget build(BuildContext context) {
    PlayerCubit playerCubit = context.read<PlayerCubit>();
    return _ListTemplate(
      itemBuilder: (context, index) {
        final TrackModel track = playlistTrackList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PlaylistTrackTile(
            playlistId: playlistId,
            onTap: () {
              playerCubit.playlistTilePlay(
                track: track,
                audioList: playlistTrackList,
                playlistId: playlistId,
              );
            },
            track: track,
          ),
        );
      },
      itemCount: playlistTrackList.length,
    );
  }
}

class _ListTemplate extends StatelessWidget {
  const _ListTemplate({
    required this.itemBuilder,
    required this.itemCount,
  });

  final Widget? Function(BuildContext context, int index) itemBuilder;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(itemBuilder: itemBuilder, itemCount: itemCount);
  }
}
