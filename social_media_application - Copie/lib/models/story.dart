class Story {
  final String id;
  final String mediaUrl;
  final String username;
  final int timestamp; // Use int for timestamp
  bool isViewed; // Track if the story has been viewed
  final String? text; // Optional text overlay for the story

  Story({
    required this.id,
    required this.mediaUrl,
    required this.timestamp,
    required this.username,
    this.isViewed = false, // Default value for isViewed is false
    this.text,
  });

  // CopyWith method to support updates
  Story copyWith({
    String? id,
    String? mediaUrl,
    int? timestamp,
    String? username,
    bool? isViewed, // Include the isViewed property
    String? text,   // Include the text property
  }) {
    return Story(
      id: id ?? this.id,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timestamp: timestamp ?? this.timestamp,
      username: username ?? this.username,
      isViewed: isViewed ?? this.isViewed,
      text: text ?? this.text,
    );
  }

  // Convert Story to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mediaUrl': mediaUrl,
      'timestamp': timestamp,
      'username': username,
      'isViewed': isViewed,
      'text': text,
    };
  }

  // Create Story from a Map
  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      id: map['id'],
      mediaUrl: map['mediaUrl'],
      timestamp: map['timestamp'],
      username: map['username'],
      isViewed: map['isViewed'] ?? false,
      text: map['text'],
    );
  }
}
