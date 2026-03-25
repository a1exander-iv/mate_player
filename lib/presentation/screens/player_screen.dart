
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart' show PlayerState;
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mate_player/domain/models/track_model.dart';
import 'package:mate_player/l10n/generated/app_localizations.dart';
import 'package:mate_player/presentation/cubits/favorite/favorite_cubit.dart';
import 'package:mate_player/presentation/cubits/music_bar_slider/slider_music_bar_cubit.dart';
import 'package:mate_player/presentation/cubits/picture/pictures_cubit.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';
import 'package:mate_player/presentation/cubits/short_info/track_short_info_cubit.dart';
import 'package:mate_player/presentation/cubits/volume_slider/volume_slider_cubit.dart';
import 'package:mate_player/presentation/enums/repeat_mode_enum.dart';
import 'package:mate_player/presentation/widgets/sequence_widget_list.dart';
import 'package:mate_player/shared/utils/parse_track_image.dart';
import 'package:mate_player/shared/utils/seconds_to_string.dart';
import 'package:mate_player/shared/widgets/image_placeholder.dart';
import 'package:mate_player/shared/widgets/music_bar.dart';
import 'package:mate_player/shared/widgets/play_and_pause_button.dart'
    show PlayAndPauseButton;
import 'package:mate_player/shared/widgets/top_app_bar.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(builder: (context, constraints) {
          Size screenSize = MediaQuery.of(context).size;
        
          return BlocBuilder<PlayerCubit, PlayerCubitState>(
            builder: (context, state) {
              if (state.audioPlayerState == PlayerState.disposed ||
                  state.audioPlayerState == PlayerState.stopped) {
                return SafeArea(
            
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                          child: TopAppBar(
                            title: Text(AppLocalizations.of(context)!.audioQueue,),
                          )),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: SequenceListWidget(),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return BlocBuilder<TrackShortInfoCubit, TrackShortInfoState>(
                builder: (context, state) {
                  if (state is TrackShortInfoLoadComplete) {
                    TrackModel track = state.playingTrack;
        
                    return BlocBuilder<PicturesCubit, PicturesState>(
                      builder: (context, state) {
                         String? imagePath = state is PicturesLoadComplete
                            ? parseTrackImagePath(
                                state.picturesDataMap,
                                track.filePath,
                              )
                            : null;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TopAppBar(),
                            Builder(builder: (context) {
                              if (screenSize.width >= 600) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Builder(builder: (context) {
                                                if (screenSize.height < 400) {
                                                  return const SizedBox.shrink();
                                                }
                                                return Flexible(
                                                  child: SizedBox(
                                                    child: Align(
                                                      alignment: Alignment.center,
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          ImageFiltered(
                                                            imageFilter:
                                                                ImageFilter.blur(
                                                                    sigmaX: 70,
                                                                    sigmaY: 70),
                                                            child:
                                                                ImagePlaceholder(
                                                              imagePath:
                                                                  imagePath,
                                                              icon: Icons
                                                                  .music_note,
                                                              iconSize: 64,
                                                              imageFit:
                                                                  BoxFit.cover,
                                                            ),
                                                          ),
                                                          ImagePlaceholder(
                                                            imagePath:
                                                                imagePath,
                                                            icon:
                                                                Icons.music_note,
                                                            iconSize: 64,
                                                            imageFit:
                                                                BoxFit.cover,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                              Builder(builder: (context) {
                                                double topPadding = 16;
                                                double bottomPadding = 32;
                                                if (screenSize.height < 400) {
                                                  topPadding = 0;
                                                  bottomPadding = 0;
                                                }
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      top: topPadding,
                                                      bottom: bottomPadding),
                                                  child:
                                                      TrackInfoWithControlPanel(
                                                          track: track),
                                                );
                                              }),
                                              BottomButtonsPlaylistScreen(),
                                            ],
                                          ),
                                        ),
                                        const Flexible(
                                            child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 16),
                                                child: SequenceListWidget())),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Builder(builder: (context) {
                                          if (screenSize.height < 400) {
                                            return const SizedBox.shrink();
                                          }
                                          return Flexible(
                                            child: SizedBox(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    ImageFiltered(
                                                      imageFilter:
                                                          ImageFilter.blur(
                                                              sigmaX: 70,
                                                              sigmaY: 70),
                                                      child: ImagePlaceholder(
                                                        imagePath:
                                                            imagePath,
                                                        icon: Icons.music_note,
                                                        iconSize: 64,
                                                        imageFit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    ImagePlaceholder(
                                                      imagePath: imagePath,
                                                      icon: Icons.music_note,
                                                      iconSize: 64,
                                                      imageFit: BoxFit.cover,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                        Builder(builder: (context) {
                                          double padding = 16;
                                          if (screenSize.height < 400) {
                                            padding = 0;
                                          }
        
                                          return Padding(
                                              padding: EdgeInsets.only(
                                                  top: padding, bottom: padding),
                                              child: TrackInfoWithControlPanel(
                                                track: track,
                                              ));
                                        }),
                                        BottomButtonsPlaylistScreen(),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }),
                          ],
                        );
                      },
                    );
                  }
                  return SizedBox();
                },
              );
            },
          );
        }),
      ),
    );
  }
}

class BottomButtonsPlaylistScreen extends StatelessWidget {
  const BottomButtonsPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PlaybackRatePopup(offset: Offset(0, 0)),
        Builder(builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (screenWidth < 600) {
            return IconButton(
              icon: const Icon(Icons.queue_music),
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog.fullscreen(
                         
                          child: Column(
                        children: [
                          TopAppBar(
                            title: Text(AppLocalizations.of(context)!.audioQueue),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: SequenceListWidget(),
                            ),
                          )
                        ],
                      ));
                    });
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        VolumeWidgetPlayerScreen(),
      ],
    );
  }
}

class VolumeWidgetPlayerScreen extends StatefulWidget {
  const VolumeWidgetPlayerScreen({super.key});

  @override
  State<VolumeWidgetPlayerScreen> createState() =>
      _VolumeWidgetPlayerScreenState();
}

class _VolumeWidgetPlayerScreenState extends State<VolumeWidgetPlayerScreen> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    final volumeSliderCubit = context.read<VolumeSliderCubit>();
    return BlocBuilder<VolumeSliderCubit, VolumeSliderState>(
      builder: (context, state) {
        return Row(children: [
          IconButton(onPressed: () {
            setState(() {
              visible = !visible;
            });
          }, icon: Builder(builder: (context) {
            switch (state.sliderValue) {
              case 0:
                return const Icon(Icons.volume_off);
              case > 0 && < 0.20:
                return const Icon(Icons.volume_mute);
              case >= 0.20 && < 0.60:
                return const Icon(Icons.volume_down);
              default:
                return const Icon(Icons.volume_up);
            }
          })),
          Visibility(
            visible: visible,
            child: SizedBox(
              width: 70,
              child: SliderMusicBar(
                onChanged: (value) {
                  volumeSliderCubit.changeVolumeSliderValue(value);
                },
                trackLength: 100,
                divisions: 100,
                sliderValue: state.sliderValue,
              ),
            ),
          )
        ]);
      },
    );
  }
}

class TrackInfo extends StatelessWidget {
  const TrackInfo({super.key, required this.track});

  final TrackModel track;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                track.trackTitle ?? track.fileBaseName,
                style: textTheme.titleMedium?.copyWith(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                track.trackArtist ?? AppLocalizations.of(context)!.unknownArtist,
                style: textTheme.titleSmall?.copyWith(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        BlocBuilder<FavoriteCubit, FavoriteState>(
          builder: (context, state) {
            final bool favorite = state is FavoriteInfoLoadComplete &&
                    state.tracksFavoriteMap.containsKey(track.id)
                ? true
                : false;
            return AnimatedLikeButton(
              isFavorite: favorite,
              onTap: () {
                context
                    .read<FavoriteCubit>()
                    .setFavoriteTrack(track.id, favorite);
              },
            );
          },
        ),
      ],
    );
  }
}

class ControlPanelPlayerScreen extends StatelessWidget {
  const ControlPanelPlayerScreen({super.key});

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
            BlocBuilder<SliderMusicBarCubit, SliderMusicBarState>(
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

                if (sliderValueInMilliseconds > trackDuration.inMilliseconds) {
                  sliderValueInMilliseconds =
                      trackDuration.inMilliseconds.toDouble();
                }

                return Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: SizedBox(
                              child: SliderMusicBar(
                            onChangeStart: (value) {
                              sliderMusicBarCubit
                                  .pauseOnPositionChangedSubscription();
                            },
                            onChanged: (value) {
                              sliderMusicBarCubit
                                  .updateCurrentPositionValue(Duration(
                                      //seconds: value.toInt(),
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
                          )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: 60,
                            alignment: Alignment.centerLeft,
                            child: Text(secondsToString(
                                state.currentPosition.inSeconds), style: TextStyle(
                                  fontSize: 16
                                ),)),
                        Container(
                            width: 60,
                            alignment: Alignment.centerRight,
                            child: Text(
                                secondsToString((trackDuration.inSeconds)), style: TextStyle(
                                  fontSize: 16
                                ),)),
                      ],
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WithoutSplashButton(
                      isSelected: state.shuffleMode,
                      onPressed: () {
                        audioBarCubit.onShuffleButtonPressed();
                      },
                      icon: Icons.shuffle),
                  MusicBarButton(
                      radiusValue: 24,
                      height: 48,
                      width: 48,
                      isActive: state.isPreviousButtonActive,
                      onPressed: () {
                        audioBarCubit.onPreviousButtonPressed();
                      },
                      icon: Icons.navigate_before,
                      iconSize: 36),
                  Stack(
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: 5,
                          sigmaY: 5,
                        ),
                        child:
                            PlayAndPauseButton(iconSize: 52, onPressed: () {}),
                      ),
                      PlayAndPauseButton(
                          iconSize: 52,
                          onPressed: () {
                            audioBarCubit.playAndPause();
                          }),
                    ],
                  ),
                  MusicBarButton(
                      radiusValue: 24,
                      height: 48,
                      width: 48,
                      isActive: state.isNextButtonActive,
                      onPressed: () {
                        audioBarCubit.onNextButtonPressed();
                      },
                      icon: Icons.navigate_next,
                      iconSize: 36),
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
            ),
          ],
        );
      },
    );
  }
}

class TrackInfoWithControlPanel extends StatelessWidget {
  const TrackInfoWithControlPanel({super.key, required this.track});

  final TrackModel track;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TrackInfo(track: track),
        const Gap(8),
        const ControlPanelPlayerScreen(),
      ],
    );
  }
}
