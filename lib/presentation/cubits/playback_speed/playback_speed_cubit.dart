import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mate_player/data/repositories/audio_player_repository.dart';

part 'playback_speed_state.dart';

class PlaybackSpeedCubit extends Cubit<PlaybackSpeedState> {
  PlaybackSpeedCubit({required this.audioPlayerRepository})
      : super(PlaybackSpeedState(playbackRate: 1, sliderValue: 1)) {
    player = audioPlayerRepository.audioPlayer;
  }

  late final AudioPlayer player;
  final AudioPlayerRepository audioPlayerRepository;

  void setPlaybackRate(double value, Source? audioSource) {
    player.setPlaybackRate(value);
    emit(state.copyWith(playbackRate: value, playerAudioSource: audioSource));
  }

  void changePlaybackSliderValue(double value, Source? audioSource) {
    emit(state.copyWith(sliderValue: value, playerAudioSource: audioSource));
  }

}


