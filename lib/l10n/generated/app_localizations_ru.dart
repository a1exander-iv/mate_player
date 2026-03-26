// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String nTracks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      many: 'треков',
      few: 'трека',
      two: 'трека',
      one: 'трек',
      zero: 'треков',
      other: 'трека',
    );
    return '$_temp0';
  }

  @override
  String nHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      many: 'часов',
      few: 'часа',
      two: 'часа',
      one: 'час',
      zero: 'часов',
      other: 'часа',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      many: 'минут',
      few: 'минуты',
      two: 'минуты',
      one: 'минута',
      zero: 'минут',
      other: 'минуты',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      many: 'секунд',
      few: 'секунды',
      two: 'секунды',
      one: 'секунда',
      zero: 'секунд',
      other: 'секунды',
    );
    return '$_temp0';
  }

  @override
  String get shortMinute => 'мин';

  @override
  String get shortSecond => 'сек';

  @override
  String get unknownArtist => 'Неизвестный исполнитель';

  @override
  String get playlistDefaultName => 'Плейлист';

  @override
  String get mainScreen => 'Главная';

  @override
  String get favoriteScreen => 'Избранное';

  @override
  String get settingsScreen => 'Настройки';

  @override
  String get playlistsHeadline => 'Плейлисты';

  @override
  String get tracksHeadline => 'Треки';

  @override
  String get searchHint => 'Поиск';

  @override
  String get sortLabel => 'Сортировка';

  @override
  String get sortByDurationAscending => 'Длительность (по возрастанию)';

  @override
  String get sortByDurationDescending => 'Длительность (по убыванию)';

  @override
  String get sortByDateAddedAscending => 'Дата добавления (сначала старее)';

  @override
  String get sortByDateAddedDescending => 'Дата добавления (сначала новее)';

  @override
  String get sortByTitleAscending => 'Название (А-Я)';

  @override
  String get sortByTitleDescending => 'Название (Я-А)';

  @override
  String get sortByFileNameAscending => 'Имя файла (А-Я)';

  @override
  String get sortByFileNameDescending => 'Имя файла (Я-А)';

  @override
  String get withoutSortingMainList => 'Без сортировки';

  @override
  String get emptyFolderListTitle =>
      'Для импортирования музыки нажмите на кнопку \'Выбрать папку\'';

  @override
  String get emptyFolderListSubtitle =>
      'Поддерживаемые форматы: .mp3 .m4a .flac .wav .ogg';

  @override
  String get chooseFolderButton => 'Выбрать папку';

  @override
  String get trackInfoItemButton => 'Сведения';

  @override
  String get favoritePlaylistsHeadline => 'Избранные плейлисты';

  @override
  String get favoriteTracksHeadline => 'Избранные треки';

  @override
  String get languageSection => 'Язык приложения';

  @override
  String get languageName => 'Русский';

  @override
  String get languageSelectionDialog => 'Выберите язык приложения';

  @override
  String get fileSection => 'Файлы';

  @override
  String get refreshButton => 'Обновить';

  @override
  String get foldersTitle => 'Папки';

  @override
  String get foldersSubtitle => 'Выберите папку для импорта аудиофайлов';

  @override
  String get usedFolders => 'Используемые папки:';

  @override
  String get deleteFolderDialogTitle => 'Внимание!';

  @override
  String get deleteFolderDialogContent =>
      'Все добавленные треки c этой папки будут удалены из приложения!';

  @override
  String get deleteFolderCancel => 'Отмена';

  @override
  String get deleteFolderConfirm => 'Удалить';

  @override
  String get themeSection => 'Тема приложения';

  @override
  String get systemTheme => 'Системная';

  @override
  String get lightTheme => 'Светлая';

  @override
  String get darkTheme => 'Тёмная';

  @override
  String get colorSection => 'Цвет приложения';

  @override
  String get useSystemColor => 'Использовать системный цвет';

  @override
  String get colorTileTitle => 'Цвет';

  @override
  String get colorTileSubtitle => 'Выберите цвет';

  @override
  String get colorDialogTitle => 'Выберите цвет';

  @override
  String get statSection => 'Статистика';

  @override
  String get statTileTitle => 'Статистика прослушивания';

  @override
  String get statTileListeningHistoryClear => 'Очистить историю прослушивания';

  @override
  String get statTileListeningHistoryClearDialogTitle =>
      'Очистить историю прослушивания?';

  @override
  String get statTileListeningHistoryClearCancel => 'Отмена';

  @override
  String get statTileListeningHistoryClearConfirm => 'Очистить';

  @override
  String get statDialogTitle => 'Статистика прослушивания';

  @override
  String get statTotalTracks => 'Всего треков: ';

  @override
  String get statTotalListened => 'Всего прослушано';

  @override
  String get statListeningTimeByTracks => 'Время прослушивания (по трекам)';

  @override
  String get deleteFromPlaylistMenuItemButton => 'Удалить из плейлиста';

  @override
  String get addAudioFolderMenuItem => 'Добавить папку с аудиофайлами';

  @override
  String get createPlaylistMenuItem => 'Создать плейлист';

  @override
  String get deletePlaylistIconButtonTooltip => 'Удалить плейлист';

  @override
  String get deletePlaylistDialogTitle => 'Вы хотите удалить плейлист?';

  @override
  String get deletePlaylistCancelButton => 'Отмена';

  @override
  String get deletePlaylistConfirmButton => 'Удалить';

  @override
  String get playlistEditMenuButtonTooltip => 'Редактирование плейлиста';

  @override
  String get reorderPlaylistMenuItemButton => 'Изменить порядок треков';

  @override
  String get editPlaylistMenuItemButton => 'Изменить плейлист';

  @override
  String get reorderPlaylistDialogTitle =>
      'Изменение порядка треков в плейлисте';

  @override
  String get reorderPlaylistCancel => 'Отмена';

  @override
  String get reorderPlaylistSave => 'Сохранить';

  @override
  String get playlistEditDialogTitle => 'Изменение плейлиста';

  @override
  String get playlistCreationDialogTitle => 'Добавление плейлиста';

  @override
  String get playlistCommonDialogInputLabelText => 'Название плейлиста';

  @override
  String get playlistCommonDialogInputValidatorText =>
      'При изменении не может быть пустым';

  @override
  String get playlistCommonDialogImageLabelText => 'Картинка плейлиста';

  @override
  String get playlistCommonDialogTracks => 'Треки';

  @override
  String get playlstCommonDialogSelectTracksButton => 'Выбрать треки';

  @override
  String get playlistCommonDialogSelectTracksDialogTitle => 'Выбор треков';

  @override
  String get playlistCommonDialogCreateButton => 'Создать';

  @override
  String get playlistCommonDialogEditButton => 'Изменить';

  @override
  String get playlistCommonDialogCancelButton => 'Отмена';

  @override
  String get trackInformationSideSheetHeaderTitle => 'Информация о треке';

  @override
  String get untitledTrack => 'Без названия';

  @override
  String get year => 'Год';

  @override
  String get album => 'Альбом';

  @override
  String get genre => 'Жанр';

  @override
  String get trackDuration => 'Длительность';

  @override
  String get fileLocation => 'Расположение файла';

  @override
  String get fileSize => 'Размер файла';

  @override
  String get audioQueue => 'Список воспроизведения';

  @override
  String get nextSequenceList => 'Далее';

  @override
  String get shuffleMode => 'Случайный порядок';

  @override
  String get repeatOneTrack => 'Повтор одного трека';

  @override
  String get repeatAllPlaylist => 'Повтор списка воспроизведения';

  @override
  String get noRepeat => 'Повтор выключен';

  @override
  String get shuffleModeDisabledSnackBarText =>
      'Последовательное воспроизведение';

  @override
  String get playbackErrorSnackBarText => 'Не удалось воспроизвести трек';

  @override
  String get loading => 'Загрузка';

  @override
  String get informationSectionSettingsScreen => 'Информация';

  @override
  String get imagesProvided => 'Изображения предоставлены';

  @override
  String get appInformation => 'Информация о приложении';

  @override
  String get thirdPartyIcons => 'Сторонние иконки';

  @override
  String get additionalSectionSettingsScreen => 'Дополнительно';

  @override
  String get trackImageCheckboxTileTitle => 'Показывать обложки треков';

  @override
  String get trackDisplayOption => 'Отображение треков';

  @override
  String get trackGridList => 'Сетка';

  @override
  String get trackTileList => 'Список';

  @override
  String get addToPlaylist => 'Добавить в плейлист';
}
