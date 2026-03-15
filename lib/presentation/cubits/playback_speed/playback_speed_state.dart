part of "playback_speed_cubit.dart";

final class PlaybackSpeedState extends Equatable {
  final double playbackRate;
  final double sliderValue;
  final Source? playerAudioSource;
  const PlaybackSpeedState({
    required this.playbackRate,
    required this.sliderValue,
    this.playerAudioSource,
  });

  PlaybackSpeedState copyWith({
    double? playbackRate,
    double? sliderValue,
    Source? playerAudioSource,
  }) {
    return PlaybackSpeedState(
      playbackRate: playbackRate ?? this.playbackRate,
      sliderValue: sliderValue ?? this.sliderValue,
      playerAudioSource: playerAudioSource ?? this.playerAudioSource,
    );
  }

  @override
  List<Object?> get props => [playbackRate, sliderValue, playerAudioSource];
}
