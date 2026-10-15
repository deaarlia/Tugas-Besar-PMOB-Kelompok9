import 'package:flutter/material.dart';

import '../models/thread_post.dart';
import '../widgets/thread_card.dart';

class ThreadDetailScreen extends StatefulWidget {
  final ThreadPost thread;
  final bool isOwnPost;
  final bool isFollowed;
  final VoidCallback onToggleFollow;

  const ThreadDetailScreen({
    super.key,
    required this.thread,
    required this.isOwnPost,
    required this.isFollowed,
    required this.onToggleFollow,
  });

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  late bool _isFollowed = widget.isFollowed;

  void _toggleFollow() {
    setState(() => _isFollowed = !_isFollowed);
    widget.onToggleFollow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Postingan')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ThreadCard(
            thread: widget.thread,
            isOwnPost: widget.isOwnPost,
            isFollowed: _isFollowed,
            onToggleFollow: _toggleFollow,
            isDetail: true,
          ),
        ),
      ),
    );
  }
}
