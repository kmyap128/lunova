import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({super.key});

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  int clothingCount = 0;
  int outfitCount = 0;
  int collectionCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    final clothingSnapshot =
        await FirebaseFirestore.instance.collection('clothing_items').get();
    final outfitSnapshot =
        await FirebaseFirestore.instance.collection('outfits').get();
    final collectionSnapshot =
        await FirebaseFirestore.instance.collection('collections').get();

    setState(() {
      clothingCount = clothingSnapshot.docs.length;
      outfitCount = outfitSnapshot.docs.length;
      collectionCount = collectionSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile icon
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo.shade100,
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Name
            const Text(
              'Jane Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Clothes', clothingCount),
                _buildStatCard('Outfits', outfitCount),
                _buildStatCard('Collections', collectionCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
