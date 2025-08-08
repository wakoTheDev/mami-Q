class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String author;
  final String authorTitle;
  final String category;
  final List<String> tags;
  final DateTime publishedDate;
  final String? imageUrl;
  final int estimatedReadTime;
  final List<String> sources;
  final List<String> relatedArticleIds;

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.author,
    required this.authorTitle,
    required this.category,
    required this.tags,
    required this.publishedDate,
    this.imageUrl,
    required this.estimatedReadTime,
    required this.sources,
    required this.relatedArticleIds,
  });
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'author': author,
      'authorTitle': authorTitle,
      'category': category,
      'tags': tags,
      'publishedDate': publishedDate.toIso8601String(),
      'imageUrl': imageUrl,
      'estimatedReadTime': estimatedReadTime,
      'sources': sources,
      'relatedArticleIds': relatedArticleIds,
    };
  }
  
  // Create from JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      author: json['author'],
      authorTitle: json['authorTitle'],
      category: json['category'],
      tags: List<String>.from(json['tags']),
      publishedDate: DateTime.parse(json['publishedDate']),
      imageUrl: json['imageUrl'],
      estimatedReadTime: json['estimatedReadTime'],
      sources: List<String>.from(json['sources']),
      relatedArticleIds: List<String>.from(json['relatedArticleIds']),
    );
  }
}
