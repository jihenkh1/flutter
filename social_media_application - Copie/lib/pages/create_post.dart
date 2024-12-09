import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:social_media_application/models/post.dart';

class CreatePost extends StatefulWidget {
  final Function(Post) onPostCreated;
  final String username;

  const CreatePost({
    Key? key,
    required this.onPostCreated,
    required this.username,
  }) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePost> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _pollQuestionController = TextEditingController();
  final TextEditingController _pollOptionController = TextEditingController();
  String? _errorMessage;
  List<File> _selectedMedia = [];
  List<String> _pollOptions = [];
  final ImagePicker _picker = ImagePicker();
  bool _isCreatingPoll = false;
  String? postId; // Variable to store the post ID

  Future<void> _pickMedia(ImageSource source) async {
    if (_selectedMedia.length >= 2) {
      setState(() {
        _errorMessage = "You can only upload 2 images.";
      });
      return;
    }

    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedMedia.add(File(pickedFile.path));
      });
    }
  }

  void _submitPost() async {
    if (_postController.text.isEmpty && _selectedMedia.isEmpty) {
      setState(() {
        _errorMessage = "Please write something or add media.";
      });
      return;
    }

    // List to hold uploaded image URLs
    List<String> imageUrls = [];

    // Generate a valid timestamp as an int for Firebase
    int timestamp = DateTime.now().millisecondsSinceEpoch; // Use int timestamp

    // Upload images to Firebase Storage and get URLs
    for (var file in _selectedMedia) {
      try {
        print("Uploading ${file.path}..."); // Log the file path
        final ref = FirebaseStorage.instance.ref().child(
            'posts/${widget.username}/$timestamp${file.uri.pathSegments.last}'); // Unique filename
        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();
        print("Uploaded to: $downloadUrl"); // Log the download URL
        imageUrls.add(downloadUrl);
      } catch (e) {
        setState(() {
          _errorMessage = "Error uploading images: $e"; // Display the error
        });
        print("Error uploading image: $e"); // Print the error to console
        return;
      }
    }

    // Reference to the Firebase Realtime Database "posts" node
    final DatabaseReference ref = FirebaseDatabase.instance.ref("posts").child(timestamp.toString()); // Ensure the key is a String

    // Construct the post data to be saved
    Map<String, dynamic> postData = {
      "content": _postController.text,
      "imageUrls": imageUrls, // Ensure this is set to the populated list
      "username": widget.username,
      "timestamp": timestamp, // Pass the timestamp as an int
      "pollQuestion": null,
      "pollOptions": [],
    };

    try {
      // Save the post data with the formatted timestamp
      await ref.set(postData);

      // Notify the parent widget with the created post object
      widget.onPostCreated(Post(
        id: timestamp.toString(), // Convert timestamp to String for post ID
        content: _postController.text,
        imageUrls: imageUrls,
        username: widget.username,
        timestamp: timestamp, // Pass timestamp as int
      ));

      Navigator.pop(context); // Close the CreatePost page
    } catch (e) {
      setState(() {
        _errorMessage = "Error saving post: $e"; // Error saving to Realtime Database
      });
      print("Error saving post: $e"); // Print the error to console
    }
  }




  void _addPollOption() {
    if (_pollOptionController.text.isNotEmpty) {
      setState(() {
        _pollOptions.add(_pollOptionController.text);
        _pollOptionController.clear();
      });
    }
  }

  // Method to delete the post using postId
  void _deletePost(String postId) async {
    try {
      // Delete the post from Firebase Realtime Database using the postId
      await FirebaseDatabase.instance.ref("posts/$postId").remove();
      print("Post deleted successfully");

      Navigator.pop(
          context); // Close the CreatePost page or navigate to another page
    } catch (e) {
      setState(() {
        _errorMessage = "Error deleting post: $e"; // Display the error
      });
      print("Error deleting post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.black,
        title: const Text('Create Post',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text(
              'Post',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue, // You can set a color as a placeholder
                  child: Text(
                    widget.username.isNotEmpty ? widget.username[0] : 'U', // Display first letter of the username
                    style: TextStyle(color: Colors.white), // Text style for the letter
                  ),
                ),

                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _postController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                      errorText: _errorMessage,
                    ),
                    style: const TextStyle(
                      fontSize: 18,  // Text size
                      color: Colors.white,  // Change text color
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedMedia.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedMedia.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.file(
                            _selectedMedia[index],
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedMedia.removeAt(index);
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            if (_isCreatingPoll) ...[
              TextField(
                controller: _pollQuestionController,
                decoration: const InputDecoration(
                  hintText: "Poll Question",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pollOptionController,
                decoration: const InputDecoration(
                  hintText: "Poll Option",
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: _addPollOption,
                child: const Text("Add Option"),
              ),
              const SizedBox(height: 10),
              Wrap(
                children: _pollOptions
                    .map((option) => Chip(label: Text(option)))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.blue),
                      onPressed: () => _pickMedia(ImageSource.gallery),
                    ),
                    IconButton(
                      icon: const Icon(Icons.poll, color: Colors.blue),
                      onPressed: () {
                        setState(() {
                          _isCreatingPoll = !_isCreatingPoll;
                        });
                      },
                    ),
                  ],
                ),
                const Icon(Icons.public, color: Colors.grey),
              ],
            ),
            // Button to delete the post
            if (postId != null)
              ElevatedButton(
                onPressed: () {
                  _deletePost(postId!); // Pass the postId to delete
                },
                child: const Text('Delete Post'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    _pollQuestionController.dispose();
    _pollOptionController.dispose();
    super.dispose();
  }
}
