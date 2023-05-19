import 'package:json_annotation/json_annotation.dart';

enum MessageType {
  @JsonValue('pub')
  pub,
  @JsonValue('sub')
  sub
}
