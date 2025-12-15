import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



// ----- Home Page -----
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

          // ----- Outfit of the Day -----

          SizedBox(
            height: 350,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('outfits')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    // if there are no outfits added yet
                    child: const Center(
                      child: Text(
                        'No outfits yet',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }

                final outfits = snapshot.data!.docs;
                outfits.shuffle(); 
                final outfit = outfits.first;   // choose a random outfit to display as outfit of the day
                final data = outfit.data() as Map<String, dynamic>;

                // main container to display outfit
                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GestureDetector(
                    onTap: () => _showOutfitDialog(
                      context,
                      data['name'],
                      List<String>.from(data['itemIds']),
                    ),
                    child: _OutfitPreviewCard(
                      name: data['name'],
                      itemIds: List<String>.from(data['itemIds']),
                      large: true,
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 8),

          // ----- Recently Added Clothing Items -----

          Text(
            'Recently Added Clothing Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: StreamBuilder<QuerySnapshot>(
              // grab the 5 most recently added items
              stream: FirebaseFirestore.instance
                  .collection('clothing_items')
                  .orderBy('createdAt', descending: true)   
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No clothing items yet.'));
                }

                final docs = snapshot.data!.docs;

                // scrollable list of items
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    return Container(
                      margin: const EdgeInsets.all(8),
                      width: 150,
                      child: GestureDetector(
                        onTap: () => _showClothingDialog(context, data),
                        // clothing item card
                        child: Card(
                          elevation: 6,
                          shadowColor: Colors.black54,
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
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SizedBox(height: 8),

          // ----- Recently Added Outfits -----
          Text(
            'Recently Added Outfits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: StreamBuilder<QuerySnapshot>(
              // grab the 5 most recently added outfits
              stream: FirebaseFirestore.instance
                  .collection('outfits')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No outfits yet.'));
                }

                final outfits = snapshot.data!.docs;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: outfits.length,
                  itemBuilder: (context, index) {
                    final data = outfits[index].data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.all(8),
                      width: 150,
                      // Card to display outfit
                      child: GestureDetector(
                        onTap: () => _showOutfitDialog(
                          context,
                          data['name'],
                          List<String>.from(data['itemIds']),
                        ),
                        child: _OutfitPreviewCard(
                          name: data['name'],
                          itemIds: List<String>.from(data['itemIds']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Card container for an outfit
// displays a collage of clothing items in the outfit
class _OutfitPreviewCard extends StatelessWidget {
  final String name;
  final List<String> itemIds;
  final bool large;

  const _OutfitPreviewCard({
    required this.name,
    required this.itemIds,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _buildImageGrid(),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: large ? 18 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // builds the collage of clothing items displayed in the outfit preview card
  Widget _buildImageGrid() {
    if (itemIds.isEmpty) {
      return const Center(child: Text('No items'));
    }

    return StreamBuilder<QuerySnapshot>(
      // grab snapshot of clothing items in database at this point
      stream: FirebaseFirestore.instance
          .collection('clothing_items')
          .where(FieldPath.documentId,
              whereIn: itemIds.take(4).toList())
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          // make the grid have 2 columns
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: items.length.clamp(0, 4),    // limit to 4 items
          itemBuilder: (context, index) {
            final data =
                items[index].data() as Map<String, dynamic>;

            return Image.network(
              data['imageUrl'],
              fit: BoxFit.cover,
            );
          },
        );
      },
    );
  }
}

// dialogue box that shows up when you click on clothing item
void _showClothingDialog(BuildContext context, Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
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
    ),
  );
}

// dialogue box that shows up when you click on an outfit
void _showOutfitDialog(
  BuildContext context,
  String name,
  List<String> itemIds,
) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(name),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          // grab snapshot of database at this instance
          stream: FirebaseFirestore.instance
              .collection('clothing_items')
              .where(FieldPath.documentId, whereIn: itemIds)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data!.docs;

            // display grid of clothing items in this outfit
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
    ),
  );
}
