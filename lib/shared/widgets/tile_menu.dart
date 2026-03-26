import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mate_player/domain/models/track_model.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/presentation/cubits/playlist/playlist_cubit.dart';
import 'package:mate_player/shared/modals/track_information_side_sheet.dart';


class TrackTileMenu extends StatelessWidget {
  const TrackTileMenu({super.key,required this.track, this.menuIcon = Icons.more_vert});

  final TrackModel track;
  final IconData menuIcon;
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
            consumeOutsideTap: true,
            builder: (BuildContext context, MenuController controller,
                Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: Icon(menuIcon),
              );
            },
            menuChildren: [
              MenuItemButton(
                  requestFocusOnHover: false,
                  leadingIcon: const Icon(
                    Icons.info_outline,
                    size: 24,
                  ),
                  child: Text(AppLocalizations.of(context)!.trackInfoItemButton),
                  onPressed: () async {
                    await showTrackInformationModalSideSheet(
                        context: context, track: track);
                  }),
              SubmenuPlaylistSelection(track: track,),
            ]);
  }
}

class SubmenuPlaylistSelection extends StatefulWidget {
  const SubmenuPlaylistSelection({super.key, required this.track});

  final TrackModel track;

  @override
  State<SubmenuPlaylistSelection> createState() => _SubmenuPlaylistSelectionState();
}

class _SubmenuPlaylistSelectionState extends State<SubmenuPlaylistSelection> {

  late PlaylistCubit _playlistCubit;
  @override
  void initState() {
    _playlistCubit = context.read<PlaylistCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        final List<MenuItemButton> submenuList = [];
        if (state is PlaylistCatalogLoadComplete) {
          for (var playlist in state.playlistCatalog) {
            submenuList.add(MenuItemButton(
              requestFocusOnHover: false,
              onPressed: () async {
              await _playlistCubit.addTrackToPlaylist(playlistId: playlist.id, trackId: widget.track.id);
            }, child: Text(playlist.name ?? "${AppLocalizations.of(context)?.playlistDefaultName} ${playlist.id}",), ));
          }
        }
        return SubmenuButton(
          onClose: () {
            FocusScope.of(context).unfocus();
          },
          menuChildren: submenuList, leadingIcon: Icon(Icons.library_add_outlined),
               child: Text(AppLocalizations.of(context)?.addToPlaylist ?? ""),);
      }

    );
  }
}

class PlaylistTrackTileMenu extends StatelessWidget {
  const PlaylistTrackTileMenu({
    super.key,
    required this.track,
    required this.playlistId,
    this.menuIcon = Icons.more_vert,
  });
  final TrackModel track;
  final int playlistId;
  final IconData menuIcon;
  @override
  Widget build(BuildContext context) {
    PlaylistCubit playlistCubit = context.read<PlaylistCubit>();
    PlayerCubit playerCubit = context.read<PlayerCubit>();
    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: Icon(menuIcon),
            );
          },
      menuChildren: [
        MenuItemButton(
          requestFocusOnHover: false,
          leadingIcon: const Icon(Icons.info_outline),
          child: Text(AppLocalizations.of(context)!.trackInfoItemButton),
          onPressed: () async {
            await showTrackInformationModalSideSheet(
              context: context,
              track: track,
            );
          },
        ),
        MenuItemButton(
          requestFocusOnHover: false,
          leadingIcon: const Icon(Icons.delete_sweep),
          child: Text(
            AppLocalizations.of(context)!.deleteFromPlaylistMenuItemButton,
          ),
          onPressed: () async {
            await playlistCubit.removeTrackFromPlaylist(
              playlistId: playlistId,
              trackId: track.id,
            );

            if (playerCubit.getCurrentPlayingPlaylist == playlistId) {
              List<TrackModel> sequenceListWithoutRemovedTrack =
                  playerCubit.getTrackSequenceList;
              sequenceListWithoutRemovedTrack.removeWhere(
                (track) => track.id == this.track.id,
              );
              playerCubit.reorderSequenceListByPlaylistIdsList(
                playlistIdsList: sequenceListWithoutRemovedTrack
                    .map((track) => track.id)
                    .toList(),
              );
            }
          },
        ),
      ],
    );
  }
}
