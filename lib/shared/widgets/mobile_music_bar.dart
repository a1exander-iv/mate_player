

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/picture/pictures_cubit.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/presentation/cubits/short_info/track_short_info_cubit.dart';
import 'package:mate_player/shared/utils/parse_track_image.dart';
import 'package:mate_player/shared/widgets/image_placeholder.dart';
import 'package:mate_player/shared/widgets/music_bar.dart';
import 'package:mate_player/shared/widgets/play_and_pause_button.dart';

class MobileMusicBar extends StatelessWidget {
  const MobileMusicBar({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SizedBox(
      height: 64,
      width: screenSize.width,
      child: Material(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          onTap: () {
            GoRouter.of(context).pushNamed("player");
          },
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: BlocBuilder<TrackShortInfoCubit, TrackShortInfoState>(
              builder: (context, trackShortInfoState) {
                if (trackShortInfoState is TrackShortInfoLoadComplete) {
                  return ListTile(
                    visualDensity: VisualDensity.compact,
                    enabled: false,
                    contentPadding: const EdgeInsets.only(left: 16, right: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                    leading: BlocBuilder<PicturesCubit, PicturesState>(
                      builder: (context, state) {
                        String? imagePath = state is PicturesLoadComplete
                            ? parseTrackImagePath(
                                state.picturesDataMap,
                                trackShortInfoState.playingTrack.filePath,
                              )
                            : null;

                        return Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          height: 48,
                          width: 48,
                          clipBehavior: Clip.hardEdge,
                          child: ImagePlaceholder(
                            imagePath: imagePath,
                            icon: Icons.music_note,
                            cachedHeight: 48,
                            cachedWidth: 48,
                          ),
                        );
                      },
                    ),
                    title: Text(
                      trackShortInfoState.playingTrack.trackTitle ??
                          trackShortInfoState.playingTrack.fileBaseName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    subtitle: Text(
                      trackShortInfoState.playingTrack.trackArtist ??
                          AppLocalizations.of(context)!.unknownArtist,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onTap: () {},
                    trailing: BlocBuilder<PlayerCubit, PlayerCubitState>(
                      builder: (context, state) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MusicBarButton(
                              isActive: state.isPreviousButtonActive,
                              onPressed: () {
                                context
                                    .read<PlayerCubit>()
                                    .onPreviousButtonPressed();
                              },
                              icon: Icons.navigate_before,
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(width: 10),
                            PlayAndPauseButton(
                              onPressed: () {
                                context.read<PlayerCubit>().playAndPause();
                              },
                            ),
                            const SizedBox(width: 10),
                            MusicBarButton(
                              isActive: state.isNextButtonActive,
                              onPressed: () {
                                context
                                    .read<PlayerCubit>()
                                    .onNextButtonPressed();
                              },
                              icon: Icons.navigate_next,
                              width: 32,
                              height: 32,
                            ),
                          ],
                        );
                      },
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
