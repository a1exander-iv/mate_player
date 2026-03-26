import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @nTracks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{tracks} zero{tracks} one{track} two{tracks} few{tracks} many{tracks}}'**
  String nTracks(int count);

  /// hours
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{hour} zero{hour} one{hour} two{hours} few{hours} many{hours}}'**
  String nHours(int count);

  /// N minutes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{minutes} zero{minute} one{minute} two{minutes} few{minutes} many{minutes}}'**
  String nMinutes(int count);

  /// N seconds
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{second} zero{second} one{second} two{seconds} few{seconds} many{seconds}}'**
  String nSeconds(int count);

  /// No description provided for @shortMinute.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get shortMinute;

  /// No description provided for @shortSecond.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get shortSecond;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get unknownArtist;

  /// No description provided for @playlistDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlistDefaultName;

  /// navigation destination
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get mainScreen;

  /// navigation destination
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoriteScreen;

  /// navigation destination
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreen;

  /// No description provided for @playlistsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlistsHeadline;

  /// No description provided for @tracksHeadline.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tracksHeadline;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @sortByDurationAscending.
  ///
  /// In en, this message translates to:
  /// **'Duration (ascending)'**
  String get sortByDurationAscending;

  /// No description provided for @sortByDurationDescending.
  ///
  /// In en, this message translates to:
  /// **'Duration (descending)'**
  String get sortByDurationDescending;

  /// No description provided for @sortByDateAddedAscending.
  ///
  /// In en, this message translates to:
  /// **'Date added (oldest first)'**
  String get sortByDateAddedAscending;

  /// No description provided for @sortByDateAddedDescending.
  ///
  /// In en, this message translates to:
  /// **'Date added (newest first)'**
  String get sortByDateAddedDescending;

  /// No description provided for @sortByTitleAscending.
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get sortByTitleAscending;

  /// No description provided for @sortByTitleDescending.
  ///
  /// In en, this message translates to:
  /// **'Title (Z-A)'**
  String get sortByTitleDescending;

  /// No description provided for @sortByFileNameAscending.
  ///
  /// In en, this message translates to:
  /// **'File name (A-Z)'**
  String get sortByFileNameAscending;

  /// No description provided for @sortByFileNameDescending.
  ///
  /// In en, this message translates to:
  /// **'File name (Z-A)'**
  String get sortByFileNameDescending;

  /// No description provided for @withoutSortingMainList.
  ///
  /// In en, this message translates to:
  /// **'No sorting'**
  String get withoutSortingMainList;

  /// No description provided for @emptyFolderListTitle.
  ///
  /// In en, this message translates to:
  /// **'To import music, press the \'Choose folder\' button'**
  String get emptyFolderListTitle;

  /// No description provided for @emptyFolderListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supported formats: .mp3 .m4a .flac .wav .ogg'**
  String get emptyFolderListSubtitle;

  /// No description provided for @chooseFolderButton.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get chooseFolderButton;

  /// No description provided for @trackInfoItemButton.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get trackInfoItemButton;

  /// No description provided for @favoritePlaylistsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Favorite playlists'**
  String get favoritePlaylistsHeadline;

  /// No description provided for @favoriteTracksHeadline.
  ///
  /// In en, this message translates to:
  /// **'Favorite tracks'**
  String get favoriteTracksHeadline;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageSection;

  /// No description provided for @languageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// No description provided for @languageSelectionDialog.
  ///
  /// In en, this message translates to:
  /// **'Select application language'**
  String get languageSelectionDialog;

  /// No description provided for @fileSection.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get fileSection;

  /// No description provided for @refreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshButton;

  /// No description provided for @foldersTitle.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get foldersTitle;

  /// No description provided for @foldersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a folder to import audio files'**
  String get foldersSubtitle;

  /// No description provided for @usedFolders.
  ///
  /// In en, this message translates to:
  /// **'Used folders:'**
  String get usedFolders;

  /// No description provided for @deleteFolderDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Attention!'**
  String get deleteFolderDialogTitle;

  /// No description provided for @deleteFolderDialogContent.
  ///
  /// In en, this message translates to:
  /// **'All added tracks from this folder will be removed from the app!'**
  String get deleteFolderDialogContent;

  /// No description provided for @deleteFolderCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteFolderCancel;

  /// No description provided for @deleteFolderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteFolderConfirm;

  /// No description provided for @themeSection.
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get themeSection;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @colorSection.
  ///
  /// In en, this message translates to:
  /// **'App color'**
  String get colorSection;

  /// No description provided for @useSystemColor.
  ///
  /// In en, this message translates to:
  /// **'Use system color'**
  String get useSystemColor;

  /// No description provided for @colorTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorTileTitle;

  /// No description provided for @colorTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a color'**
  String get colorTileSubtitle;

  /// No description provided for @colorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a color'**
  String get colorDialogTitle;

  /// No description provided for @statSection.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statSection;

  /// No description provided for @statTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Listening Statistics'**
  String get statTileTitle;

  /// No description provided for @statTileListeningHistoryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear listening history'**
  String get statTileListeningHistoryClear;

  /// No description provided for @statTileListeningHistoryClearDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear listening history?'**
  String get statTileListeningHistoryClearDialogTitle;

  /// No description provided for @statTileListeningHistoryClearCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get statTileListeningHistoryClearCancel;

  /// No description provided for @statTileListeningHistoryClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get statTileListeningHistoryClearConfirm;

  /// No description provided for @statDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Listening statistics'**
  String get statDialogTitle;

  /// No description provided for @statTotalTracks.
  ///
  /// In en, this message translates to:
  /// **'Total tracks: '**
  String get statTotalTracks;

  /// No description provided for @statTotalListened.
  ///
  /// In en, this message translates to:
  /// **'Total listened'**
  String get statTotalListened;

  /// No description provided for @statListeningTimeByTracks.
  ///
  /// In en, this message translates to:
  /// **'Listening time (by tracks)'**
  String get statListeningTimeByTracks;

  /// No description provided for @deleteFromPlaylistMenuItemButton.
  ///
  /// In en, this message translates to:
  /// **'Delete from playlist'**
  String get deleteFromPlaylistMenuItemButton;

  /// No description provided for @addAudioFolderMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Add a folder with audio files'**
  String get addAudioFolderMenuItem;

  /// No description provided for @createPlaylistMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Create playlist'**
  String get createPlaylistMenuItem;

  /// No description provided for @deletePlaylistIconButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist'**
  String get deletePlaylistIconButtonTooltip;

  /// No description provided for @deletePlaylistDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the playlist?'**
  String get deletePlaylistDialogTitle;

  /// No description provided for @deletePlaylistCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deletePlaylistCancelButton;

  /// No description provided for @deletePlaylistConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletePlaylistConfirmButton;

  /// No description provided for @playlistEditMenuButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit playlist'**
  String get playlistEditMenuButtonTooltip;

  /// No description provided for @reorderPlaylistMenuItemButton.
  ///
  /// In en, this message translates to:
  /// **'Reorder tracks'**
  String get reorderPlaylistMenuItemButton;

  /// No description provided for @editPlaylistMenuItemButton.
  ///
  /// In en, this message translates to:
  /// **'Edit playlist'**
  String get editPlaylistMenuItemButton;

  /// No description provided for @reorderPlaylistDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change track order in playlist'**
  String get reorderPlaylistDialogTitle;

  /// No description provided for @reorderPlaylistCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reorderPlaylistCancel;

  /// No description provided for @reorderPlaylistSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get reorderPlaylistSave;

  /// No description provided for @playlistEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit playlist'**
  String get playlistEditDialogTitle;

  /// No description provided for @playlistCreationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add playlist'**
  String get playlistCreationDialogTitle;

  /// No description provided for @playlistCommonDialogInputLabelText.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistCommonDialogInputLabelText;

  /// No description provided for @playlistCommonDialogInputValidatorText.
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty when editing'**
  String get playlistCommonDialogInputValidatorText;

  /// No description provided for @playlistCommonDialogImageLabelText.
  ///
  /// In en, this message translates to:
  /// **'Playlist image'**
  String get playlistCommonDialogImageLabelText;

  /// No description provided for @playlistCommonDialogTracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get playlistCommonDialogTracks;

  /// No description provided for @playlstCommonDialogSelectTracksButton.
  ///
  /// In en, this message translates to:
  /// **'Select tracks'**
  String get playlstCommonDialogSelectTracksButton;

  /// No description provided for @playlistCommonDialogSelectTracksDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select tracks'**
  String get playlistCommonDialogSelectTracksDialogTitle;

  /// No description provided for @playlistCommonDialogCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get playlistCommonDialogCreateButton;

  /// No description provided for @playlistCommonDialogEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get playlistCommonDialogEditButton;

  /// No description provided for @playlistCommonDialogCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get playlistCommonDialogCancelButton;

  /// No description provided for @trackInformationSideSheetHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Track details'**
  String get trackInformationSideSheetHeaderTitle;

  /// No description provided for @untitledTrack.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitledTrack;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @genre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @trackDuration.
  ///
  /// In en, this message translates to:
  /// **'Track duration'**
  String get trackDuration;

  /// No description provided for @fileLocation.
  ///
  /// In en, this message translates to:
  /// **'File location'**
  String get fileLocation;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get fileSize;

  /// No description provided for @audioQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get audioQueue;

  /// No description provided for @nextSequenceList.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextSequenceList;

  /// No description provided for @shuffleMode.
  ///
  /// In en, this message translates to:
  /// **'Shuffle mode'**
  String get shuffleMode;

  /// No description provided for @repeatOneTrack.
  ///
  /// In en, this message translates to:
  /// **'Repeat one track'**
  String get repeatOneTrack;

  /// No description provided for @repeatAllPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Repeat playlist'**
  String get repeatAllPlaylist;

  /// No description provided for @noRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat off'**
  String get noRepeat;

  /// No description provided for @shuffleModeDisabledSnackBarText.
  ///
  /// In en, this message translates to:
  /// **'Sequential playback'**
  String get shuffleModeDisabledSnackBarText;

  /// No description provided for @playbackErrorSnackBarText.
  ///
  /// In en, this message translates to:
  /// **'Failed to play track'**
  String get playbackErrorSnackBarText;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @informationSectionSettingsScreen.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get informationSectionSettingsScreen;

  /// No description provided for @imagesProvided.
  ///
  /// In en, this message translates to:
  /// **'Images provided'**
  String get imagesProvided;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get appInformation;

  /// No description provided for @thirdPartyIcons.
  ///
  /// In en, this message translates to:
  /// **'Third-party icons'**
  String get thirdPartyIcons;

  /// No description provided for @additionalSectionSettingsScreen.
  ///
  /// In en, this message translates to:
  /// **'Optionally'**
  String get additionalSectionSettingsScreen;

  /// No description provided for @trackImageCheckboxTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Show track covers'**
  String get trackImageCheckboxTileTitle;

  /// No description provided for @trackDisplayOption.
  ///
  /// In en, this message translates to:
  /// **'Track display option'**
  String get trackDisplayOption;

  /// No description provided for @trackGridList.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get trackGridList;

  /// No description provided for @trackTileList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get trackTileList;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
