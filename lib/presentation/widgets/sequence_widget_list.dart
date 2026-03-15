import 'package:audioplayers/audioplayers.dart' show PlayerState;
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mate_player/domain/models/track_model.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/presentation/enums/repeat_mode_enum.dart';
import 'package:mate_player/presentation/widgets/track_tile.dart'
    show SequenceListTile, ReorderableSequenceTrackTile;

class SequenceListWidget extends StatelessWidget {
  const SequenceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerCubitState>(
      builder: (context, playerCubitState) {
        if (playerCubitState.audioPlayerState == PlayerState.playing ||
            playerCubitState.audioPlayerState == PlayerState.paused ||
            playerCubitState.audioPlayerState == PlayerState.completed) {
          if (playerCubitState.currentPlayingTrack != null) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: CurrentPlayingTrackInSequnce(
                    track: playerCubitState.currentPlayingTrack!,
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                SliverToBoxAdapter(child: Center(child: Text(AppLocalizations.of(context)!.nextSequenceList))),
                const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                Builder(builder: (context) {
                  List<Widget> playerInfoWidgetList = [];

                  if (playerCubitState.shuffleMode) {
                    playerInfoWidgetList.add(
                      PlayerPlaybackInfo(
                          icon: Icons.shuffle, text: AppLocalizations.of(context)!.shuffleMode),
                    );
                  }

                  if (playerCubitState.repeatMode ==
                      RepeatMode.repeatOneTrack) {
                    playerInfoWidgetList.add(
                      PlayerPlaybackInfo(
                          icon: Icons.repeat_one, text: AppLocalizations.of(context)!.repeatOneTrack
                    ));
                  }
                  if (playerCubitState.shuffleMode ||
                      playerCubitState.repeatMode ==
                          RepeatMode.repeatOneTrack) {
                    return SliverToBoxAdapter(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: playerInfoWidgetList,
                      ),
                    );
                  }

                  int? currentPlayingTrackIndexInSequenceList = context
                      .read<PlayerCubit>()
                      .getCurrentPlayingTrackIndexInSequenceList;

                  if (currentPlayingTrackIndexInSequenceList != null &&
                      currentPlayingTrackIndexInSequenceList <
                          context
                              .read<PlayerCubit>()
                              .getTrackSequenceList
                              .length) {
                    final List<TrackModel> sequenceSublist = context
                        .read<PlayerCubit>()
                        .getTrackSequenceList
                        .sublist(currentPlayingTrackIndexInSequenceList + 1);
                    return SequenceReorderableList(
                      key: UniqueKey(),
                      sequenceSublist: sequenceSublist,
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(builder: (context) {
                      if (playerCubitState.repeatMode ==
                          RepeatMode.repeatAllPlaylistAfterCompleted) {
                        return  PlayerPlaybackInfo(
                            icon: Icons.repeat,
                            text: AppLocalizations.of(context)!.repeatAllPlaylist);
                      }
                      return const SizedBox.shrink();
                    }),
                  ),
                )
              ],
            );
          }
        }

        List<TrackModel> sequenceList =
            context.read<PlayerCubit>().getTrackSequenceList;
        return CustomScrollView(
          slivers: [
            SliverList.builder(
              itemCount: sequenceList.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SequenceListTile(
                      track: sequenceList[index],
                    ));
              },
            ),
          ],
        );
      },
    );
  }
}

class PlayerPlaybackInfo extends StatelessWidget {
  const PlayerPlaybackInfo({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.secondaryContainer,
          size: 48,
        ),
        Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        )
      ],
    );
  }
}

class CurrentPlayingTrackInSequnce extends StatelessWidget {
  const CurrentPlayingTrackInSequnce({
    super.key,
    required this.track,
  });
  final TrackModel track;

  @override
  Widget build(BuildContext context) {
    return SequenceListTile(
      track: track,
    );
  }
}

class SequenceReorderableList extends StatefulWidget {
  const SequenceReorderableList({super.key, required this.sequenceSublist});

  final List<TrackModel> sequenceSublist;

  @override
  State<SequenceReorderableList> createState() =>
      _SequenceReorderableListState();
}

class _SequenceReorderableListState extends State<SequenceReorderableList> {
  List<TrackModel> sequenceSublist = [];

  @override
  void initState() {
    sequenceSublist = widget.sequenceSublist;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemBuilder: (context, index) {
        return ReorderableDragStartListener(
            index: index,
            key: Key(index.toString()),
            child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ReorderableSequenceTrackTile(
                    track: sequenceSublist[index])));
      },
      itemCount: sequenceSublist.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }

          final TrackModel track = sequenceSublist.removeAt(oldIndex);
          sequenceSublist.insert(newIndex, track);
        });
        context.read<PlayerCubit>().addSublistSequenceWidget(sequenceSublist);
      },
    );
  }
}
