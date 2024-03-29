import 'package:flutter/material.dart';
import 'package:wc_dart_v1/models/wc_peer_meta.dart';
// import 'package:wallet_connect/wallet_connect.dart';

class SessionRequestView extends StatefulWidget {
  final WCPeerMeta peerMeta;
  final void Function(int) onApprove;
  final void Function() onReject;

  const SessionRequestView({
    Key? key,
    required this.peerMeta,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  State<SessionRequestView> createState() => _SessionRequestViewState();
}

class _SessionRequestViewState extends State<SessionRequestView> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Column(
        children: [
          if (widget.peerMeta.icons.isNotEmpty)
            Container(
              height: 100.0,
              width: 100.0,
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Image.network(widget.peerMeta.icons.first),
            ),
          Text(widget.peerMeta.name),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
      children: [
        if (widget.peerMeta.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(widget.peerMeta.description),
          ),
        if (widget.peerMeta.url.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text('Connection to ${widget.peerMeta.url}'),
          ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () {
                  // widget.onApprove(userService.currentChain.chainId!);
                },
                child: const Text('APPROVE'),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: widget.onReject,
                child: const Text('REJECT'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
