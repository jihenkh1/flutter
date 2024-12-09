import 'package:flutter/material.dart';
import 'package:social_media_application/pages/ad_editing.dart';
import 'package:social_media_application/pages/home_page.dart';

class AdCreation extends StatefulWidget {
  const AdCreation({super.key});

  @override
  State<AdCreation> createState() => _AdCreationState();
}

class _AdCreationState extends State<AdCreation> {

  String? selectedReason;

  // List of options for the reasons with subtext
  final List<Map<String, String>> reasons = [
    {
      'title': 'Brand Awareness',
      'subtitle': 'Increase visibility of your brand.'
    },
    {'title': 'Increase Sales', 'subtitle': 'Drive more sales with this ad.'},
    {
      'title': 'Promote Event',
      'subtitle': 'Let people know about your upcoming event.'
    },
    {'title': 'Grow Audience', 'subtitle': 'Expand your audience reach.'},
    {'title': 'Other', 'subtitle': 'Choose another goal for your promotion.'}
  ];

  void _showDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('More about this section'),
            content: Text(
                'This is going to be for our analytical benefits, the results here will not affect the availability of your ad.'),
          );
        });
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
                builder: (context) => HomePage(),
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
        actions: [
          IconButton(
            onPressed: _showDialog,
            icon: const Icon(Icons.info_rounded),
            color: Colors.white,
          )
        ],
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)))
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title of the section
            const Text(
              'Goals',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Subtitle under the title
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: Text(
                'What results would you like from this ad?',
                style: TextStyle(fontSize: 16),
              ),
            ),


            Expanded(
              child: ListView(
                children: reasons.map((reason) {
                  return RadioListTile<String>(
                    title:
                        Text(reason['title']!),
                    subtitle: Text(
                        reason['subtitle']!),
                    value: reason['title']!,
                    groupValue: selectedReason,
                    onChanged: (String? value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),


            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedReason == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a goal')),

                    );

                  } else {

                    print('Selected goal: $selectedReason');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdEditing(),
                      ),
                    );
                  }
                },
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
