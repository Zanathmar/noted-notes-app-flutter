class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? category;
  final int? colorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.category,
    this.colorIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'],
      colorIndex: json['color_index'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'color_index': colorIndex,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}