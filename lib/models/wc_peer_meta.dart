import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wc_peer_meta.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class WCPeerMeta {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String url;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final List<String> icons;

  WCPeerMeta({
    required this.name,
    required this.url,
    required this.description,
    this.icons = const [],
  });

  factory WCPeerMeta.empty() => WCPeerMeta(
        name: '',
        url: '',
        description: '',
        icons: const [],
      );

  factory WCPeerMeta.fromJson(Map<String, dynamic> json) =>
      _$WCPeerMetaFromJson(json);

  Map<String, dynamic> toJson() => _$WCPeerMetaToJson(this);

  @override
  String toString() {
    return 'WCPeerMeta(name: $name, url: $url, description: $description, icons: $icons)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is WCPeerMeta &&
        other.name == name &&
        other.url == url &&
        other.description == description &&
        listEquals(other.icons, icons);
  }

  @override
  int get hashCode {
    return name.hashCode ^ url.hashCode ^ description.hashCode ^ icons.hashCode;
  }
}
