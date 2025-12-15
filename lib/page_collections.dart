import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'page_add.dart';

// ----- Collections Page -----
// displays collections of outfits
class PageCollections extends StatefulWidget {
  const PageCollections({super.key});

  @override
  State<PageCollections> createState() => _PageCollectionsState();
}

class _PageCollectionsState extends State<PageCollections> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      body: StreamBuilder<QuerySnapshot>(
        // grab database snapshot
        stream: FirebaseFirestore.instance
            .collection('collections')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No collections added yet.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final collections = snapshot.data!.docs;  // populate collections

          // display list of collections
          return ListView.builder(
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final data =
                  collections[index].data() as Map<String, dynamic>;

              // card to display collection
              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // display how many outfits are in the collection
                  subtitle: Text(
                    '${(data['outfitIds'] as List).length} outfits',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CollectionDetailPage(
                          collectionId: collections[index].id,
                          collectionName: data['name'],
                          outfitIds:
                              List<String>.from(data['outfitIds']),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// page to display collection items and info
// displays when clicking into a collection
class CollectionDetailPage extends StatelessWidget {
  final String collectionId;
  final String collectionName;
  final List<String> outfitIds;

  const CollectionDetailPage({
    super.key,
    required this.collectionId,
    required this.collectionName,
    required this.outfitIds,
  });

  @override
  Widget build(BuildContext context) {
    if (outfitIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(collectionName)),
        // display grid of outfits
        body: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 1,
          itemBuilder: (context, index) {
            // tile to add an outfit from the collections page
            // navigates to "Add page"
            return _AddOutfitTile(context);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(collectionName)),
      body: StreamBuilder<QuerySnapshot>(
        // grab database snapshot of outfits collection
        stream: FirebaseFirestore.instance
            .collection('outfits')
            .where(FieldPath.documentId, whereIn: outfitIds)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No outfits found.'));
          }

          final outfits = snapshot.data!.docs;  // populate outfits

          // build grid of outfits in the collection
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: outfits.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _AddOutfitTile(context);
              }

              final data =
                  outfits[index - 1].data() as Map<String, dynamic>;
              final itemIds = List<String>.from(data['itemIds']);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GestureDetector(
                  onTap: () {
                    // optionally, show outfit details here
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildOutfitPreview(itemIds),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          data['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // build the collage of images on outfit preview card
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

            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                data['imageUrl'],
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }

  // Widget tile to navigate to the Add page
  Widget _AddOutfitTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PageAdd(),
          ),
        );
      },
      child: Card(
        color: Colors.indigo.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 40),
              SizedBox(height: 8),
              Text(
                'Add Outfit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
