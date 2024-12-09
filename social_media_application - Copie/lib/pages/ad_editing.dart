import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_application/pages/ad_creation.dart';

class AdEditing extends StatefulWidget {
  const AdEditing({super.key});

  @override
  State<AdEditing> createState() => _AdEditingState();
}

class _AdEditingState extends State<AdEditing> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future getImageGallery() async {
    final PickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    setState(() {
      if (PickedFile != null) {
        _image = File(PickedFile.path);
        //widget.imgUrl = null;
      } else {
        print("No image picked");
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      // AppBar with centered title
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdCreation(), // Navigate to Explore page
              ),
            );
          },
        ),
        title: const Text(
          'Ads',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
      ),

      // Body with input fields and button
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Ad Title Input
            const Text(
              'Ad Title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the title of your ad',
              ),
            ),

            const SizedBox(height: 20),

            // Ad Link Input
            const Text(
              'Ad Link',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the link for your ad',
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: InkWell(
                onTap: () {
                  getImageGallery();
                },
                child: Container(
                  height: 200,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                    child: _image != null
                        ? Image.file(
                            _image!.absolute,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Icon(Icons.add_photo_alternate_outlined),
                          )),
              ),
            ),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement your logic here when the user clicks on the button
                  final adTitle = _titleController.text;
                  final adLink = _linkController.text;

                  if (adTitle.isEmpty || adLink.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ad Title: $adTitle\nAd Link: $adLink'),
                      ),
                    );
                    // Add logic to save or proceed with the input
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[200],
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'Save Ad',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
