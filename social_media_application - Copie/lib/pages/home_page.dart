import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_media_application/models/story.dart';
import 'package:social_media_application/models/post.dart';
import 'package:social_media_application/pages/create_post.dart';
import 'package:social_media_application/pages/create_story.dart';
import 'Full_Story_Page.dart';
import 'menu_drawer.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Story> _stories = [];
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _fetchStories();

  }

  Future<void> _fetchPosts() async {
    final postRef = FirebaseDatabase.instance.ref("posts");
    postRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Post> fetchedPosts = data.entries.map((entry) {
          final value = entry.value;
          List<String> comments = List<String>.from(value['comments'] ?? []);
          return Post(
            id: entry.key,  // Add the post ID here
            content: value['content'],
            imageUrls: List<String>.from(value['imageUrls'] ?? []),
            username: value['username'],
            timestamp: value['timestamp'],
            pollQuestion: value['pollQuestion'],
            pollOptions: List<String>.from(value['pollOptions'] ?? []),
            likes: value['likes'] ?? 0,
            commentCount: comments.length,// Ensure likes field exists
          );
        }).toList();
        setState(() => _posts = fetchedPosts);
      }
    });
  }


  Future<void> _fetchStories() async {
    final storyRef = FirebaseDatabase.instance.ref("stories");
    storyRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Story> fetchedStories = data.entries.map((entry) {
          final value = entry.value;
          return Story(
            mediaUrl: value['mediaUrl'],
            username: value['username'],
            timestamp: value['timestamp'],
            id: entry.key,
          );
        }).toList();

        print("Fetched stories count: ${fetchedStories.length}");
        setState(() => _stories = fetchedStories);
      } else {
        print("No stories found in the database.");
      }
    }, onError: (error) {
      print("Failed to fetch stories: $error");
    });
  }

  Future<String> _uploadImage(File imageFile, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      throw Exception("Failed to upload image");
    }
  }

  Future<void> _handleStoryCreated(Story story) async {
    try {
      String imageUrl = await _uploadImage(
        File(story.mediaUrl),
        'stories/${story.username}/${DateTime.now().toIso8601String()}',
      );

      final storyRef = FirebaseDatabase.instance.ref("stories").push();
      await storyRef.set({
        "mediaUrl": imageUrl,
        "username": story.username,
        "timestamp": DateTime.now().toIso8601String(),
      });

      // Add story with new imageUrl directly in UI
      setState(() {
        _stories.insert(0, story.copyWith(mediaUrl: imageUrl));
      });
    } catch (e) {
      print("Failed to create story: $e");
    }
  }

  Future<void> _handlePostCreated(Post post) async {
    try {
      List<String> imageUrls = [];
      for (var filePath in post.imageUrls ?? []) {
        String imageUrl = await _uploadImage(
          File(filePath),
          'posts/${post.username}/${DateTime.now().toIso8601String()}',
        );
        imageUrls.add(imageUrl);
      }

      final postRef = FirebaseDatabase.instance.ref("posts").push();
      await postRef.set({
        "content": post.content,
        "imageUrls": imageUrls,

        "username": post.username,
        "timestamp": DateTime.now().toIso8601String(),
      });

      setState(() => _posts.insert(0, post.copyWith(imageUrls: imageUrls)));
    } catch (e) {
      print("Failed to create post: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _navigateToCreatePost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePost(
          onPostCreated: _handlePostCreated,
          username: 'swiftie',
        ),
      ),
    );
  }
  Future<void> _likePost(Post post) async {
    if (post.id == null) {
      print("Error: Post ID is null");
      return; // Exit the method early if the post ID is null
    }

    final postRef = FirebaseDatabase.instance.ref("posts").child(post.id!); // post.id should never be null here now
    final currentLikes = post.likes;
    final newLikes = currentLikes + 1;

    try {
      // Update the like count in the database
      await postRef.update({
        'likes': newLikes, // Update likes count
      });

      // Update the UI locally by modifying the local post list
      setState(() {
        // Replace the old post with a new post with updated likes
        _posts = _posts.map((p) {
          if (p.id == post.id) {
            return p.copyWith(likes: newLikes); // Create a copy with updated likes
          }
          return p;
        }).toList();
      });
    } catch (e) {
      print("Error liking post: $e");
    }
  }



// Helper method to update the post in your local list
  void _updatePostInList(Post updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      setState(() {
        _posts[index] = updatedPost; // Replace the post in the list
      });
    }
  }


  void _commentOnPost(Post post) async {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController commentController = TextEditingController();
        return AlertDialog(
          title: Text("Comment on ${post.username}'s post"),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: "Enter your comment"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String comment = commentController.text.trim();
                if (comment.isNotEmpty) {
                  try {
                    final postRef = FirebaseDatabase.instance.ref("posts").child(post.id!);

                    // Fetch the existing comments list
                    final snapshot = await postRef.child('comments').get();
                    List<String> existingComments = [];
                    if (snapshot.exists) {
                      existingComments = List<String>.from(snapshot.value as List);
                    }

                    // Append the new comment to the list
                    existingComments.add(comment);

                    // Update the post with the new comments list
                    await postRef.update({
                      'comments': existingComments,
                    });

                    // Optionally update the UI to reflect the new comment
                    setState(() {
                      post.comments.add(comment); // Add the comment locally
                    });

                    Navigator.pop(context); // Close the dialog
                  } catch (e) {
                    print("Error commenting on post: $e");
                  }
                }
              },
              child: Text("Post Comment"),
            ),
          ],
        );
      },
    );
  }

  void _sharePost(Post post) {
    // Implement sharing logic, e.g., using share package
    Share.share('Check out this post by ${post.username}: ${post.content}');
  }

  void _deletePost(Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: const Text("This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                try {
                  final postRef = FirebaseDatabase.instance
                      .ref("posts")
                      .child(post.timestamp.toString());
                  await postRef.remove();
                  print("Post deleted by ${post.username}");

                  setState(() {
                    _posts.remove(post);
                  });
                  Navigator.of(context)
                      .pop(); // Close the dialog after deletion
                } catch (e) {
                  print("Failed to delete post: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Connectivity',  // The text you want in the AppBar
          style: TextStyle(
            fontSize: 24,  // Font size
            fontWeight: FontWeight.bold,  // Font weight
            color: Colors.white,  // Text color
          ),
        ),
        centerTitle: true,
      ),
      drawer: MenuDrawer(),
      body: Column(
        children: [
          // Stories Section
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _stories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateStory(onStoryCreated: _handleStoryCreated),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: const Center(
                          child:
                              Icon(Icons.add, size: 40, color: Colors.black)),
                    ),
                  );
                } else {
                  return StoryWidget(story: _stories[index - 1]);
                }
              },
            ),
          ),
          const Divider(),
          // Posts Section
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return PostCard(
                  post: post,
                  onLike: () => _likePost(post),
                  onComment: () => _commentOnPost(post),
                  onShare: () => _sharePost(post),
                  onDelete: () => _deletePost(post),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.blueAccent,
        color: Colors.transparent,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 26, color: Colors.white),
          Icon(Icons.message, size: 26, color: Colors.white),
          Icon(Icons.add, size: 26, color: Colors.white),
          Icon(Icons.notifications, size: 26, color: Colors.white),
          Icon(Icons.person, size: 26, color: Colors.white),
        ],
        onTap: (index) {
          if (index == 2) {
            // Index for the "add" icon
            _navigateToCreatePost(); // Navigate to the create post page
          } else {
            setState(() {
              _selectedIndex =
                  index; // Update the selected index for other icons
            });
          }
        },
      ),
    );


  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike; // Callback for like button
  final VoidCallback onComment; // Callback for comment button
  final VoidCallback onShare; // Callback for share button
  final VoidCallback onDelete; // Callback for delete button

  const PostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onDelete,
  }) : super(key: key);

  //format timestamp
  String _formatTimestamp(dynamic timestamp) {
    DateTime dateTime;
    if (timestamp is int) {
      // Convert the Unix timestamp to DateTime
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      // If it's a string (ISO 8601 format), parse it
      try {
        dateTime = DateTime.parse(timestamp);
      } catch (e) {
        return 'Invalid date'; // Handle parsing error
      }
    } else {
      return 'Invalid date'; // Handle unexpected types
    }

    // Return formatted date using DateFormat
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  // Function to show all comments in a dialog
  void _showCommentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Comments on ${post.username}'s post"),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: 400, // Limit the height of the content area
            ),
            child: ListView.builder(
              itemCount: post.comments.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    post.comments[index],
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.username,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(_formatTimestamp(post.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (post.content.isNotEmpty)
              Text(post.content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            // Image Section with Improved Layout
            if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
              _buildImageSection(post.imageUrls!),

            // Action Buttons
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: onLike,
                ),
                Text('${post.likes} likes'),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: onComment,
                ),
                GestureDetector(
                  onTap: () => _showCommentsDialog(context), // Show comments on text tap
                  child: Text(
                    '${post.commentCount} comments',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: onShare,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),

            // Display comments
            const SizedBox(height: 10),
            for (var comment in post.comments)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  comment,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(List<String> imageUrls) {
    if (imageUrls.length == 1) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: NetworkImage(imageUrls[0]),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (imageUrls.length == 2) {
      return Row(
        children: imageUrls.map((url) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 4.0),
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }
    return SizedBox.shrink();
  }
}


class StoryWidget extends StatelessWidget {
  final Story story;

  const StoryWidget({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the full story screen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullStoryPage(story: story), // Full story page
          ),
        );

        // Mark the story as viewed when the user taps on it
        story.isViewed = true; // Update the isViewed property
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(story.mediaUrl), // Display the story image
            fit: BoxFit.cover,
          ),
          // Add the circular border if the story is unviewed
          border: Border.all(
            color: story.isViewed ? Colors.transparent : Colors.blue, // blue border for unviewed
            width: 3, // Adjust the width as needed
          ),
        ),
      ),
    );
  }
}

