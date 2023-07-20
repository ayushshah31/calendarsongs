import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'services/playlist_repository.dart';
import 'services/service_locator.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  bool isIntroPlaying = true;

  final _audioHandler = getIt<AudioHandler>();

  final DateTime _selectedDay = DateTime.now();

  // Events: Calls coming from the UI
  void init() async {
    await _loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> _loadPlaylist() async {
    final songRepository = getIt<PlaylistRepository>();
    final playlist = await songRepository.fetchIntroPlaylist(_selectedDay);
    print("Initial: $playlist");
    final mediaItems = MediaItem(
      id: playlist['id'] ?? '',
      album: playlist['album'] ?? '',
      title: playlist['title'] ?? '',
      extras: {'url': playlist['url']},
    );
    isIntroPlaying = true;
    // _audioHandler.addQueueItems(mediaItems);
    _audioHandler.addQueueItem(mediaItems);
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
      } else {
        final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        print("Loading");
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        print("Paused");
        playButtonNotifier.value = ButtonState.paused;
      } else if(processingState == AudioProcessingState.completed){
        print("Completed");
        playButtonNotifier.value = ButtonState.finished;
        if(isIntroPlaying){

        }
        // _audioHandler.seek(Duration.zero);
        // _audioHandler.pause();
      } else if (isPlaying) {
        print("Playing");
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();
  void next5(Duration position) => _audioHandler.seek(Duration(seconds: position.inSeconds+5));
  void prev5(Duration position){
    if(position.inSeconds-5>0) {
      _audioHandler.seek(Duration(seconds: position.inSeconds - 5));
    } else {
      _audioHandler.seek(Duration.zero);
    }
  }

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      // case RepeatState.repeatPlaylist:
      //   _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
      //   break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> add(DateTime date, String type) async {
    final songRepository = getIt<PlaylistRepository>();
    final song;
    if(type == "mantra") {
      isIntroPlaying = false;
      song = await songRepository.fetchMantraSong(date);
    } else {
      isIntroPlaying = true;
      song = await songRepository.fetchIntroPlaylist(date);
    }
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    _audioHandler.addQueueItem(mediaItem);
  }

  Future<void> addCount(DateTime date,int count) async{
    // removeAll();
    await clearQueue();
    final songRepository = getIt<PlaylistRepository>();
    final song = await songRepository.fetchMantraSong(date);
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    // for(int i=0;i<count;i++){
    //   // _audioHandler.addQueueItem(mediaItem);
    //   _audioHandler.addQueueItem(mediaItem);
    // }
    _audioHandler.addQueueItems(List.generate(count, (index) => mediaItem));
  }

  Future<void> clearQueue() async{
    print("val: ${_audioHandler.queue.value}");
    // _audioHandler.queue.forEach((element) {
    //   _audioHandler.removeQueueItem(element);
    // });
    for (var element in _audioHandler.queue.value) {
      print("ele: $element");
      _audioHandler.queue.value.remove(element);
    }
    // var len = await _audioHandler.queue.length;
    // print("len: $len");
    // for (int i = 0; i < _audioHandler.queue.value.length; i++) {
    //   remove();
    // }
    print("val now: ${_audioHandler.queue.value}");
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }
}