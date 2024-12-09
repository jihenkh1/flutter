class Post {
  String? id;
  final String content;
  final List<String>? imageUrls;
  final String? profileImage;
  final String username;
  final int timestamp;
  final int likes;
  final List<String> comments;
  final String? pollQuestion;
  final List<String> pollOptions;
  int commentCount; // Add comment count field

  Post({
    this.id,
    required this.content,
    this.imageUrls,
    this.profileImage,
    required this.username,
    required this.timestamp,
    this.pollQuestion,
    this.pollOptions = const [],
    this.likes = 0, // Default value for likes
    List<String>? comments,
    this.commentCount = 0, // Default value for comment count
  }) : comments = comments ?? [];

  Map<String, dynamic> get map {
    return {
      'id': id,
      'content': content,
      'imageUrls': imageUrls ?? [],
      'username': username,
      'timestamp': timestamp,
      'likes': likes,
      'comments': comments,
      'pollQuestion': pollQuestion,
      'pollOptions': pollOptions,
      'commentCount': commentCount, // Include comment count in the map
    };
  }

  Post copyWith({
    String? content,
    List<String>? imageUrls,
    String? username,
    int? timestamp,
    int? likes,
    List<String>? comments,
    String? pollQuestion,
    List<String>? pollOptions,
    int? commentCount, // Include commentCount in copyWith
  }) {
    return Post(
      id: this.id,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      username: username ?? this.username,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      pollQuestion: pollQuestion ?? this.pollQuestion,
      pollOptions: pollOptions ?? this.pollOptions,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
