class HelpTopic {
  final String title;
  final String content;

  const HelpTopic({required this.title, required this.content});
}

class HelpSection {
  final String productName;
  final String description;
  final List<HelpTopic> topics;

  const HelpSection({
    required this.productName,
    required this.description,
    required this.topics,
  });
}
