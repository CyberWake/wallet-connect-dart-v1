import 'package:hive_flutter/hive_flutter.dart';
import 'package:wc_dart_v1/wc_dart_v1.dart';

part 'session_model.g.dart';

@HiveType(typeId: 1)
class SavedSessions {
  @HiveField(0)
  final List<WCSessionStore> sessions;

  SavedSessions(this.sessions);

  set addSession(WCSessionStore newSession) {
    sessions.add(newSession);
  }

  set removeSession(WCSessionStore sessionToRemove) {
    sessions.remove(sessionToRemove);
  }
}
