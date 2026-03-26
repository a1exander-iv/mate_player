import 'dart:async';
import 'dart:io' show File;

import 'package:async/async.dart';
import 'package:mate_player/data/mappers/favorite_playlist_mapper.dart';
import 'package:mate_player/data/mappers/favorite_track_mapper.dart';
import 'package:mate_player/data/mappers/picture_mapper.dart';
import 'package:mate_player/data/mappers/playlist_mapper.dart';
import 'package:mate_player/data/mappers/playlist_track_mapper.dart';
import 'package:mate_player/data/mappers/track_entry_mapper.dart';
import 'package:mate_player/data/mappers/track_mapper.dart';
import 'package:mate_player/data/sources/db.dart';
import 'package:mate_player/data/sources/prefs.dart';
import 'package:mate_player/domain/models/favorite_playlist_model.dart';
import 'package:mate_player/domain/models/favorite_track_model.dart';
import 'package:mate_player/domain/models/picture_model.dart';
import 'package:mate_player/domain/models/playlist_model.dart';
import 'package:mate_player/domain/models/playlist_track_model.dart';
import 'package:mate_player/domain/models/track_entry_model.dart';
import 'package:mate_player/domain/models/track_model.dart';
import 'package:mate_player/presentation/enums/select_sorting_enum.dart';

class DatabaseRepository {
  DatabaseRepository(this._appDatabase, this._prefs) {
    switch (SelectSortingEnum.fromPrefsString(
        _prefs.getString(SharedKeys.mainListSorting))) {
      case SelectSortingEnum.byDurationAscending:
        listenAllTracksByDuration(ascending: true);

      case SelectSortingEnum.byDurationDescending:
        listenAllTracksByDuration(ascending: false);

      case SelectSortingEnum.byDateAddedAscending:
        listenAllTracksByDateAdded(ascending: true);

      case SelectSortingEnum.byDateAddedDescending:
        listenAllTracksByDateAdded(ascending: false);

      case SelectSortingEnum.byTitleAscending:
        listenAllTracksByTitle(ascending: true);
      case SelectSortingEnum.byTitleDescending:
        listenAllTracksByTitle(ascending: false);

      case SelectSortingEnum.byYearAscending:
        listenAllTracksByYear(ascending: true);

      case SelectSortingEnum.byYearDescending:
        listenAllTracksByYear(ascending: false);

      case SelectSortingEnum.byFileNameAscending:
        listenAllTracksByFileName(ascending: true);

      case SelectSortingEnum.byFileNameDescending:
        listenAllTracksByFileName(ascending: false);

      case SelectSortingEnum.withoutSorting:
        listenAllTracksWithoutSorting();
    }

    trackListStreamController.stream.listen((data) {
      _trackList = data;

      for (var track in data) {
        _filePathTrackMap[track.filePath] = track;
      }
    });
  }

  final AppDatabase _appDatabase;
  final Prefs _prefs;
  StreamSubscription? _allTracksStreamSubscription;
  List<TrackModel> _trackList = [];
  List<TrackModel> get trackList => _trackList;
  Map<String, List<PictureModel>> pictureDataMap = {};
  final Map<String, TrackModel> _filePathTrackMap = {};
  Map<String, TrackModel> get filePathTrackMap => _filePathTrackMap;

  StreamController<List<TrackModel>> trackListStreamController =
      StreamController.broadcast();

  void addAudioTracksToDb({required List<TrackEntryModel> trackEntriesList}) {
    List<TracksCompanion> entries =
        trackEntriesList.map((element) => element.toCompanion()).toList();
    _appDatabase.insertTracks(entries);
  }

  void updateAudioMetadataByFilePath(
          {required String trackFilePath,
          required TracksCompanion trackEntry}) =>
      _appDatabase.updateAudioMetadataByFilePath(
          trackFilePath: trackFilePath, trackEntry: trackEntry);

  Future<List<TrackModel>> get readAllTracksFromDb async {
    List<Track> list = await _appDatabase.allTracks;
    return list.map((element) => element.toDomain()).toList();
  }


  Future addListenedTrackToHistory(
      {required TrackModel track, required int listenedTimeInSeconds}) async {
    return _appDatabase.addListenedTrack(
        trackId: track.id, listenedTimeInSeconds: listenedTimeInSeconds);
  }

  Future<void> createPlaylist(
      {required String name, List<int>? trackIds, String? imagePath}) {
    return _appDatabase.createPlaylist(
        name: name, trackIds: trackIds, imagePath: imagePath);
  }

  Stream<List<PlaylistModel>> watchAllPlaylists() async* {
    await for (var playlists in _appDatabase.watchAllPlaylists()) {
      yield playlists.map((element) => element.toDomain()).toList();
    }
  }

  Future<List<TrackModel>> getTrackListById(List<int> trackIdList) async {
    final List<Track> list = await _appDatabase.getTrackListById(trackIdList);
    final List<TrackModel> trackModelList =
        list.map((element) => element.toDomain()).toList();
    return trackModelList;
  }

  Future<Set<String>> getTracksFilePaths() async {
    return _appDatabase.getTracksFilePaths();
  }

  Future deleteTrackByFilePaths({required List<String> filePathList}) async {
    return _appDatabase.deleteTracksByFilePathList(filePathList: filePathList);
  }

  Future<List<TrackModel>> getTracksByDirectory({required String directoryPath}) async {
    List<Track> list = await _appDatabase.getTrackListByDirectory(directoryPath: directoryPath);
    final List<TrackModel> trackModelList = list.map((element) => element.toDomain()).toList();
    return trackModelList;
  }

  Future<List<TrackModel>> getPlaylistTrackList(int playlistId) async {
    List<Track> list = await _appDatabase.getPlaylistTracks(playlistId);
    final List<TrackModel> trackModelList =
        list.map((element) => element.toDomain()).toList();
    return trackModelList;
  }

  Future<List<int>> getPlaylistTracksIdsList(int playlistId) =>
      _appDatabase.getPlaylistTracksIdsList(playlistId);

  Future<PlaylistModel> getPlaylistInfo(int playlistId) async {
    PlaylistData playlistData = await _appDatabase.getPlaylistInfo(playlistId);
    return playlistData.toDomain();
  }

  Future<int> getTotalPlaylists() => _appDatabase.getTotalPlaylists();
  Future deletePlaylist(int playlistId) async {
    final playlistInfo = await _appDatabase.getPlaylistInfo(playlistId);
    if (playlistInfo.imagePath != null) {
      File imageFile = File(playlistInfo.imagePath!);
      final bool imageFileExists = await imageFile.exists();

      if (imageFileExists) {
        await File(playlistInfo.imagePath!).delete();
      }
    }
    await _appDatabase.deletePlaylist(playlistId);
  }

  Future setNewTrackIdsListPlaylist(
          {required List<int> plyalistTrackIdsList, required int playlistId}) =>
      _appDatabase.setNewTrackIdsListPlaylist(playlistId, plyalistTrackIdsList);
  Future removeTrackFromPlaylist(
          {required int playlistId, required int trackId}) =>
      _appDatabase.removeTrackFromPlaylist(playlistId, trackId);
  Future addTrackToPlaylist({required int trackId, required int playlistId}) => _appDatabase.addTrackToPlaylist(playlistId: playlistId, trackId: trackId);
  Future editPlaylist(
          {required int playlistId,
          required String? name,
          List<int>? trackIds,
          int? totalDurationInMilliseconds,
          String? imagePath}) =>
      _appDatabase.editPlaylist(
          playlistId: playlistId,
          name: name,
          imagePath: imagePath,
          trackIds: trackIds);
  Future<void> setTrackPlaybackError(int trackId, bool playbackError) =>
      _appDatabase.setTrackPlaybackError(trackId, playbackError);

  Stream<List<PlaylistTrackModel>> watchAllPlaylistTrackData(
      int playlistId) async* {
    await for (var playlistTrackDataList
        in _appDatabase.watchAllPlaylistTrackData(playlistId)) {
      final List<PlaylistTrackModel> playlistTrackModelList =
          playlistTrackDataList.map((element) => element.toDomain()).toList();
      yield playlistTrackModelList;
    }
  }

  Stream<List<TrackModel>> watchAllTracksByDuration() async* {
    await for (var data in _appDatabase.watchAllTracks) {
      yield data.map((element) => element.toDomain()).toList();
    }
  }

  void listenAllTracksByDuration({required bool ascending}) {
    _allTracksStreamSubscription?.cancel();

    _allTracksStreamSubscription = _appDatabase
        .watchAllTracksByDuration(ascending: ascending)
        .listen((value) {
      List<TrackModel> list =
          value.map((element) => element.toDomain()).toList();
      trackListStreamController.add(list);
    });
  }

  void listenAllTracksWithoutSorting() {
    _allTracksStreamSubscription?.cancel();

    _allTracksStreamSubscription = _appDatabase.watchAllTracks.listen((value) {
      List<TrackModel> list =
          value.map((element) => element.toDomain()).toList();
      trackListStreamController.add(list);
    });
  }

  void listenAllTracksByDateAdded({required bool ascending}) {
    _allTracksStreamSubscription?.cancel();

    _allTracksStreamSubscription = _appDatabase
        .watchAllTracksByDateAdded(ascending: ascending)
        .listen((value) {
      List<TrackModel> list =
          value.map((element) => element.toDomain()).toList();
      trackListStreamController.add(list);
    });
  }

  void listenAllTracksByTitle({required bool ascending}) {
    _allTracksStreamSubscription?.cancel();

    _allTracksStreamSubscription =
        _appDatabase.watchAllTrackByTitle(ascending: ascending).listen((value) {
      List<TrackModel> list =
          value.map((element) => element.toDomain()).toList();
      trackListStreamController.add(list);
    });
  }

  void listenAllTracksByYear({required bool ascending}) {
    _allTracksStreamSubscription?.cancel();

    _allTracksStreamSubscription =
        _appDatabase.watchAllTrackByYear(ascending: ascending).listen((value) {
      List<TrackModel> list =
          value.map((element) => element.toDomain()).toList();
      trackListStreamController.add(list);
    });
  }

  void listenAllTracksByFileName({required bool ascending}) {
    _allTracksStreamSubscription?.cancel();

    _allTracksStreamSubscription = _appDatabase
        .watchAllTrackByFileName(ascending: ascending)
        .listen((value) {
      List<TrackModel> list =
          value.map((element) => element.toDomain()).toList();
      trackListStreamController.add(list);
    });
  }

  Future<int> getTotalTracks() => _appDatabase.getTotalTracks();
  Future<int> getTotalListenedTimeInSeconds() =>
      _appDatabase.getTotalListenedTimeInSeconds();
  Future<Map<TrackModel, int>> getListenedTimeByTracks() async {
    Map<Track, int> map = await _appDatabase.getListenedTimeByTracks();
    Map<TrackModel, int> trackModelMap = {};
    for (var entry in map.entries) {
      trackModelMap[entry.key.toDomain()] = entry.value;
    }
    return trackModelMap;
  }

  Future clearListeningHistory() => _appDatabase.clearListeningHistory();

  Future<void> addPicturesToDb(List<PictureModel> pictures) async {
    await _appDatabase.addPicturesToDb(
        pictures.map((element) => element.toCompanion()).toList());
  }

  Future getPictures() => _appDatabase.getPictures();

  Stream<Map<String, List<PictureModel>>> watchPictures() async* {
    await for (var data in _appDatabase.watchPictures()) {
      pictureDataMap.clear();
      for (var pictureData in data) {
        if (pictureDataMap.containsKey(pictureData.trackPath)) {
          var pictureList = pictureDataMap[pictureData.trackPath];
          pictureList?.add(pictureData.toDomain());           
          pictureDataMap[pictureData.trackPath] = pictureList ?? [];
        } else {
          pictureDataMap[pictureData.trackPath] = [pictureData.toDomain()];
        }
      }
      yield pictureDataMap;
    }
  }

  Future clearPictureTable() => _appDatabase.clearPictureTable();
  Stream<List<FavoriteTrackModel>> watchAllFavoriteTracks() async* {
    await for (var favoriteTrackDataList
        in _appDatabase.watchAllFavoriteTracks()) {
      final List<FavoriteTrackModel> favoriteTrackList =
          favoriteTrackDataList.map((element) => element.toDomain()).toList();
      yield favoriteTrackList;
    }
  }

  Future setFavoriteTrack(int trackId) =>
      _appDatabase.setFavoriteTrack(trackId: trackId);
  Future removeFavoriteTrack(int trackId) =>
      _appDatabase.removeFavoriteTrack(trackId: trackId);

  Stream<List<FavoritePlaylistModel>> watchAllFavoritePlaylist() async* {
    _appDatabase.watchAllFavoritePlaylist();
    await for (var favoritePlaylistList
        in _appDatabase.watchAllFavoritePlaylist()) {
      List<FavoritePlaylistModel> list =
          favoritePlaylistList.map((element) => element.toDomain()).toList();
      yield list;
    }
  }

  Future setFavoritePlaylist(int playlistId) =>
      _appDatabase.setFavoritePlaylist(playlistId: playlistId);
  Future removeFavoritePlaylist(int playlistId) =>
      _appDatabase.removeFavoritePlaylist(playlistId: playlistId);

  Stream<(List<PlaylistModel>, List<TrackModel>)>
      watchAllFavoriteData() async* {
    Stream mergedDataStream = StreamGroup.merge([
      _appDatabase.watchAllFavoritePlaylistWithData(),
      _appDatabase.watchAllFavoriteTracksWithData()
    ]);

    List<PlaylistModel> playlistModelList = [];
    List<TrackModel> trackDataList = [];
    await for (var data in mergedDataStream) {
      if (data is List<PlaylistData>) {
        playlistModelList = data.map((element) => element.toDomain()).toList();
      }
      if (data is List<Track>) {
        trackDataList = data.map((element) => element.toDomain()).toList();
      }
      yield (playlistModelList, trackDataList);
    }
  }

  Future deleteTracksByDirectory({required String directoryPath}) => _appDatabase.deleteTracksByDirectory(directoryPath: directoryPath);
  Future<List<String>> getImagePathListByTrackPathList({required List<String> trackPathList}) => _appDatabase.getImagePathListByTrackPathList(trackPathList: trackPathList);
}
