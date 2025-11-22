import 'package:flutter/material.dart';
import 'package:hackifm/widgets/app_widgets.dart';

class OpportunityListScreen extends StatelessWidget {
  final String categoryName;

  const OpportunityListScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Dummy data for now
    final opportunities = List.generate(
      10,
      (index) => {
        'title': '$categoryName Opportunity ${index + 1}',
        'description':
            'This is a short description for the opportunity. More details will be available upon clicking.',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF05060A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: opportunities.length,
        itemBuilder: (context, index) {
          final opp = opportunities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            color: Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opp['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    opp['description']!,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        /* Placeholder for Apply/Enroll */
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: premiumPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        categoryName == 'Courses' ? 'Enroll Now' : 'Apply Now',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
