// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_rpc_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonRpcRequest _$JsonRpcRequestFromJson(Map<String, dynamic> json) =>
    JsonRpcRequest(
      id: json['id'] as int,
      jsonrpc: json['jsonrpc'] as String? ?? jsonRpcVersion,
      method: $enumDecodeNullable(_$WCMethodEnumMap, json['method'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
      params: json['params'] as List<dynamic>?,
    );

Map<String, dynamic> _$JsonRpcRequestToJson(JsonRpcRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jsonrpc': instance.jsonrpc,
      'method': _$WCMethodEnumMap[instance.method],
      'params': instance.params,
    };

const _$WCMethodEnumMap = {
  WCMethod.sessionRequest: 'wc_sessionRequest',
  WCMethod.sessionUpdate: 'wc_sessionUpdate',
  WCMethod.ethSign: 'eth_sign',
  WCMethod.ethPersonalSign: 'personal_sign',
  WCMethod.ethSignTypedData: 'eth_signTypedData',
  WCMethod.ethSignTransaction: 'eth_signTransaction',
  WCMethod.ethSendTransaction: 'eth_sendTransaction',
  WCMethod.walletSwitchNetwork: 'wallet_switchEthereumChain',
};
