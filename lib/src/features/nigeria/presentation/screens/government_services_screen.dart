import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import '../../data/zetra_help_content.dart';
import '../../domain/help_topic.dart';

/// The Zetra product help hub — replaces the old, never-real government
/// services stub. Real, hand-written guides for every Zetra product.
class GovernmentServicesScreen extends StatelessWidget {
  const GovernmentServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return DefaultTabController(
      length: ZetraHelpContent.sections.length,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Zetra Help Center',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: ZetraHelpContent.sections
                .map((s) => Tab(text: s.productName))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: ZetraHelpContent.sections.map((section) {
            return _SectionView(section: section);
          }).toList(),
        ),
      ),
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section});

  final HelpSection section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md.w),
      children: [
        Text(
          section.description,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: AppSpacing.lg.h),
        ...section.topics.map((topic) => _TopicTile(topic: topic)),
      ],
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.topic});

  final HelpTopic topic;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: ExpansionTile(
        title: Text(
          topic.title,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        childrenPadding: EdgeInsets.fromLTRB(AppSpacing.md.w, 0, AppSpacing.md.w, AppSpacing.md.h),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.content,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
