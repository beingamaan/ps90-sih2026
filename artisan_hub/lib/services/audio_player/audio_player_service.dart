// Conditional export based on platform library support
export 'audio_player_stub.dart'
    if (dart.library.html) 'audio_player_web.dart';
