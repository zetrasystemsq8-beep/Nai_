import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// Fetches live Nigerian headlines from Google News RSS — free, unlimited,
/// no API key or rate limits, since it's a public RSS feed rather than a
/// commercial API product.
class NigeriaNewsRSS {
  static const _feedUrl = 'https://news.google.com/rss?hl=en-NG&gl=NG&ceid=NG:en';

  Future<List<Map<String, String>>> fetchHeadlines({String? searchQuery}) async {
    try {
      final url = searchQuery != null && searchQuery.trim().isNotEmpty
          ? Uri.parse(
              'https://news.google.com/rss/search?q=${Uri.encodeComponent(searchQuery)}+when:7d&hl=en-NG&gl=NG&ceid=NG:en',
            )
          : Uri.parse(_feedUrl);

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      return items.take(8).map((item) {
        final title = item.findElements('title').isNotEmpty
            ? item.findElements('title').first.text
            : '';
        final link = item.findElements('link').isNotEmpty
            ? item.findElements('link').first.text
            : '';
        final description = item.findElements('description').isNotEmpty
            ? item.findElements('description').first.text
            : '';
        final source = item.findElements('source').isNotEmpty
            ? item.findElements('source').first.text
            : 'Google News';

        return {
          'title': title,
          'link': link,
          'description': _stripHtml(description),
          'source': source,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}
