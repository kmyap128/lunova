import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ----- Wardrobe Page -----
// displays a grid of clothing items
class PageWardrobe extends StatefulWidget {
  const PageWardrobe({super.key});

  @override
  State<PageWardrobe> createState() => _PageWardrobeState();
}

class _PageWardrobeState extends State<PageWardrobe>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dialogue box to display clothing item data
  void _showClothingDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Category: ${data['category']}'),
          content: Image.network(
            data['imageUrl'],
            fit: BoxFit.cover,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Widget to build grid displaying clothing items
  Widget _buildClothingGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('clothing_items')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No clothing items yet.'));
        }

        final docs = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            // ----- clothing item card -----
            return GestureDetector(
              onTap: () => _showClothingDialog(data),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    data['imageUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget to build the collage of clothing images on the outfit preview card
  Widget _buildOutfitPreview(List<String> itemIds) {
    if (itemIds.isEmpty) {
      return const Center(child: Text('No items'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('clothing_items')
          .where(FieldPath.documentId, whereIn: itemIds.take(4).toList())
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: items.length.clamp(0, 4),
          itemBuilder: (context, index) {
            final data = items[index].data() as Map<String, dynamic>;

            return Image.network(
              data['imageUrl'],
              fit: BoxFit.cover,
            );
          },
        );
      },
    );
  }

  // Widget to build the grid displaying outfits
  Widget _buildOutfitsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('outfits')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No outfits yet.'));
        }

        final outfits = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: outfits.length,
          itemBuilder: (context, index) {
            final outfit = outfits[index].data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                _showOutfitDialog(
                  context,
                  outfit['name'],
                  List<String>.from(outfit['itemIds']),
                );
              },
              // ----- outfit card -----
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    _buildOutfitPreview(List<String>.from(outfit['itemIds'])),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        color: Colors.black54,
                        child: Text(
                          outfit['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Dialogue box to display clothing items in an outfit
  void _showOutfitDialog(
    BuildContext context,
    String outfitName,
    List<String> itemIds,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(outfitName),
          content: SizedBox(
            width: double.maxFinite,
            // grab database snapshot
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clothing_items')
                  .where(FieldPath.documentId, whereIn: itemIds)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No items in this outfit.');
                }

                final items = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final data =
                        items[index].data() as Map<String, dynamic>;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data['imageUrl'],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ----- Build Wardrobe page content -----
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle Tabs
        TabBar(
          controller: _tabController,
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.indigo,
          // tab bar to switch between clothing and outfits screens
          tabs: const [
            Tab(text: 'Clothing'),
            Tab(text: 'Outfits'),
          ],
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildClothingGrid(),
              _buildOutfitsGrid(),
            ],
          ),
        ),
      ],
    );
  }
}
