import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:social_media_application/models/story.dart';

class CreateStory extends StatefulWidget {
  final Function(Story) onStoryCreated;

  const CreateStory({Key? key, required this.onStoryCreated}) : super(key: key);

  @override
  _CreateStoryState createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedStoryMedia;
  String? _errorMessage;
  Offset _textPosition = Offset(50, 50);
  TextEditingController _textController = TextEditingController();
  TransformationController _imageController = TransformationController();

  Future<String> _uploadMediaToStorage(File mediaFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('stories/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(mediaFile);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload media");
    }
  }

  Future<void> _submitStory() async {
    if (_selectedStoryMedia == null) {
      setState(() {
        _errorMessage = "Please add an image to your story.";
      });
      return;
    }

    try {
      String mediaUrl = await _uploadMediaToStorage(_selectedStoryMedia!);

      DatabaseReference storyRef = FirebaseDatabase.instance.ref("stories").push();
      Story story = Story(
        id: storyRef.key!,
        mediaUrl: mediaUrl,
        username: 'swiftie',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await storyRef.set({
        "mediaUrl": story.mediaUrl,
        "username": story.username,
        "timestamp": story.timestamp,
      });

      widget.onStoryCreated(story);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story created successfully!')),
      );

      setState(() {
        _selectedStoryMedia = null;
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to create story. Please try again.";
      });
    }
  }

  Future<void> _pickMedia(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedStoryMedia = File(pickedFile.path);
      });
    } else {
      setState(() {
        _errorMessage = 'No image selected!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        title: const Text('Create Story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _submitStory,
            child: const Text(
              'Post',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: _selectedStoryMedia == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tap the camera or gallery to select a photo for your story.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.blue),
                    onPressed: () => _pickMedia(ImageSource.gallery),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.blue),
                    onPressed: () => _pickMedia(ImageSource.camera),
                  ),
                ],
              ),
            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none, // Prevent clipping of children
                  children: [
                    // Image with Independent Zooming and Panning, properly stretched to full screen
                    Positioned.fill(
                      child: InteractiveViewer(
                        transformationController: _imageController,
                        boundaryMargin: const EdgeInsets.all(double.infinity), // Allow free dragging beyond the screen
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: FittedBox(
                          fit: BoxFit.cover, // Ensures the image fills the entire screen
                          child: Image.file(
                            _selectedStoryMedia!,
                            fit: BoxFit.cover, // Ensures the image fills its parent
                          ),
                        ),
                      ),
                    ),
                    // Text Overlay (Independent of Image Dragging)
                    Positioned(
                      top: _textPosition.dy,
                      left: _textPosition.dx,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _textPosition = Offset(
                              _textPosition.dx + details.localPosition.dx,
                              _textPosition.dy + details.localPosition.dy,
                            );
                          });
                        },
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 32,
                          ),
                          child: TextField(
                            controller: _textController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText: "Add a text overlay to your story (optional)",
                              hintStyle: TextStyle(color: Colors.white, fontSize: 18),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.blue),
                      onPressed: () => _pickMedia(ImageSource.gallery),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      onPressed: () => _pickMedia(ImageSource.camera),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
