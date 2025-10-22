class SearchItem {
  final String image;
  final String title;
  final List<String> symptoms;

  SearchItem({
    required this.image,
    required this.title,
    required this.symptoms,
  });

  factory SearchItem.fromMap(Map<String, dynamic> map) {
    return SearchItem(
      image: map['image'] ?? '',
      title: map['title'] ?? '',
      symptoms: List<String>.from(map['symptoms'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'title': title,
      'symptoms': symptoms,
    };
  }
}
