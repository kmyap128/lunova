import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'clothing_item.dart';

// ----- Add Page -----
// handles all app additions (clothing items, outfits, collections)
class PageAdd extends StatefulWidget {
  const PageAdd({super.key});

  @override
  State<PageAdd> createState() => _PageAddState();
}

class _PageAddState extends State<PageAdd> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _collectionNameController =
      TextEditingController();

  List<ClothingItem> allClothingItems = [];
  List<String> selectedItemIds = [];

  bool addingOutfit = false;

  // New collection
  bool createNewCollection = false;

  // Existing collection
  bool addToExistingCollection = false;
  String? selectedCollectionId;
  List<QueryDocumentSnapshot> collections = [];

  // Clothing categories
  final List<String> categories = [
    'tops',
    'bottoms',
    'dresses',
    'accessories',
    'jewelry',
    'shoes',
    'hats',
  ];
  String? selectedCategory;

  // selected image from gallery
  File? pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchClothingItems();
    fetchCollections();
  }

  // Fetch all clothing items from the database
  Future<void> fetchClothingItems() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('clothing_items').get();
    setState(() {
      allClothingItems = snapshot.docs
          .map((doc) => ClothingItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Fetch all collections from the database
  Future<void> fetchCollections() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('collections').get();
    setState(() {
      collections = snapshot.docs;
    });
  }

  // Add a new clothing item
  Future<void> addClothingItem(String category, String imageUrl) async {
    await FirebaseFirestore.instance.collection('clothing_items').add({
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.now(),
    });
    fetchClothingItems();   // fetch clothing items to update view in app
  }

  // Add a new outfit
  Future<String> addOutfit(String name, List<ClothingItem> items) async {
    final doc = await FirebaseFirestore.instance.collection('outfits').add({
      'name': name,
      'itemIds': items.map((item) => item.id).toList(),
      'createdAt': Timestamp.now(),
    });
    return doc.id;
  }

  // Add a new collection
  Future<void> addCollection(String name, String outfitId) async {
    await FirebaseFirestore.instance.collection('collections').add({
      'name': name,
      'outfitIds': [outfitId],
      'createdAt': Timestamp.now(),
    });
  }

  // Add an outfit to an existing collection
  Future<void> addOutfitToCollection(
      String collectionId, String outfitId) async {
    await FirebaseFirestore.instance
        .collection('collections')
        .doc(collectionId)
        .update({
      'outfitIds': FieldValue.arrayUnion([outfitId]),
    });
  }

  // pick an image using image picker
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  // upload the image to database
  Future<String> uploadImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance
        .ref()
        .child('clothing_images/$fileName.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();    // return a URL to access the image
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ----- Add page content -----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(addingOutfit ? "Add Outfit" : "Add Clothing Item")),
      body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ----- Name field (outfits) -----
              if (addingOutfit)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Outfit name"),
                ),
        
              const SizedBox(height: 16),
        
              // ----- Outfit mode -----
              if (addingOutfit)
                Expanded(
                  child: ListView(
                    // list all clothing items available with checkboxes
                    children: allClothingItems.map((item) {
                      final isSelected =
                          selectedItemIds.contains(item.id);
                      return ListTile(
                        leading: Image.network(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.category),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedItemIds.add(item.id);
                              } else {
                                selectedItemIds.remove(item.id);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                )
              else
                // add a new clothing item
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // dropdown to select item category
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Select category',
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val;
                        });
                      },
                    ),
                  ],
                ),
        
              const SizedBox(height: 16),
        
              // outfit addition button
              ElevatedButton(
                onPressed: () async {
                  if (addingOutfit) {
                    if (_nameController.text.trim().isEmpty) {
                      showError('Outfit name is required.');
                      return;
                    }

                    if (selectedItemIds.isEmpty) {
                      showError('Please select at least one clothing item.');
                      return;
                    }

        
                    final selectedItems = allClothingItems
                        .where((item) =>
                            selectedItemIds.contains(item.id))
                        .toList();
        
                    final outfitId =
                        await addOutfit(_nameController.text, selectedItems);

                    // create a new collection from the outfit being added
                    if (createNewCollection) {
                      if (_collectionNameController.text.trim().isEmpty) {
                        showError('Collection name is required.');
                        return;
                      }
                      await addCollection(
                        _collectionNameController.text,
                        outfitId,
                      );
                    }

                    // add the outfit to an existing collection
                    if (addToExistingCollection &&
                        selectedCollectionId != null) {
                      await addOutfitToCollection(
                        selectedCollectionId!,
                        outfitId,
                      );
                    }
                  } else {
                    if (pickedImage == null || selectedCategory == null) {
                      showError('Category and image are required.');
                      return;
                    }
                    final imageUrl = await uploadImage(pickedImage!);
                    await addClothingItem(selectedCategory!, imageUrl);
                  }

                  // display a confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        addingOutfit
                            ? 'Outfit added successfully!'
                            : 'Clothing item added successfully!',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
        
                  // Small delay so the SnackBar is visible
                  await Future.delayed(const Duration(milliseconds: 300));
        
                  Navigator.pop(context);
        
                },
                child:
                    Text("Add ${addingOutfit ? "Outfit" : "Clothing Item"}"),
              ),
        
              // ----- image picker -----
              if (!addingOutfit)
                Column(
                  children: [
                    if (pickedImage != null)
                      Image.file(
                        pickedImage!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: pickImage,
                    ),
                  ],
                ),
        
              TextButton(
                onPressed: () {
                  setState(() {
                    addingOutfit = !addingOutfit;
                    selectedItemIds.clear();
                    createNewCollection = false;
                    addToExistingCollection = false;
                  });
                },
                child: Text(addingOutfit
                    ? "Switch to Add Clothing Item"
                    : "Switch to Add Outfit"),
              ),
        
              // ----- collection options -----
              if (addingOutfit) ...[
                SwitchListTile(
                  title: const Text('Create new collection'),
                  value: createNewCollection,
                  onChanged: (val) {
                    setState(() {
                      createNewCollection = val;
                      if (val) addToExistingCollection = false;
                    });
                  },
                ),
        
                if (createNewCollection)
                  TextField(
                    controller: _collectionNameController,
                    decoration: const InputDecoration(
                      labelText: 'Collection name',
                    ),
                  ),
        
                SwitchListTile(
                  title: const Text('Add to existing collection'),
                  value: addToExistingCollection,
                  onChanged: (val) {
                    setState(() {
                      addToExistingCollection = val;
                      if (val) createNewCollection = false;
                    });
                  },
                ),
        
                if (addToExistingCollection)
                  DropdownButtonFormField<String>(
                    initialValue: selectedCollectionId,
                    decoration: const InputDecoration(
                      labelText: 'Select collection',
                    ),
                    // map current collections to dropdown items
                    items: collections.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(data['name']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCollectionId = val;
                      });
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
