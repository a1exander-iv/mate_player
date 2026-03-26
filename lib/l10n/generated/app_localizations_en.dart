// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String nTracks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      many: 'tracks',
      few: 'tracks',
      two: 'tracks',
      one: 'track',
      zero: 'tracks',
      other: 'tracks',
    );
    return '$_temp0';
  }

  @override
  String nHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      many: 'hours',
      few: 'hours',
      two: 'hours',
      one: 'hour',
      zero: 'hour',
      other: 'hour',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      many: 'minutes',
      few: 'minutes',
      two: 'minutes',
      one: 'minute',
      zero: 'minute',
      other: 'minutes',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      many: 'seconds',
      few: 'seconds',
      two: 'seconds',
      one: 'second',
      zero: 'second',
      other: 'second',
    );
    return '$_temp0';
  }

  @override
  String get shortMinute => 'min';

  @override
  String get shortSecond => 'sec';

  @override
  String get unknownArtist => 'Unknown Artist';

  @override
  String get playlistDefaultName => 'Playlist';

  @override
  String get mainScreen => 'Main';

  @override
  String get favoriteScreen => 'Favorites';

  @override
  String get settingsScreen => 'Settings';

  @override
  String get playlistsHeadline => 'Playlists';

  @override
  String get tracksHeadline => 'Tracks';

  @override
  String get searchHint => 'Search';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortByDurationAscending => 'Duration (ascending)';

  @override
  String get sortByDurationDescending => 'Duration (descending)';

  @override
  String get sortByDateAddedAscending => 'Date added (oldest first)';

  @override
  String get sortByDateAddedDescending => 'Date added (newest first)';

  @override
  String get sortByTitleAscending => 'Title (A-Z)';

  @override
  String get sortByTitleDescending => 'Title (Z-A)';

  @override
  String get sortByFileNameAscending => 'File name (A-Z)';

  @override
  String get sortByFileNameDescending => 'File name (Z-A)';

  @override
  String get withoutSortingMainList => 'No sorting';

  @override
  String get emptyFolderListTitle =>
      'To import music, press the \'Choose folder\' button';

  @override
  String get emptyFolderListSubtitle =>
      'Supported formats: .mp3 .m4a .flac .wav .ogg';

  @override
  String get chooseFolderButton => 'Choose folder';

  @override
  String get trackInfoItemButton => 'Details';

  @override
  String get favoritePlaylistsHeadline => 'Favorite playlists';

  @override
  String get favoriteTracksHeadline => 'Favorite tracks';

  @override
  String get languageSection => 'App language';

  @override
  String get languageName => 'English';

  @override
  String get languageSelectionDialog => 'Select application language';

  @override
  String get fileSection => 'Files';

  @override
  String get refreshButton => 'Refresh';

  @override
  String get foldersTitle => 'Folders';

  @override
  String get foldersSubtitle => 'Select a folder to import audio files';

  @override
  String get usedFolders => 'Used folders:';

  @override
  String get deleteFolderDialogTitle => 'Attention!';

  @override
  String get deleteFolderDialogContent =>
      'All added tracks from this folder will be removed from the app!';

  @override
  String get deleteFolderCancel => 'Cancel';

  @override
  String get deleteFolderConfirm => 'Delete';

  @override
  String get themeSection => 'App theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get colorSection => 'App color';

  @override
  String get useSystemColor => 'Use system color';

  @override
  String get colorTileTitle => 'Color';

  @override
  String get colorTileSubtitle => 'Select a color';

  @override
  String get colorDialogTitle => 'Choose a color';

  @override
  String get statSection => 'Statistics';

  @override
  String get statTileTitle => 'Listening Statistics';

  @override
  String get statTileListeningHistoryClear => 'Clear listening history';

  @override
  String get statTileListeningHistoryClearDialogTitle =>
      'Clear listening history?';

  @override
  String get statTileListeningHistoryClearCancel => 'Cancel';

  @override
  String get statTileListeningHistoryClearConfirm => 'Clear';

  @override
  String get statDialogTitle => 'Listening statistics';

  @override
  String get statTotalTracks => 'Total tracks: ';

  @override
  String get statTotalListened => 'Total listened';

  @override
  String get statListeningTimeByTracks => 'Listening time (by tracks)';

  @override
  String get deleteFromPlaylistMenuItemButton => 'Delete from playlist';

  @override
  String get addAudioFolderMenuItem => 'Add a folder with audio files';

  @override
  String get createPlaylistMenuItem => 'Create playlist';

  @override
  String get deletePlaylistIconButtonTooltip => 'Delete playlist';

  @override
  String get deletePlaylistDialogTitle => 'Do you want to delete the playlist?';

  @override
  String get deletePlaylistCancelButton => 'Cancel';

  @override
  String get deletePlaylistConfirmButton => 'Delete';

  @override
  String get playlistEditMenuButtonTooltip => 'Edit playlist';

  @override
  String get reorderPlaylistMenuItemButton => 'Reorder tracks';

  @override
  String get editPlaylistMenuItemButton => 'Edit playlist';

  @override
  String get reorderPlaylistDialogTitle => 'Change track order in playlist';

  @override
  String get reorderPlaylistCancel => 'Cancel';

  @override
  String get reorderPlaylistSave => 'Save';

  @override
  String get playlistEditDialogTitle => 'Edit playlist';

  @override
  String get playlistCreationDialogTitle => 'Add playlist';

  @override
  String get playlistCommonDialogInputLabelText => 'Playlist name';

  @override
  String get playlistCommonDialogInputValidatorText =>
      'Cannot be empty when editing';

  @override
  String get playlistCommonDialogImageLabelText => 'Playlist image';

  @override
  String get playlistCommonDialogTracks => 'Tracks';

  @override
  String get playlstCommonDialogSelectTracksButton => 'Select tracks';

  @override
  String get playlistCommonDialogSelectTracksDialogTitle => 'Select tracks';

  @override
  String get playlistCommonDialogCreateButton => 'Add';

  @override
  String get playlistCommonDialogEditButton => 'Edit';

  @override
  String get playlistCommonDialogCancelButton => 'Cancel';

  @override
  String get trackInformationSideSheetHeaderTitle => 'Track details';

  @override
  String get untitledTrack => 'Untitled';

  @override
  String get year => 'Year';

  @override
  String get album => 'Album';

  @override
  String get genre => 'Genre';

  @override
  String get trackDuration => 'Track duration';

  @override
  String get fileLocation => 'File location';

  @override
  String get fileSize => 'File size';

  @override
  String get audioQueue => 'Queue';

  @override
  String get nextSequenceList => 'Next';

  @override
  String get shuffleMode => 'Shuffle mode';

  @override
  String get repeatOneTrack => 'Repeat one track';

  @override
  String get repeatAllPlaylist => 'Repeat playlist';

  @override
  String get noRepeat => 'Repeat off';

  @override
  String get shuffleModeDisabledSnackBarText => 'Sequential playback';

  @override
  String get playbackErrorSnackBarText => 'Failed to play track';

  @override
  String get loading => 'Loading';

  @override
  String get informationSectionSettingsScreen => 'Information';

  @override
  String get imagesProvided => 'Images provided';

  @override
  String get appInformation => 'App information';

  @override
  String get thirdPartyIcons => 'Third-party icons';

  @override
  String get additionalSectionSettingsScreen => 'Optionally';

  @override
  String get trackImageCheckboxTileTitle => 'Show track covers';

  @override
  String get trackDisplayOption => 'Track display option';

  @override
  String get trackGridList => 'Grid';

  @override
  String get trackTileList => 'List';

  @override
  String get addToPlaylist => 'Add to playlist';
}
