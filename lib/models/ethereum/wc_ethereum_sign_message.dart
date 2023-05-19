enum WCSignType { message, personalMessage, typedMessage }

class WCEthereumSignMessage {
  final List<String> raw;
  final WCSignType type;
  WCEthereumSignMessage({
    required this.raw,
    required this.type,
  });

  String? get data {
    switch (type) {
      case WCSignType.message:
        return raw[1];
      case WCSignType.typedMessage:
        return raw[1];
      case WCSignType.personalMessage:
        return raw[0];
      default:
        return null;
    }
  }
}
