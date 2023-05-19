import 'package:json_annotation/json_annotation.dart';

enum WCMethod {
  @JsonValue("wc_sessionRequest")
  sessionRequest,

  @JsonValue("wc_sessionUpdate")
  sessionUpdate,

  @JsonValue("eth_sign")
  ethSign,

  @JsonValue("personal_sign")
  ethPersonalSign,

  @JsonValue("eth_signTypedData")
  ethSignTypedData,

  @JsonValue("eth_signTransaction")
  ethSignTransaction,

  @JsonValue("eth_sendTransaction")
  ethSendTransaction,

  @JsonValue("wallet_switchEthereumChain")
  walletSwitchNetwork,
}
