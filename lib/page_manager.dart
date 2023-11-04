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
  final repeatCounterNotifier = ValueNotifier<int>(-1);

  bool isIntroPlaying = true;

  final _audioHandler = getIt<AudioHandler>();

  // final DateTime _selectedDay = DateTime.now();

  Duration? mantraDuration = Duration.zero;

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
    final playlist = await songRepository.fetchIntroPlaylist(-1);
    print("InitialLoad: $playlist");
    final mediaItems = MediaItem(
      id: playlist['id'] ?? '',
      album: playlist['album'] ?? '',
      title: playlist['title'] ?? '',
      extras: {'url': playlist['url']},
    );
    clearQueue(-1);
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
      } else if (processingState == AudioProcessingState.completed) {
        print("Completed");
        playButtonNotifier.value = ButtonState.finished;
        if (isIntroPlaying) {}
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
      if (repeatCounterNotifier.value > 0) {
        repeatCounterNotifier.value -= 1;
      }
      // _updateSkipButtons();
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

  void repeatMantraCount(int count, int tithiNo) async {
    final songRepository = getIt<PlaylistRepository>();
    final song;
    final String type = "mantra";
    if (type == "mantra") {
      isIntroPlaying = false;
      song = await songRepository.fetchMantraSong(tithiNo);
    } else {
      isIntroPlaying = true;
      song = await songRepository.fetchIntroPlaylist(tithiNo);
    }
    // mantraDuration = _audioHandler.queue.value.first.duration;
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    List<MediaItem> genList = [];
    for (int i = 0; i < count; i++) {
      genList.add(mediaItem);
    }
    for (int i = 0; i < 108; i++) {
      remove();
    }
    print("queue value length1: ${_audioHandler.queue.value.length}");
    print("Queue length: ${_audioHandler.queue.length}");
    await _audioHandler.addQueueItems(genList);
    print("queue value length: ${_audioHandler.queue.value.length}");
    repeatCounterNotifier.value = count + 1;
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void duration() {
    mantraDuration = _audioHandler.queue.value.first.duration;
  }

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();
  void next5(Duration position) => _audioHandler.seek(Duration(seconds: position.inSeconds + 5));
  void prev5(Duration position) {
    if (position.inSeconds - 5 > 0) {
      _audioHandler.seek(Duration(seconds: position.inSeconds - 5));
    } else {
      _audioHandler.seek(Duration.zero);
    }
  }

  Future<void> onRepeatPlay() async {
    // while(repeatCounterNotifier.value>0) {
    //   seek(Duration.zero);
    //   play();
    //   print("Audio shld play");
    // repeat();
    // print("Audio played");
    // print("_repeatCount: ${repeatCounterNotifier.value}");
    // repeatCounterNotifier.value -=1;
    // repeat();
    // seek(Duration.zero);
    // }
    _audioHandler.play();
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
      } else if (processingState == AudioProcessingState.completed) {
        print("Completed-new");
        decrease();
        playButtonNotifier.value = ButtonState.finished;
        if (repeatCounterNotifier.value > 0) {
          _audioHandler.seek(Duration.zero);
          _audioHandler.pause();
          _audioHandler.play();
        }
      } else if (isPlaying) {
        print("Playing");
        playButtonNotifier.value = ButtonState.playing;
      }
    });
  }

  void decrease() => repeatCounterNotifier.value -= 1;

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        if (isIntroPlaying) {
          _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        } else {
          // onRepeatPlay();
          _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        }
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

  Future<void> add(int tithiNo, String type) async {
    final songRepository = getIt<PlaylistRepository>();
    final song;
    if (type == "mantra") {
      isIntroPlaying = false;
      song = await songRepository.fetchMantraSong(tithiNo);
    } else {
      isIntroPlaying = true;
      song = await songRepository.fetchIntroPlaylist(tithiNo);
    }
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    await _audioHandler.addQueueItem(mediaItem);
    duration();
    // mantraDuration = _audioHandler.queue.value.first.duration;
    // print("Mantra durr add: ${mantraDuration!.inMilliseconds}");
  }

  Future<void> addCount(int res, int count) async {
    // removeAll();
    // await clearQueue();
    final songRepository = getIt<PlaylistRepository>();
    final song = await songRepository.fetchMantraSong(res);
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

  Future<void> clearQueue(int res) async {
    // stop();
    // seek(Duration.zero);
    // final songRepository = getIt<PlaylistRepository>();
    // final song = await songRepository.fetchMantraSong(res);
    // final mediaItem = MediaItem(
    //   id: song['id'] ?? '',
    //   album: song['album'] ?? '',
    //   title: song['title'] ?? '',
    //   extras: {'url': song['url']},
    // );
    // // _audioHandler.queue.forEach((element) {
    // //   print("element $element");
    // //   // _audioHandler.queue.value.removeLast();
    // //   _audioHandler.queue.value.remove(element);
    // // });
    // // _audioHandler.removeQueueItem(mediaItem);
    // _audioHandler.fastForward();
    for (int i = 0; i < 108; i++) {
      remove();
    }
    repeatCounterNotifier.value = -1;
    // add(res, "intro");
    // try {
    //   for (int i = 0; i < 108; i++) {
    //     _audioHandler.removeQueueItemAt(i);
    //   }
    // } catch(e){
    //   // print(e);
    // }
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
