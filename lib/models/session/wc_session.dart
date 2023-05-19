import 'package:hive_flutter/hive_flutter.dart';

part 'wc_session.g.dart';

// @JsonSerializable()
@HiveType(typeId: 3)
class WCSession {
  @HiveField(0)
  final String topic;
  @HiveField(1)
  final String version;
  @HiveField(2)
  final String bridge;
  @HiveField(3)
  final String key;

  WCSession({
    required this.topic,
    required this.version,
    required this.bridge,
    required this.key,
  });

  String toUri() => "wc:$topic@$version?bridge=$bridge&key=$key";

  factory WCSession.from(String wcUri) {
    if (!wcUri.startsWith("wc:")) {
      return WCSession.empty();
    }

    final uriString = wcUri.replaceAll("wc:", "wc://");
    final uri = Uri.parse(uriString);
    final bridge = uri.queryParameters["bridge"];
    final key = uri.queryParameters["key"];
    final topic = uri.userInfo;
    final version = uri.host;
    if (bridge == null || key == null) {
      return WCSession.empty();
    }

    return WCSession(topic: topic, version: version, bridge: bridge, key: key);
  }

  factory WCSession.empty() =>
      WCSession(topic: '', version: '', bridge: '', key: '');

  factory WCSession.fromJson(Map<String, dynamic> json) =>
      _$WCSessionFromJson(json);

  Map<String, dynamic> toJson() => _$WCSessionToJson(this);

  @override
  String toString() {
    return 'WCSession(topic: $topic, version: $version, bridge: $bridge, key: $key)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WCSession &&
        other.topic == topic &&
        other.version == version &&
        other.bridge == bridge &&
        other.key == key;
  }

  @override
  int get hashCode {
    return topic.hashCode ^ version.hashCode ^ bridge.hashCode ^ key.hashCode;
  }
}
