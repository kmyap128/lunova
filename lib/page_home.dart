import 'package:flutter/material.dart';


// Home Page
// contains a dashboard overview outfit of the day and of 
// recently added outfits and clothing items
class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          // Outfit of the Day section
          Container(
            margin: const EdgeInsets.all(16),
            width: 350,
            height: 350,
            decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
            child: const Center(
              child: Text(
                'Outfit of the Day',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          // Recently Added Clothing Items section
          Text(
            'Recently Added Clothing Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Clothing Item'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Clothing Item'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Clothing Item'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Clothing Item'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // Recently Added Outfits section
          Text(
            'Recently Added Outfits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Outfit'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Outfit'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Outfit'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Outfit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}