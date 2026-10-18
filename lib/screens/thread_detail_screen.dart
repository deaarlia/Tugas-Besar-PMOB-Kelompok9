import 'package:flutter/material.dart';

import '../data/thread_repository.dart';
import '../models/thread_comment.dart';
import '../models/thread_post.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../viewmodels/thread_detail_view_model.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/thread_card.dart';
import '../widgets/vote_control.dart';
import 'comment_composer_screen.dart';
import 'create_thread_screen.dart';

class ThreadDetailScreen extends StatefulWidget {
  final ThreadPost thread;
  final UserProfile currentUser;
  final bool isOwnPost;
  final bool isFollowed;
  final VoidCallback onToggleFollow;

  const ThreadDetailScreen({
    super.key,
    required this.thread,
    required this.currentUser,
    required this.isOwnPost,
    required this.isFollowed,
    required this.onToggleFollow,
  });

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  late final ThreadDetailViewModel _viewModel = ThreadDetailViewModel(
    isFollowed: widget.isFollowed,
    onToggleFollow: widget.onToggleFollow,
    thread: widget.thread,
    currentUser: widget.currentUser,
  )..loadComments();
  final _commentController = TextEditingController();
  ThreadComment? _replyTo;
  bool _isSending = false;

  ThreadPost get _thread => _viewModel.thread ?? widget.thread;

  @override
  void dispose() {
    _commentController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    final error = await _viewModel.addComment(content, parentId: _replyTo?.id);
    if (!mounted) return;
    setState(() {
      _isSending = false;
      if (error == null) {
        _commentController.clear();
        _replyTo = null;
      }
    });
    if (error != null) AppSnackbar.showError(context, error);
  }

  Future<void> _openCommentComposer() async {
    final replyTo = _replyTo;
    final sent = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => CommentComposerScreen(
          replyingTo: replyTo?.authorName ?? 'utas ini',
          initialContent: _commentController.text,
          onSubmit: ({required content, required photos, required document}) =>
              _viewModel.addComment(
                content,
                parentId: replyTo?.id,
                photos: photos,
                document: document,
              ),
        ),
      ),
    );
    if (!mounted || sent != true) return;
    setState(() {
      _commentController.clear();
      _replyTo = null;
    });
  }

  Future<void> _editThread() async {
    final updated = await Navigator.push<ThreadPost>(
      context,
      MaterialPageRoute<ThreadPost>(
        builder: (_) => CreateThreadScreen(
          author: widget.currentUser,
          editingThread: _thread,
        ),
      ),
    );
    if (!mounted || updated == null) return;
    _viewModel.updateThread(updated);
    AppSnackbar.showSuccess(context, 'Utas berhasil diperbarui.');
  }

  Future<void> _deleteThread() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus utas?'),
        content: const Text(
          'Utas akan disembunyikan dari komunitas. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || shouldDelete != true) return;
    try {
      await ThreadRepository.instance.deleteThread(
        threadId: _thread.id,
        authorName: widget.currentUser.name,
      );
      if (mounted) Navigator.pop(context, true);
    } on ThreadException catch (error) {
      if (mounted) AppSnackbar.showError(context, error.message);
    }
  }

  Future<void> _voteThread(int vote) async {
    final error = await _viewModel.voteThread(vote);
    if (mounted && error != null) AppSnackbar.showError(context, error);
  }

  Future<void> _voteComment(ThreadComment comment, int vote) async {
    final error = await _viewModel.voteComment(comment, vote);
    if (mounted && error != null) AppSnackbar.showError(context, error);
  }

  Future<void> _editComment(ThreadComment comment) async {
    final controller = TextEditingController(text: comment.content);
    final editedContent = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit komentar'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Tulis komentar...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || editedContent == null || editedContent.isEmpty) return;
    final error = await _viewModel.editComment(comment, editedContent);
    if (mounted && error != null) AppSnackbar.showError(context, error);
  }

  Future<void> _deleteComment(ThreadComment comment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus komentar?'),
        content: const Text('Komentar akan dihapus dari percakapan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || shouldDelete != true) return;
    final error = await _viewModel.deleteComment(comment);
    if (mounted && error != null) AppSnackbar.showError(context, error);
  }

  Future<void> _acceptAnswer(ThreadComment comment) async {
    final error = await _viewModel.acceptAnswer(comment);
    if (!mounted) return;
    if (error != null) {
      AppSnackbar.showError(context, error);
    } else {
      AppSnackbar.showSuccess(context, 'Jawaban terbaik berhasil ditandai.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Detail Postingan')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    ThreadCard(
                      thread: _thread,
                      isOwnPost: widget.isOwnPost,
                      isFollowed: _viewModel.isFollowed,
                      onToggleFollow: _viewModel.toggleFollow,
                      onVote: widget.isOwnPost ? null : _voteThread,
                      onEdit: widget.isOwnPost ? _editThread : null,
                      onDelete: widget.isOwnPost ? _deleteThread : null,
                      isDetail: true,
                    ),
                    _buildCommentHeader(),
                    if (_viewModel.isLoadingComments &&
                        _viewModel.comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_viewModel.errorMessage != null &&
                        _viewModel.comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              _viewModel.errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: _viewModel.loadComments,
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      )
                    else if (_viewModel.comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Belum ada komentar. Mulai percakapan!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    else
                      ..._viewModel.rootComments.map(
                        (comment) => _buildComment(comment),
                      ),
                  ],
                ),
              ),
              _buildCommentComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Komentar (${_viewModel.commentCount})',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: AppTypography.sectionTitle,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          PopupMenuButton<CommentSort>(
            tooltip: 'Urutkan komentar',
            initialValue: _viewModel.commentSort,
            icon: const Icon(Icons.sort),
            onSelected: _viewModel.setCommentSort,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: CommentSort.newest,
                child: _buildSortMenuItem('Waktu terbaru', CommentSort.newest),
              ),
              PopupMenuItem(
                value: CommentSort.top,
                child: _buildSortMenuItem('Skor tertinggi', CommentSort.top),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortMenuItem(String label, CommentSort sort) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: _viewModel.commentSort == sort
              ? const Icon(Icons.check, size: 18)
              : null,
        ),
        Text(label),
      ],
    );
  }

  Widget _buildComment(ThreadComment comment, {bool isLast = true}) {
    final isOwnComment = comment.authorName == widget.currentUser.name;
    final isAccepted = _thread.acceptedCommentId == comment.id;
    final canReply = comment.depth < 4 && !comment.isDeleted;
    final replies = _viewModel.repliesFor(comment);
    return Padding(
      padding: EdgeInsets.fromLTRB(comment.depth == 0 ? 16 : 0, 8, 16, 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (comment.depth > 0)
              CustomPaint(
                size: const Size(22, 1),
                painter: _CommentConnectorPainter(
                  isLast: isLast,
                  color: AppColors.border,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCommentContent(
                    comment,
                    isOwnComment: isOwnComment,
                    isAccepted: isAccepted,
                    canReply: canReply,
                  ),
                  if (replies.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        children: [
                          for (var index = 0; index < replies.length; index++)
                            _buildComment(
                              replies[index],
                              isLast: index == replies.length - 1,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentContent(
    ThreadComment comment, {
    required bool isOwnComment,
    required bool isAccepted,
    required bool canReply,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.avatarBg,
                child: Text(
                  UserProfile.initialsOf(comment.authorName),
                  style: const TextStyle(
                    fontSize: AppTypography.micro,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment.authorName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: AppTypography.label,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (comment.authorBadge.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.chipBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              comment.authorBadge,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: AppTypography.micro,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${comment.timeLabel}${comment.isEdited ? ' · diedit' : ''}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: AppTypography.micro,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAccepted)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
              if (isOwnComment && !comment.isDeleted)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  onSelected: (action) {
                    if (action == 'edit') _editComment(comment);
                    if (action == 'delete') _deleteComment(comment);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.isDeleted ? 'Komentar dihapus.' : comment.content,
            style: TextStyle(
              color: comment.isDeleted
                  ? AppColors.textMuted
                  : AppColors.textDark,
              fontSize: AppTypography.body,
              height: 1.4,
              fontStyle: comment.isDeleted ? FontStyle.italic : null,
            ),
          ),
          if (!comment.isDeleted &&
              (comment.photos.isNotEmpty || comment.document != null)) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final photo in comment.photos)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      photo,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (comment.document != null)
                  Chip(
                    avatar: const Icon(Icons.description_outlined, size: 18),
                    label: Text(
                      comment.document!.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
          if (isAccepted)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Jawaban terbaik',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppTypography.caption,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (!comment.isDeleted) ...[
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                VoteControl(
                  upvoteCount: comment.upvoteCount,
                  downvoteCount: comment.downvoteCount,
                  myVote: comment.myVote,
                  compact: true,
                  onVote: isOwnComment
                      ? null
                      : (vote) => _voteComment(comment, vote),
                ),
                if (canReply)
                  TextButton.icon(
                    onPressed: () => setState(() => _replyTo = comment),
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('Balas'),
                  ),
                if (widget.isOwnPost && !isAccepted)
                  TextButton.icon(
                    onPressed: () => _acceptAnswer(comment),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Jawaban terbaik'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyTo != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Membalas ${_replyTo!.authorName} · maksimal 5 tingkat',
                      style: const TextStyle(
                        fontSize: AppTypography.caption,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Batal membalas',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _replyTo = null),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 500,
                    style: const TextStyle(fontSize: AppTypography.body),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: _replyTo == null
                          ? 'Tulis komentar...'
                          : 'Tulis balasan...',
                      counterText: '',
                      helperText:
                          '${_commentController.text.characters.length}/500 karakter',
                      filled: true,
                      fillColor: const Color(0xFFF5F8F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Perbesar composer',
                  onPressed: _isSending ? null : _openCommentComposer,
                  icon: const Icon(Icons.open_in_full, size: 19),
                ),
                IconButton.filled(
                  tooltip: 'Kirim komentar',
                  onPressed: _isSending ? null : _sendComment,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentConnectorPainter extends CustomPainter {
  const _CommentConnectorPainter({required this.isLast, required this.color});

  final bool isLast;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    final centerX = size.width / 2;
    final branchY = 20.0;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, isLast ? branchY : size.height),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, branchY),
      Offset(size.width, branchY),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CommentConnectorPainter oldDelegate) =>
      oldDelegate.isLast != isLast || oldDelegate.color != color;
}
