import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/story.dart';

class FullStoryPage extends StatelessWidget {
  final Story story;

  const FullStoryPage({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert the timestamp to DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(story.timestamp);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Full Story",
          style: TextStyle(
            color: Colors.white, // Change the color here
            fontWeight: FontWeight.bold, // Optional: Bold the text
            fontSize: 20, // Optional: Adjust the font size
          ),
        ),
      ),
      body: Container(
        color: Colors.black, // Set the background color of the entire page to black
        child: Column(
          children: [
            // Use an Expanded widget to make the image fill the available space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Add spacing around the image
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Apply rounded corners
                  child: Image.network(
                    story.mediaUrl, // Display the full image
                    fit: BoxFit.cover, // Ensure the image covers the available space
                    width: double.infinity, // Make the image as wide as the screen
                    height: double.infinity, // Make the image as tall as the available space
                  ),
                ),
              ),
            ),
            // Entire section with background color for username and timestamp
            Container(
              width: double.infinity, // Make the container span the full width
              color: Colors.black87, // Set the background color for the section
              padding: const EdgeInsets.all(16), // Add padding around the text
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.blue, // Change username text color
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Posted at ${DateFormat.yMMMd().add_jm().format(dateTime)}",
                    style: const TextStyle(
                      color: Colors.grey, // Change timestamp text color
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
