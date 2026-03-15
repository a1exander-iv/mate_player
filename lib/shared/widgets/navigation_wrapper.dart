import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/permission/permission_cubit.dart';
import 'package:mate_player/presentation/cubits/picture/pictures_cubit.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/presentation/cubits/settings/settings_cubit.dart';
import 'package:mate_player/presentation/enums/repeat_mode_enum.dart';
import 'package:mate_player/shared/dialogs/permission_alert_message.dart';
import 'package:mate_player/shared/snackbars/playback_error_snackbar.dart';
import 'package:mate_player/shared/snackbars/player_repeat_mode_snackbar.dart';
import 'package:mate_player/shared/widgets/load_info_bar.dart';
import 'package:mate_player/shared/widgets/music_bar.dart';
import 'package:mate_player/shared/widgets/navigation.dart';
import 'package:permission_handler/permission_handler.dart';

class NavigationWrapper extends StatelessWidget {
  const NavigationWrapper({super.key, required this.bodyChild});

  final Widget bodyChild;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return MultiBlocListener(
      listeners: [
        BlocListener<PermissionCubit, PermissionState>(
          listenWhen: (previous, current) => true,
          listener: (context, state) async {
            if (state is PermissionsStatusState) {
              if (state.permissionStatusMap[Permission.audio] !=
                      PermissionStatus.granted &&
                  state.permissionStatusMap[Permission.storage] !=
                      PermissionStatus.granted) {
                await showDialog(
                    context: context,
                    builder: (context) {
                      return FilesystemPermissionAlertDialog();
                    });
              }
            }
          },
        ),
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen:(previous, current) {
            return previous.loadTrackImages != current.loadTrackImages;
          },
          listener:(context, state) {
          if (state.loadTrackImages) {
            context.read<PicturesCubit>().resumePictureLoading();
          } else {
            context.read<PicturesCubit>().clearPicturesAndCancelSubscription();
          }
        },)
      ],
      child: LayoutBuilder(builder: (context, constraints) {
        Size screenSize = MediaQuery.of(context).size;
        if (screenSize.width >= 600) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: MultiBlocListener(
              listeners: [
                BlocListener<PlayerCubit, PlayerCubitState>(
                    listener: (context, state) {
                  if (state.playbackError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                     playbackErrorSnackBar(context: context, contentText: appLocalizations.playbackErrorSnackBarText),
                    );
                  }
                }),
                BlocListener<PlayerCubit, PlayerCubitState>(
                  listenWhen: (previous, current) {
                    return previous.shuffleMode != current.shuffleMode;
                  },
                  listener: (context, state) {
                    if (state.shuffleMode == true) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                          playerRepeatModeSnackbar(
                              context: context,
                              contentText: appLocalizations.shuffleMode));
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                          playerRepeatModeSnackbar(
                              context: context,
                              contentText: appLocalizations.shuffleModeDisabledSnackBarText));
                    }
                  },
                ),
                BlocListener<PlayerCubit, PlayerCubitState>(
                  listenWhen: (previous, current) {
                    return previous.repeatMode != current.repeatMode;
                  },
                  listener: (context, state) {
                    switch (state.repeatMode) {
                      case RepeatMode.noRepeat:
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            playerRepeatModeSnackbar(
                                context: context,
                                contentText: appLocalizations.noRepeat));
                      case RepeatMode.repeatOneTrack:
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            playerRepeatModeSnackbar(
                                context: context,
                                contentText: appLocalizations.repeatOneTrack));
                      case RepeatMode.repeatAllPlaylistAfterCompleted:
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            playerRepeatModeSnackbar(
                                context: context,
                                contentText: appLocalizations.repeatAllPlaylist));
                    }
                  },
                ),
              ],
              child: BlocBuilder<PlayerCubit, PlayerCubitState>(
                builder: (context, state) {
                  switch (state.audioPlayerState) {
                    case PlayerState.playing ||
                          PlayerState.paused ||
                          PlayerState.completed:
                      return MusicBar();
                    default:
                      return SizedBox.shrink();
                  }
                },
              ),
            ),
            body: SafeArea(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: screenSize.height, child: const Navigation()),
                      Flexible(child: SizedBox(width: screenSize.width , child: bodyChild)),
                    ],
                  ),
                  const LoadInfoBarContent(
                    bottomPadding: 16,
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  bodyChild,
                  const LoadInfoBarContent(
                    bottomPadding: 64,
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const NavigationMobile(),
          );
        }
      }),
    );
  }
}