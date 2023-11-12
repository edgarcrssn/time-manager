import 'package:flutter/material.dart';

class FAQWidget extends StatefulWidget {
  const FAQWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FAQWidgetState createState() => _FAQWidgetState();
}

class _FAQWidgetState extends State<FAQWidget> {
  List<Map<String, dynamic>> questions = [
    {
      'question': 'Do we need to clock in during lunch break?',
      'answer': 'Indeed, it is imperative to clock in during the lunch break.',
      'show': false,
    },
    {
      'question': 'Do we need to clock in during commutes within our working hours?',
      'answer': 'No, commutes made during your working hours are counted as working hours.',
      'show': false,
    },
    {
      'question': 'I don’t have a computer, how do I clock in?',
      'answer': 'Our application is available online. Thus, you can easily access it from a mobile device.',
      'show': false,
    },
    {
      'question': 'Who can access my professional data?',
      'answer': 'Only the administrators and your supervisors have the privilege to access your professional information.',
      'show': false,
    },
    {
      'question': 'How do I clock in using the application?',
      'answer': 'You simply log in using the credentials we provide to you via email. After this step, click on the "Clock-In" button when you start your work, and press it again to end your work period.',
      'show': false,
    },
    {
      'question': 'Are overtime hours accounted for?',
      'answer': 'Yes, overtime hours are duly accounted for. They are clearly displayed in the app and are compensated at twice the standard hourly rate.',
      'show': false,
    },
    {
      'question': 'Are daytime and nighttime working hours differentiated?',
      'answer': 'Indeed, hours worked during the day and night are treated differently. Moreover, the hourly rate is adjusted based on these periods. Please note that hours worked between 9:00 pm and 6:00 am are compensated at a rate 1.5 times higher than those worked during the day.',
      'show': false,
    },
    {
      'question': 'I am visually impaired, how do I use the application?',
      'answer': 'We have considered the needs of all our users. Thus, our application has been optimized to be accessible to visually impaired individuals.',
      'show': false,
    },
    {
      'question': 'Can I manage my leave and sick days directly on the app?',
      'answer': "For now, the app doesn't allow that, but the feature should be released in 2024.",
      'show': false,
    },
    {
      'question': 'I forgot to check in on the last day of the month, what should I do?',
      'answer': 'You can create, modify, and delete your working hours whenever you can. To avoid this, you can actually schedule your worked hours in advance.',
      'show': false,
    },
  ];

  void toggle(int index) {
    setState(() {
      questions[index]['show'] = !questions[index]['show'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext scaffoldContext) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: questions.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ExpansionTile(
                            title: Text(
                              questions[index]['question'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onExpansionChanged: (bool expanded) {
                              toggle(index);
                            },
                            initiallyExpanded: questions[index]['show'],
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  questions[index]['answer'],
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}