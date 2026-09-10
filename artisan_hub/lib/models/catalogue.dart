/// Generated or verified e-commerce catalogue listing data.
class Catalogue {
  final String title;
  final String description;
  final String regionalDescription;
  final String targetLang;
  final List<String> tags;
  final String makerStory;

  const Catalogue({
    this.title = '',
    this.description = '',
    this.regionalDescription = '',
    this.targetLang = 'hi',
    this.tags = const [],
    this.makerStory = '',
  });

  Catalogue copyWith({
    String? title,
    String? description,
    String? regionalDescription,
    String? targetLang,
    List<String>? tags,
    String? makerStory,
  }) {
    return Catalogue(
      title: title ?? this.title,
      description: description ?? this.description,
      regionalDescription: regionalDescription ?? this.regionalDescription,
      targetLang: targetLang ?? this.targetLang,
      tags: tags ?? List.from(this.tags),
      makerStory: makerStory ?? this.makerStory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'regional_description': regionalDescription,
      'target_lang': targetLang,
      'tags': tags,
      'maker_story': makerStory,
    };
  }

  factory Catalogue.fromMap(Map<String, dynamic> map) {
    return Catalogue(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      regionalDescription: map['regional_description'] ?? map['hindi_description'] ?? '',
      targetLang: map['target_lang'] ?? 'hi',
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      makerStory: map['maker_story'] ?? '',
    );
  }
}
