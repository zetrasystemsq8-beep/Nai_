import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import '../../data/chat_history_store.dart';
import '../../domain/chat_message.dart';
import 'chat_session_detail_screen.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final _store = ChatHistoryStore();
  final _searchController = TextEditingController();

  List<ChatSession> _allSessions = [];
  List<ChatSession> _filteredSessions = [];
  bool _loading = true;

  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sessions = await _store.getAllSessions();
    if (mounted) {
      setState(() {
        _allSessions = sessions;
        _filteredSessions = sessions;
        _loading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSessions = _allSessions;
      } else {
        _filteredSessions = _allSessions.where((s) {
          final inTitle = s.title.toLowerCase().contains(query);
          final inMessages = s.messages.any((m) => m.content.toLowerCase().contains(query));
          return inTitle || inMessages;
        }).toList();
      }
    });
  }

  Future<void> _delete(String id) async {
    await _store.deleteSession(id);
    await _load();
    _onSearchChanged();
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${_selectedIds.length} conversation(s)?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final id in _selectedIds) {
        await _store.deleteSession(id);
      }
      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });
      await _load();
      _onSearchChanged();
    }
  }

  Future<void> _renameSession(ChatSession session) async {
    final controller = TextEditingController(text: session.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Conversation title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      await _store.renameSession(session.id, newTitle);
      await _load();
      _onSearchChanged();
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) _selectionMode = false;
    });
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _selectionMode
            ? Text('${_selectedIds.length} selected')
            : Text(
                'Chat History',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _selectionMode = false;
                  _selectedIds.clear();
                }),
              )
            : null,
        actions: _selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          if (!_selectionMode && _allSessions.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md.w, 0, AppSpacing.md.w, AppSpacing.sm.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: const Icon(IconsaxPlusLinear.search_normal, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: AppBorders.card,
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md.w,
                    vertical: AppSpacing.sm.h,
                  ),
                ),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _allSessions.isEmpty
                    ? _buildEmptyState(context)
                    : _filteredSessions.isEmpty
                        ? Center(
                            child: Text(
                              'No matching conversations',
                              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: EdgeInsets.all(AppSpacing.md.w),
                              itemCount: _filteredSessions.length,
                              itemBuilder: (context, index) {
                                final session = _filteredSessions[index];
                                final lastMessage = session.messages.isNotEmpty
                                    ? session.messages.last.content
                                    : '';
                                final isSelected = _selectedIds.contains(session.id);

                                return Dismissible(
                                  key: ValueKey(session.id),
                                  direction: _selectionMode
                                      ? DismissDirection.none
                                      : DismissDirection.endToStart,
                                  onDismissed: (_) => _delete(session.id),
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                                    decoration: BoxDecoration(
                                      color: colorScheme.error,
                                      borderRadius: AppBorders.md,
                                    ),
                                    child: Icon(Icons.delete, color: colorScheme.onError),
                                  ),
                                  child: Card(
                                    margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
                                    color: isSelected
                                        ? colorScheme.primary.withValues(alpha: 0.1)
                                        : null,
                                    child: ListTile(
                                      onTap: () {
                                        if (_selectionMode) {
                                          _toggleSelection(session.id);
                                        } else {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ChatSessionDetailScreen(session: session),
                                            ),
                                          );
                                        }
                                      },
                                      onLongPress: () {
                                        if (!_selectionMode) _enterSelectionMode(session.id);
                                      },
                                      leading: _selectionMode
                                          ? Icon(
                                              isSelected
                                                  ? Icons.check_circle
                                                  : Icons.radio_button_unchecked,
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurfaceVariant,
                                            )
                                          : null,
                                      title: Text(
                                        session.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                      ),
                                      trailing: _selectionMode
                                          ? null
                                          : IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 18),
                                              onPressed: () => _renameSession(session),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xl.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusLinear.clock,
                size: 64.sp,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              'No conversations yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              'Your past conversations with NAI\nwill appear here.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
