import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mate_player/data/repositories/database_repository.dart';
import 'package:mate_player/domain/models/picture_model.dart';
import 'package:mate_player/domain/models/playlist_model.dart';
import 'package:mate_player/domain/models/track_model.dart';

part 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit(this._databaseRepository) : super(PlaylistInitial());

  final DatabaseRepository _databaseRepository;

  int? playlistId;
  String? playlistName;
  String? playlistImagePath;
  List<int>? playlistTrackIdList;

  List<PlaylistModel>? playlistCatalogList;

  void createPlaylist() async {
    
    _databaseRepository.createPlaylist(
      name: playlistName ?? "",
      imagePath: playlistImagePath,
      trackIds: playlistTrackIdList,
    );
    clear();
  }

  void loadPlaylistCatalog() {
    _databaseRepository.watchAllPlaylists().listen((playlistCatalog) {
      playlistCatalogList = playlistCatalog;
      emit(PlaylistCatalogLoadComplete(playlistCatalog: playlistCatalog));
    });
  }

  void clear() {
    playlistName = null;
    playlistImagePath = null;
    playlistTrackIdList = null;
    playlistId = null;
  }

  List<TrackModel> getTrackList() => _databaseRepository.trackList;
  Map<String, List<PictureModel>> getPictureMap() =>
      _databaseRepository.pictureDataMap;
  Future<void> deletePlaylist(int playlistId) async {
    await _databaseRepository.deletePlaylist(playlistId);
  }

  Future<void> saveNewPlaylistTrackIdsList({required int playlistId}) async {
    await _databaseRepository.setNewTrackIdsListPlaylist(
        plyalistTrackIdsList: playlistTrackIdList!, playlistId: playlistId);
  }

  Future<void> removeTrackFromPlaylist(
      {required int playlistId, required int trackId}) async {
    await _databaseRepository.removeTrackFromPlaylist(
        playlistId: playlistId, trackId: trackId);
  }

  Future<void> editPlaylist() async {
    await _databaseRepository.editPlaylist(
        playlistId: playlistId!,
        name: playlistName,
        imagePath: playlistImagePath,
        trackIds: playlistTrackIdList);
  }

  Future<List<TrackModel>> getPlaylistTrackList(int playlistId) async {
    return _databaseRepository.getPlaylistTrackList(playlistId);
  }

  Future<List<int>> getPlaylistTrackIdsList(int playlistId) async {
    return _databaseRepository.getPlaylistTracksIdsList(playlistId);
  }

  Future<int> getTotalPlaylists() async {
    return await _databaseRepository.getTotalPlaylists();
  }

  Future<void> addTrackToPlaylist({required int playlistId, required int trackId}) async {
    await _databaseRepository.addTrackToPlaylist(trackId: trackId, playlistId: playlistId);
  }
}
