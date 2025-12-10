import 'package:flutter/material.dart';

// Wardrobe Page
// displays a grid of clothing items
class PageWardrobe extends StatefulWidget {
  const PageWardrobe({super.key});

  @override
  State<PageWardrobe> createState() => _PageWardrobeState();
}

class _PageWardrobeState extends State<PageWardrobe> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Grid of clothing items
        Expanded(
          child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            return Card(
              child: Center(
                child: Text('Item $index'),
              ),
            );
          },
          itemCount: 20,
        )
        ),
      ],
    );
  }
}