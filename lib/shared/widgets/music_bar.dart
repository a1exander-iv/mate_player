import 'dart:async';

import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mate_player/domain/models/track_model.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/favorite/favorite_cubit.dart';
import 'package:mate_player/presentation/cubits/music_bar_slider/slider_music_bar_cubit.dart';
import 'package:mate_player/presentation/cubits/picture/pictures_cubit.dart';
import 'package:mate_player/presentation/cubits/playback_speed/playback_speed_cubit.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/presentation/cubits/short_info/track_short_info_cubit.dart';
import 'package:mate_player/presentation/cubits/volume_slider/volume_slider_cubit.dart';
import 'package:mate_player/presentation/enums/repeat_mode_enum.dart';
import 'package:mate_player/presentation/widgets/sequence_widget_list.dart';
import 'package:mate_player/shared/modals/modal_side_sheet.dart';
import 'package:mate_player/shared/resources/asset_path.dart';
import 'package:mate_player/shared/utils/parse_track_image.dart';
import 'package:mate_player/shared/utils/seconds_to_string.dart';
import 'package:mate_player/shared/widgets/image_placeholder.dart';
import 'package:mate_player/shared/widgets/play_and_pause_button.dart';

class MusicBar extends StatelessWidget {
  const MusicBar({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Size screenSize = MediaQuery.of(context).size;
    return SafeArea(
      bottom: true,
      child: SizedBox(
        width: screenSize.width,
        height: 80,
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Flexible(
                child: TrackShortInfoMusicBar(),
              ),
              Flexible(child: ControlPanelMusicBar(),
              ),
              const Flexible(child: AdditionalButtonsMusicBar()),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackShortInfoMusicBar extends StatelessWidget {
  const TrackShortInfoMusicBar({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return BlocBuilder<TrackShortInfoCubit, TrackShortInfoState>(
      builder: (context, state) {
        if (state is TrackShortInfoLoadComplete) {
          TrackModel playingTrack = state.playingTrack;

          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              BlocBuilder<PicturesCubit, PicturesState>(
                  builder: (context, state) {
                 String? imagePath = state is PicturesLoadComplete
                    ? parseTrackImagePath(state.picturesDataMap, playingTrack.filePath)
                    : null;
                return ImagePlaceholder(
                  imagePath: imagePath,
                  icon: Icons.music_note,
                  width: 56,
                  height: 56,
                  cachedHeight: 102,
                  cachedWidth: 102,
                  imageFit: BoxFit.cover,
                  iconSize: 28,
                );
              }),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.playingTrack.trackTitle ??
                              playingTrack.fileBaseName,
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          state.playingTrack.trackArtist ?? AppLocalizations.of(context)!.unknownArtist,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: BlocBuilder<FavoriteCubit, FavoriteState>(
                    builder: (context, state) {
                      if (state is FavoriteInfoLoadComplete) {
                        final bool favorite = state.tracksFavoriteMap
                            .containsKey(playingTrack.id);
                        return AnimatedLikeButton(
                          onTap: () {
                            context
                                .read<FavoriteCubit>()
                                .setFavoriteTrack(playingTrack.id, favorite);
                          
                          },
                          isFavorite: favorite,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class AnimatedLikeButton extends StatefulWidget {
  const AnimatedLikeButton(
      {super.key,
      required this.isFavorite,
      required this.onTap,
      this.width = 64,
      this.height = 64,
      this.iconSize});
  final bool isFavorite;

  final Function() onTap;
  final double width;
  final double height;
  final double? iconSize;
  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  bool _needToShowAnimation = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    if (widget.isFavorite) {
      _needToShowAnimation = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Builder(builder: (context) {
      if (widget.isFavorite) {
        if (_needToShowAnimation) {
          _animationController.forward();
        } else {
          _animationController.value = 1;
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            ColorFiltered(
                colorFilter:
                    ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
                child: Lottie.asset(
                    alignment: Alignment.centerLeft,
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.fill,
                    AssetPath.likeButtonAnimation,
                    controller: _animationController)),
            SizedBox(
              height: widget.height / 2,
              width: widget.width / 2,
              child: GestureDetector(
                onTap: () {
                  widget.onTap();
                },
              ),
            ),
          ],
        );
      } else {
        return SizedBox(
            width: widget.width,
            height: widget.height,
            child: GestureDetector(
              onTap: () {
                _needToShowAnimation = true;
                _animationController.reset();

                widget.onTap();
              },
              child: Icon(
                Icons.favorite_outline_rounded,
                size: widget.iconSize,
                color: colorScheme.primary,
              ),
            ));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}

class ControlPanelMusicBar extends StatelessWidget {
  const ControlPanelMusicBar({super.key});

  @override
  Widget build(BuildContext context) {
    final sliderMusicBarCubit = context.read<SliderMusicBarCubit>();
    final audioBarCubit = context.read<PlayerCubit>();
    return BlocBuilder<PlayerCubit, PlayerCubitState>(
      builder: (context, state) {
        TrackModel? currentPlayingTrack = state.currentPlayingTrack;
        Duration? trackDurationFromDb;

        if (currentPlayingTrack != null) {
          if (currentPlayingTrack.trackDurationInMilliseconds != null) {
            trackDurationFromDb = Duration(
                milliseconds:
                    currentPlayingTrack.trackDurationInMilliseconds!.toInt());
          }
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                WithoutSplashButton(
                    isSelected: state.shuffleMode,
                    onPressed: () {
                      audioBarCubit.onShuffleButtonPressed();
                    },
                    icon: Icons.shuffle),
                MusicBarButton(
                  height: 32,
                  width: 32,
                  isActive: state.isPreviousButtonActive,
                  onPressed: () {
                    audioBarCubit.onPreviousButtonPressed();
                  },
                  icon: Icons.navigate_before,
                ),
                PlayAndPauseButton(onPressed: () {
                  audioBarCubit.playAndPause();
                }),
                MusicBarButton(
                  height: 32,
                  width: 32,
                  isActive: state.isNextButtonActive,
                  onPressed: () {
                    audioBarCubit.onNextButtonPressed();
                  },
                  icon: Icons.navigate_next,
                ),
                Builder(builder: (context) {
                  switch (state.repeatMode) {
                    case RepeatMode.noRepeat:
                      return WithoutSplashButton(
                        isSelected: false,
                        onPressed: () {
                          audioBarCubit.onRepeatButtonPressed();
                        },
                        icon: Icons.repeat,
                      );
                    case RepeatMode.repeatOneTrack:
                      return WithoutSplashButton(
                        isSelected: true,
                        onPressed: () {
                          audioBarCubit.onRepeatButtonPressed();
                        },
                        icon: Icons.repeat,
                        selectedIcon: Icons.repeat_one,
                      );
                    case RepeatMode.repeatAllPlaylistAfterCompleted:
                      return WithoutSplashButton(
                        isSelected: true,
                        onPressed: () {
                          audioBarCubit.onRepeatButtonPressed();
                        },
                        icon: Icons.repeat,
                        selectedIcon: Icons.repeat,
                      );
                  }
                }),
              ],
            ),
            RepaintBoundary(
              child: BlocBuilder<SliderMusicBarCubit, SliderMusicBarState>(
                builder: (context, state) {
                  Duration trackDurationFromAudioPlayer = state.trackLength;
                  Duration trackDuration = Duration.zero;
              
                  if (trackDurationFromDb == null) {
                    trackDuration = trackDurationFromAudioPlayer;
                  } else {
                    trackDuration = trackDurationFromDb;
                  }
              
                  double sliderValueInMilliseconds =
                      state.currentPosition.inMilliseconds.toDouble();
              
                  if (sliderValueInMilliseconds >
                      trackDuration.inMilliseconds) {
                    sliderValueInMilliseconds =
                        trackDuration.inMilliseconds.toDouble();
                  }
               
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                          width: 60,
                          alignment: Alignment.centerRight,
                          child: Text(secondsToString(
                              state.currentPosition.inSeconds))),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 8, right: 8, top: 2),
                          child: SliderMusicBar(
                            onChangeStart: (value) {
                              sliderMusicBarCubit
                                  .pauseOnPositionChangedSubscription();
                            },
                            onChanged: (value) {
                              sliderMusicBarCubit
                                  .updateCurrentPositionValue(Duration(
                                      milliseconds: value.toInt().floor()));
                            },
                            onChangeEnd: (value) async {
                              await sliderMusicBarCubit.setNewPositionValue(
                                  Duration(milliseconds: value.toInt()));
                              sliderMusicBarCubit
                                  .resumeOnPositionChangedSubscription();
                            },
                            trackLength: trackDuration.inMilliseconds.toDouble(),
                            sliderValue: sliderValueInMilliseconds,
                          ),
                        ),
                      ),
                      Container(
                          width: 60,
                          alignment: Alignment.centerLeft,
                          child:
                              Text(secondsToString((trackDuration.inSeconds)))),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class WithoutSplashButton extends StatelessWidget {
  const WithoutSplashButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      this.size,
      this.color,
      required this.isSelected,
      this.selectedIcon});

  final void Function()? onPressed;
  final IconData icon;
  final double? size;
  final bool isSelected;
  final IconData? selectedIcon;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      selectedIcon: Icon(
        selectedIcon ?? icon,
        color: colorScheme.onPrimaryContainer,
        size: size,
      ),
      isSelected: isSelected,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color ?? colorScheme.inversePrimary,
        size: size,
      ),
      style: ButtonStyle(
          overlayColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              return Colors.transparent;
            },
          ),
          splashFactory: NoSplash.splashFactory),
    );
  }
}

class MusicBarButton extends StatelessWidget {
  const MusicBarButton(
      {super.key,
      required this.onPressed,
      this.width,
      this.height,
      required this.icon,
      required this.isActive,
      this.iconSize,
      this.radiusValue = 16});

  final void Function()? onPressed;
  final double? height;
  final double? width;
  final IconData icon;
  final double? iconSize;
  final double radiusValue;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      child: Material(
        color: colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(radiusValue),
        child: InkWell(
          enableFeedback: isActive,
          borderRadius: BorderRadius.circular(radiusValue),
          onTap: onPressed,
          child: Ink(
            width: width,
            height: height,
            child: Icon(
              icon,
              color: colorScheme.onPrimaryContainer,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class AdditionalButtonsMusicBar extends StatefulWidget {
  const AdditionalButtonsMusicBar({super.key});

  @override
  State<AdditionalButtonsMusicBar> createState() =>
      _AdditionalButtonsMusicBarState();
}

class _AdditionalButtonsMusicBarState extends State<AdditionalButtonsMusicBar> {


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.aspect_ratio, ),
          onPressed: () async {
            GoRouter.of(context).pushNamed("player");
          },
        ),
        PlaybackRatePopup(offset: Offset(100, -70),),
        IconButton(
          icon: const Icon(Icons.queue_music),
          onPressed: () async {
            await showModalSideSheet(
                headerTitle: AppLocalizations.of(context)!.audioQueue,
                body: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: SequenceListWidget(),
                ),
                context: context);
          },
        ),
         BlocBuilder<VolumeSliderCubit, VolumeSliderState>(
           builder: (BuildContext context, VolumeSliderState state) {
             return IconButton(onPressed: () {
                context.read<VolumeSliderCubit>().onMuteVolumeButtonPressed();
              }, icon: Builder(builder: (context) {
                switch (state.sliderValue) {
                  case 0:
                    return const Icon(Icons.volume_off);
                  case > 0 && < 20:
                    return const Icon(Icons.volume_mute);
                  case >= 20 && < 60:
                    return const Icon(Icons.volume_down);
                  default:
                    return const Icon(Icons.volume_up);
                }
              }));
  }),
        Flexible(child: const VolumeSliderWidget()),
      ],
    );
  }
}

class VolumeSliderWidget extends StatelessWidget {
  const VolumeSliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final volumeSliderCubit = context.read<VolumeSliderCubit>();
    return BlocBuilder<VolumeSliderCubit, VolumeSliderState>(
      builder: (context, state) {
        final width = MediaQuery.of(context).size.width;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width * 0.05,),
          child: SliderMusicBar(
            onChanged: (value) {
              volumeSliderCubit.changeVolumeSliderValue(value);
            },
            divisions: 100,
            trackLength: 100,
            sliderValue: state.sliderValue,
          ),
        );
      },
    );
  }
}

class SliderMusicBar extends StatelessWidget {
  const SliderMusicBar(
      {super.key,
      this.onChangeStart,
      this.onChangeEnd,
      this.divisions,
      this.min,
      required this.onChanged,
      required this.trackLength,
      required this.sliderValue});

  final void Function(double)? onChangeStart;
  final void Function(double)? onChangeEnd;
  final void Function(double) onChanged;
  final double sliderValue;
  final double trackLength;
  final int? divisions;
  final double? min;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SliderTheme(
        data: SliderThemeData(
            showValueIndicator: ShowValueIndicator.always,
            inactiveTickMarkColor: colorScheme.inversePrimary,
            secondaryActiveTrackColor: colorScheme.inversePrimary,
            activeTickMarkColor: colorScheme.primary,
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 8,
            ),
            overlayColor: Colors.transparent,
            trackHeight: 4,
            trackShape: const RectangularSliderTrackShape(),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2)),
        child: Slider(
          min: min ?? 0,
          label: divisions != null ?  sliderValue.toInt().toString() : null,
          divisions: divisions,
          max: trackLength.toDouble(),
          value: sliderValue,
          onChangeStart: onChangeStart,
          onChangeEnd: onChangeEnd,
          onChanged: (value) {
            onChanged(value);
          },
        ));
  }
}

class PlaybackRatePopup extends StatefulWidget {
  const PlaybackRatePopup({super.key, required this.offset});
  final Offset offset;

  @override
  State<PlaybackRatePopup> createState() => _PlaybackRatePopupState();
}

class _PlaybackRatePopupState extends State<PlaybackRatePopup> {

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton(
      tooltip: "",
      offset: widget.offset,
      icon: Icon(Icons.speed, color: colorScheme.onSurfaceVariant),
      position: .over,
      itemBuilder: (context) {
          return [
          PopupMenuItem(
            enabled: false,
            child: PlaybackRatePopupItem(),
            ),
        ];});
  }
}

class PlaybackRatePopupItem extends StatefulWidget {
  const PlaybackRatePopupItem({super.key});

  @override
  State<PlaybackRatePopupItem> createState() => _PlaybackRatePopupItemState();
}

class _PlaybackRatePopupItemState extends State<PlaybackRatePopupItem> {
  Timer? closeTimer;
  static const closeDuration = Duration(seconds: 3);

  void _autoClose(BuildContext context) {
    closeTimer?.cancel();
    closeTimer = Timer(closeDuration, () {
      if (mounted) {
         Navigator.pop(context);
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _autoClose(context);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<PlayerCubit, PlayerCubitState>(
            builder: (context, playerState) {
              return BlocBuilder<PlaybackSpeedCubit, PlaybackSpeedState>(
                builder: (context, state) {
                  //necessary to reset the slider value because audioplayer doesn't do this after switching audio tracks (match track and playbackrate)
                  double sliderValue = state.sliderValue;
                  if (playerState.source != state.playerAudioSource) {
                    sliderValue = 1;
                    context.read<PlaybackSpeedCubit>().changePlaybackSliderValue(1, playerState.source);
                  }
                  return Row(          
                  mainAxisAlignment: .center,
                  children: [
                  Text("${sliderValue.toStringAsFixed(2)}x", style: TextStyle(color: colorScheme.onSurface),),
                  Gap(4),
                  SliderMusicBar(
                  onChangeEnd: (value) {
                    context.read<PlaybackSpeedCubit>().setPlaybackRate(value, playerState.source);
                  },
                  onChanged: (value) {
                    context.read<PlaybackSpeedCubit>().changePlaybackSliderValue(value, playerState.source);
                    _autoClose(context);
                  },
                  trackLength: 2, 
                  min: 0.5,
                  sliderValue: sliderValue)
                ],);}
              );}
    );
  }

  @override
  void dispose() {
    super.dispose();
    closeTimer?.cancel();
  }
}