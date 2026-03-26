import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:mate_player/data/sources/db_type_converters.dart';
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackTitle => text().nullable()();
  TextColumn get trackArtist => text().nullable()();
  IntColumn get trackDurationInMilliseconds => integer().nullable()();
  IntColumn get sampleRate => integer().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get lyrics => text().nullable()();
  TextColumn get performers => text().nullable()();
  TextColumn get album => text().nullable()();
  IntColumn get discNumber => integer().nullable()();
  IntColumn get discTotal => integer().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get trackTotal => integer().nullable()();
  TextColumn get genreList => text().map(const GenreConverter())();
  DateTimeColumn get releaseYear => dateTime().nullable()();
  TextColumn get directoryPath => text()();
  TextColumn get filePath => text().unique()();
  TextColumn get fileBaseName => text()();
  IntColumn get fileSize => integer().nullable()();
  DateTimeColumn get createdTime =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get playbackError =>
      boolean().withDefault(const Constant(false))();
}

class ListenedTrack extends Table {
  IntColumn get trackId =>
      integer().references(Tracks, #id, onDelete: KeyAction.cascade)();
  IntColumn get listenedTimeInSeconds => integer()();
  DateTimeColumn get createdTime => dateTime()();
}

class Playlist extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get createdTime =>
      dateTime().withDefault(currentDateAndTime)();
}

class PlaylistTrack extends Table {
  IntColumn get trackId => integer().references(Tracks, #id,
      onDelete: KeyAction.cascade, onUpdate: KeyAction.cascade)();
  IntColumn get playlistId => integer().references(Playlist, #id,
      onDelete: KeyAction.cascade, onUpdate: KeyAction.cascade)();
  IntColumn get position => integer()();
  DateTimeColumn get createdTime =>
      dateTime().withDefault(currentDateAndTime)();
}

class Picture extends Table {
  TextColumn get trackPath => text().references(Tracks, #filePath,
      onDelete: KeyAction.cascade, onUpdate: KeyAction.cascade)();
  TextColumn get imagePath => text()();
  TextColumn get imageHash => text()();
  TextColumn get mimeType => text().nullable()();
  TextColumn get pictureType => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {trackPath, imageHash}
      ];
}

class FavoriteTrack extends Table {
  IntColumn get trackId => integer()
      .references(Tracks, #id,
          onDelete: KeyAction.cascade, onUpdate: KeyAction.cascade)
      .unique()();
  DateTimeColumn get createdTime =>
      dateTime().withDefault(currentDateAndTime)();
}

class FavoritePlaylist extends Table {
  IntColumn get playlistId => integer()
      .references(Playlist, #id,
          onDelete: KeyAction.cascade, onUpdate: KeyAction.cascade)
      .unique()();
  DateTimeColumn get createdTime =>
      dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Tracks,
  ListenedTrack,
  Playlist,
  PlaylistTrack,
  Picture,
  FavoriteTrack,
  FavoritePlaylist
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection()  {

    return driftDatabase(
      name: 'database',
      native: DriftNativeOptions(
          databaseDirectory: getApplicationSupportDirectory,
          ),
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    });
  }

  Future<List<Track>> get allTracks => select(tracks).get();

  Stream<List<Track>> get watchAllTracks => select(tracks).watch();
  Stream<List<Track>> watchAllTracksByDuration({required bool ascending}) {
    return (select(tracks)
          ..orderBy([
            (track) => ascending
                ? OrderingTerm.asc(track.trackDurationInMilliseconds)
                : OrderingTerm.desc(track.trackDurationInMilliseconds)
          ]))
        .watch();
  }

  Stream<List<Track>> watchAllTracksByDateAdded({required bool ascending}) {
    return (select(tracks)
          ..orderBy([
            (track) => ascending
                ? OrderingTerm.asc(track.createdTime)
                : OrderingTerm.desc(track.createdTime)
          ]))
        .watch();
  }

  Stream<List<Track>> watchAllTrackByTitle({required bool ascending}) {
    return (select(tracks)
          ..orderBy([
            (track) => ascending
                ? OrderingTerm.asc(track.trackTitle)
                : OrderingTerm.desc(track.trackTitle),
            (track) => ascending
                ? OrderingTerm.asc(track.fileBaseName)
                : OrderingTerm.desc(track.fileBaseName)
          ]))
        .watch();
  }

  Stream<List<Track>> watchAllTrackByYear({required bool ascending}) {
    return (select(tracks)
          ..orderBy([
            (track) => ascending
                ? OrderingTerm.asc(track.releaseYear)
                : OrderingTerm.desc(track.releaseYear),
          ]))
        .watch();
  }

  Stream<List<Track>> watchAllTrackByFileName({required bool ascending}) {
    return (select(tracks)
          ..orderBy([
            (track) => ascending
                ? OrderingTerm.asc(track.fileBaseName)
                : OrderingTerm.desc(track.fileBaseName),
          ]))
        .watch();
  }

  Future<void> insertTracks(List<TracksCompanion> trackEntriesList) async {
    await batch((batch) {
      for (final entry in trackEntriesList) {
        batch.insert(
          tracks,
          entry,
          onConflict: DoUpdate((old) {
            return entry;
          }, target: [tracks.filePath]),
        );
      }
    });
  }

  Future<void> updateAudioMetadataByFilePath(
      {required String trackFilePath,
      required TracksCompanion trackEntry}) async {
    update(tracks)
      ..where((track) => track.filePath.equals(trackFilePath))
      ..write(trackEntry);
  }

  Future<void> addListenedTrack(
      {required int trackId, required int listenedTimeInSeconds}) async {
    await into(listenedTrack).insert(ListenedTrackCompanion.insert(
        trackId: trackId,
        listenedTimeInSeconds: listenedTimeInSeconds,
        createdTime: DateTime.now()));
  }

  Future<void> setTrackPlaybackError(int trackId, bool playbackError) async {
    await (update(tracks)..where((t) => t.id.equals(trackId)))
        .write(TracksCompanion(playbackError: Value(playbackError)));
  }

  Future<List<Track>> getTrackListById(List<int> idList) async {
    List<Track> unorderedTrackList =
        await (select(tracks)..where((track) => track.id.isIn(idList))).get();
    final trackMap = {for (var track in unorderedTrackList) track.id: track};
    return idList.map((id) => trackMap[id]!).toList();
  }

  Future<List<PlaylistData>> getPlaylists() async {
    return select(playlist).get();
  }

  Future<void> createPlaylist(
      {required String name, List<int>? trackIds, String? imagePath}) async {
    final playlistId = await into(playlist).insert(
      PlaylistCompanion.insert(
        name: Value(name),
        imagePath: Value(imagePath),
      ),
    );

    if (trackIds != null && trackIds.isNotEmpty) {
      for (int i = 0; i < trackIds.length; i++) {
        await into(playlistTrack).insert(PlaylistTrackCompanion.insert(
          trackId: trackIds[i],
          playlistId: playlistId,
          position: i,
        ));
      }
    }
  }

  Future<void> removeTrackFromPlaylist(int playlistId, int trackId) async {
    delete(playlistTrack)
      ..where(
          (pt) => pt.playlistId.equals(playlistId) & pt.trackId.equals(trackId))
      ..go();
  }

  Future<List<Track>> getPlaylistTracks(int playlistId) async {
    final playlistTrackList = await (select(playlistTrack)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy(
              [(playlistTrack) => OrderingTerm.asc(playlistTrack.position)]))
        .get();

    if (playlistTrackList.isEmpty) return [];
    final trackIds = playlistTrackList.map((pt) => pt.trackId).toList();
    final tracksById =
        await (select(tracks)..where((t) => t.id.isIn(trackIds))).get();

    final trackMap = {for (var track in tracksById) track.id: track};
    return playlistTrackList.map((pt) => trackMap[pt.trackId]!).toList();
  }

  Future<List<int>> getPlaylistTracksIdsList(int playlistId) async {
    final playlistTracks = await (select(playlistTrack)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy(
              [(playlistTrack) => OrderingTerm.asc(playlistTrack.position)]))
        .get();
    if (playlistTracks.isEmpty) return [];
    final trackIds = playlistTracks.map((pt) => pt.trackId).toList();
    return trackIds;
  }

  Future<PlaylistData> getPlaylistInfo(int playlistId) async {
    final playlistData = await (select(playlist)
          ..where((p) => p.id.equals(playlistId)))
        .getSingle();
    return playlistData;
  }

  Future deletePlaylist(int playlistId) async {
    delete(playlist)
      ..where((p) => p.id.equals(playlistId))
      ..go();
  }

  Future<void> setNewTrackIdsListPlaylist(
      int playlistId, List<int> playlistTrackIdsList) async {
    await transaction(() async {
      for (int position = 0;
          position < playlistTrackIdsList.length;
          position++) {
        await (update(playlistTrack)
              ..where((playlistTrack) =>
                  playlistTrack.trackId.equals(playlistTrackIdsList[position])))
            .write(PlaylistTrackCompanion(
          position: Value(position),
        ));
      }
    });
  }

  Future<void> editPlaylist(
      {required int playlistId,
      required String? name,
      List<int>? trackIds,
      String? imagePath}) async {
    //delete playlistTracks by playlistId
    await transaction(() async {
      await (delete(playlistTrack)
            ..where(
                (playlistTrack) => playlistTrack.playlistId.equals(playlistId)))
          .go();
    });

    //prepare data PlaylistTrack to reinsert
    List<PlaylistTrackCompanion> insertTrackList = [];
    if (trackIds != null) {
      for (int i = 0; i < trackIds.length; i++) {
        insertTrackList.add(PlaylistTrackCompanion.insert(
            trackId: trackIds[i], playlistId: playlistId, position: i));
      }
    }

    //reinsert playlistTracks
    await batch((batch) {
      batch.insertAll(playlistTrack, insertTrackList);
    });

    //update playlist name and imagePath
    await (update(playlist)..where((p) => p.id.equals(playlistId)))
        .write(PlaylistCompanion(
      name: Value(name),
      imagePath: Value(imagePath),
    ));
  }

  Future<void> addTrackToPlaylist({required int playlistId, required int trackId}) async {

    List<int> playlistTrackIdsList = await getPlaylistTracksIdsList(playlistId);
    
    if (playlistTrackIdsList.contains(trackId)) return;
    
    final playlistTrackList = await (select(playlistTrack)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy(
              [(playlistTrack) => OrderingTerm.asc(playlistTrack.position)]))
        .get();
    
    await batch((batch) {
    for (var track in playlistTrackList) {
      batch.update(playlistTrack,PlaylistTrackCompanion(trackId: Value(track.trackId), playlistId: Value(playlistId), position: Value(track.position + 1)), where: (table) => table.playlistId.equals(playlistId) & table.trackId.equals(track.trackId),);
    }
    batch.insert(playlistTrack, PlaylistTrackCompanion.insert(trackId: trackId, playlistId: playlistId, position: 0));
    });

  }
  Stream<List<PlaylistData>> watchAllPlaylists() => (select(playlist)
        ..orderBy([(playlist) => OrderingTerm.desc(playlist.createdTime)]))
      .watch();

  Stream<List<PlaylistTrackData>> watchAllPlaylistTrackData(int playlistId) {
    return (select(playlistTrack)
          ..where(
              (playlistTrack) => playlistTrack.playlistId.equals(playlistId))
          ..orderBy(
              [(playlistTrack) => OrderingTerm.asc(playlistTrack.position)]))
        .watch();
  }

  Future<int> getTotalPlaylists() {
    return playlist.count().getSingle();
  }

  Future<List<Track>> getTrackListByDirectory({required String directoryPath}) async {
    return (select(tracks)..where((track) => track.directoryPath.equals(directoryPath))).get();
  }

  Future<void> deleteTracksByDirectory({required String directoryPath}) async {
    await (delete(tracks)
          ..where((track) => track.directoryPath.equals(directoryPath)))
        .go();
    }

  Future<void> deleteTracksByFilePathList({required List<String> filePathList}) async {
    await transaction(() async {
      for (var path in  filePathList) {
        await (delete(tracks)..where((track) => track.filePath.equals(path))).go();
      }
    });
    
  }

  Future<int> getTotalTracks() async {
    return tracks.count().getSingle();
  }

  Future<Set<String>> getTracksFilePaths() async {

    Set<String> pathSet = {};
    final query = selectOnly(tracks, distinct: true);
    query.addColumns([tracks.filePath]);
    final result = await query.get();
    for (final row in result) {
      final path = row.read(tracks.filePath);
      if (path != null) {
        pathSet.add(path);
      }
    }

    return pathSet;
  }

  Future<int> getTotalListenedTimeInSeconds() async {
    final query = selectOnly(listenedTrack)
      ..addColumns([listenedTrack.listenedTimeInSeconds.sum()]);
    final result = await query.getSingle();
    return result.read(listenedTrack.listenedTimeInSeconds.sum()) ?? 0;
  }

  Future<Map<Track, int>> getListenedTimeByTracks() async {
    final query = select(listenedTrack).join([
      innerJoin(tracks, tracks.id.equalsExp(listenedTrack.trackId)),
    ]);

    query.addColumns([listenedTrack.listenedTimeInSeconds.sum()]);
    query.groupBy([listenedTrack.trackId]);
    query.orderBy(
        [OrderingTerm.desc(listenedTrack.listenedTimeInSeconds.sum())]);
    final result = await query.get();

    Map<Track, int> listenedTracksMap = {};

    for (final row in result) {
      Track track = row.readTable(tracks);
      int listenedSeconds =
          row.read(listenedTrack.listenedTimeInSeconds.sum()) ?? 0;
      listenedTracksMap[track] = listenedSeconds;
    }

    return listenedTracksMap;
  }

  Future clearListeningHistory() async {
    await delete(listenedTrack).go();
  }

  Future addPicturesToDb(List<PictureCompanion> pictureList) async {
    await batch((batch) {
      for (final entry in pictureList) {
        batch.insert(
          picture, 
          entry,
          mode: InsertMode.insertOrReplace,
          );
      }
      });
     
  }

  Future<List<String>> getImagePathListByTrackPathList({required List<String> trackPathList}) async {

    final List<PictureData> pictureDataList = await (select(picture)..where((pictureData) => pictureData.trackPath.isIn(trackPathList))).get();
    final List<String> imagePathList = pictureDataList.map((element) => element.imagePath).toList();

    return imagePathList;
  }

  Future<Map<String, List<PictureData>>> getPictures() async {
    Map<String, List<PictureData>> trackPathPictureMap = {};
    List<PictureData> pictureDataList = await select(picture).get();
    pictureDataList.map((picture) {
      if (trackPathPictureMap.containsKey(picture.trackPath)) {
        var pictureList = trackPathPictureMap[picture.trackPath];
        pictureList?.add(picture);
      } else {
        trackPathPictureMap[picture.trackPath] = [picture];
      }
    });

    return trackPathPictureMap;
  }

  Stream<List<PictureData>> watchPictures() {
    return select(picture).watch();
  }

  Future clearPictureTable() async {
    return delete(picture).go();
  }

  Stream<List<FavoriteTrackData>> watchAllFavoriteTracks() {
    return select(favoriteTrack).watch();
  }

  Future setFavoriteTrack({required int trackId}) {
    return into(favoriteTrack)
        .insert(FavoriteTrackCompanion.insert(trackId: trackId));
  }

  Future<void> removeFavoriteTrack({required int trackId}) async {
    delete(favoriteTrack)
      ..where((fTrack) => fTrack.trackId.equals(trackId))
      ..go();
  }

  Stream<List<FavoritePlaylistData>> watchAllFavoritePlaylist() {
    return select(favoritePlaylist).watch();
  }

  Future setFavoritePlaylist({required int playlistId}) {
    return into(favoritePlaylist)
        .insert(FavoritePlaylistCompanion.insert(playlistId: playlistId));
  }

  Future<void> removeFavoritePlaylist({required int playlistId}) async {
    delete(favoritePlaylist)
      ..where((fPlaylist) => fPlaylist.playlistId.equals(playlistId))
      ..go();
  }

  Stream<List<PlaylistData>> watchAllFavoritePlaylistWithData() async* {
    final query = select(favoritePlaylist).join([
      innerJoin(playlist, playlist.id.equalsExp(favoritePlaylist.playlistId))
    ]).watch();
    await for (var result in query) {
      final List<PlaylistData> playlistDataList = [];
      for (final row in result) {
        PlaylistData playlistData = row.readTable(playlist);
        playlistDataList.add(playlistData);
      }
      yield playlistDataList;
    }
  }

  Stream<List<Track>> watchAllFavoriteTracksWithData() async* {
    final query = select(favoriteTrack).join([
      innerJoin(tracks, tracks.id.equalsExp(favoriteTrack.trackId))
    ]).watch();
    await for (var result in query) {
      final List<Track> trackDataList = [];
      for (final row in result) {
        Track trackData = row.readTable(tracks);
        trackDataList.add(trackData);
      }
      yield trackDataList;
    }
  }
}
