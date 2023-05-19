import 'package:json_annotation/json_annotation.dart';
import 'package:wc_dart_v1/models/jsonrpc/json_rpc_error.dart';
import 'package:wc_dart_v1/utils/constants.dart';

part 'json_rpc_error_response.g.dart';

@JsonSerializable()
class JsonRpcErrorResponse {
  final int id;
  final String jsonrpc = jsonRpcVersion;
  final JsonRpcError error;

  JsonRpcErrorResponse({
    required this.id,
    required this.error,
  });

  factory JsonRpcErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$JsonRpcErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$JsonRpcErrorResponseToJson(this);

  @override
  String toString() => 'JsonRpcErrorResponse(id: $id, error: $error)';
}
