/// Add Nigerian knowledge sources here yourself — just copy a line and
/// change the name/url/category. No other file ever needs to change
/// when you add a new source.
///
/// Example: NigeriaSource('Fela Kuti - Afrobeat pioneer', 'https://en.wikipedia.org/wiki/Fela_Kuti', 'Music & Culture'),
class NigeriaSource {
  final String name;
  final String url;
  final String category;

  const NigeriaSource(this.name, this.url, this.category);
}

const List<NigeriaSource> nigeriaSources = [
  NigeriaSource('Federal Government of Nigeria', 'https://www.nigeria.gov.ng', 'Government'),
  NigeriaSource('National Bureau of Statistics', 'https://www.nigerianstat.gov.ng', 'Economy'),
  NigeriaSource('Central Bank of Nigeria', 'https://www.cbn.gov.ng', 'Finance'),

  // Add your own below — just copy this pattern:
  // NigeriaSource('Name here', 'https://link-here.com', 'Category here'),
];
