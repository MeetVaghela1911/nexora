// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class CategoryPage extends StatefulWidget {
//   const CategoryPage({super.key});
//
//   @override
//   State<CategoryPage> createState() => _CategoryPageState();
// }
//
// class _CategoryPageState extends State<CategoryPage> {
//   final _categoryController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _idController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _apiModelNameController = TextEditingController();
//   final _useCaseController = TextEditingController();
//
//   final _firestore = FirebaseFirestore.instance;
//
//   Future<void> _saveData() async {
//     try {
//       final categoryName = _categoryController.text.trim();
//       if (categoryName.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please enter category name")),
//         );
//         return;
//       }
//
//       // Path: admin/model_list/categories/{categoryId}/models/{modelId}
//       final categoryRef = _firestore
//           .collection("admin")
//           // .doc("model_list")
//           .doc("model_categories")
//           .collection(categoryName);
//
//       await categoryRef.add({
//         "name": _nameController.text.trim(),
//         "id": _idController.text.trim(),
//         "description": _descriptionController.text.trim(),
//         "api_model_name": _apiModelNameController.text.trim(),
//         "use_case": _useCaseController.text.trim(),
//         "created_at": FieldValue.serverTimestamp(),
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Model added successfully!")),
//       );
//
//       // Clear fields
//       // _nameController.clear();
//       // _idController.clear();
//       // _descriptionController.clear();
//       // _apiModelNameController.clear();
//       // _useCaseController.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Category & Model")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: _categoryController,
//                 decoration: const InputDecoration(
//                   labelText: "Category Name",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: "Model Name",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _idController,
//                 decoration: const InputDecoration(
//                   labelText: "Model ID",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: "Description",
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _apiModelNameController,
//                 decoration: const InputDecoration(
//                   labelText: "API Model Name",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _useCaseController,
//                 decoration: const InputDecoration(
//                   labelText: "Use Case",
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 2,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: _saveData,
//                 icon: const Icon(Icons.save),
//                 label: const Text("Save"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _categoryController = TextEditingController();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _apiModelNameController = TextEditingController();
  final _useCaseController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;

  // For dropdown
  String? _selectedCategory;
  List<String> _categories = [];
  bool _isActive = true; // Default active state

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load categories from the tracker
  Future<void> _loadCategories() async {
    try {
      final trackerDoc = await _firestore
          .collection("admin")
          .doc("model_categories")
          .get();

      if (trackerDoc.exists && trackerDoc.data() != null) {
        final data = trackerDoc.data()!;
        if (data.containsKey('model_categories_list')) {
          setState(() {
            _categories = List<String>.from(
              data['model_categories_list'] ?? [],
            );
          });
        }
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  // Add new category to the tracker
  Future<void> _addCategoryToTracker(String categoryName) async {
    try {
      final trackerRef = _firestore.collection("admin").doc("model_categories");

      await _firestore.runTransaction((transaction) async {
        final trackerDoc = await transaction.get(trackerRef);

        if (trackerDoc.exists) {
          // Update existing categories array
          final data = trackerDoc.data()!;
          List<dynamic> currentCategories = data['model_categories_list'] ?? [];

          if (!currentCategories.contains(categoryName)) {
            currentCategories.add(categoryName);
            transaction.update(trackerRef, {
              'model_categories_list': currentCategories,
              'last_updated': FieldValue.serverTimestamp(),
            });
          }
        } else {
          // Create new tracker document
          transaction.set(trackerRef, {
            'model_categories_list': [categoryName],
            'created_at': FieldValue.serverTimestamp(),
            'last_updated': FieldValue.serverTimestamp(),
          });
        }
      });

      // Refresh the categories list
      await _loadCategories();
    } catch (e) {
      print("Error adding category to tracker: $e");
      rethrow;
    }
  }

  Future<void> _saveData() async {
    try {
      // Use selected category from dropdown OR text input
      final categoryName = _selectedCategory ?? _categoryController.text.trim();

      if (categoryName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select or enter a category name"),
          ),
        );
        return;
      }

      // Validate required fields
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter model name")),
        );
        return;
      }

      // If it's a new category (entered in text field), add it to tracker
      if (_selectedCategory == null &&
          _categoryController.text.trim().isNotEmpty) {
        await _addCategoryToTracker(categoryName);
        // After adding new category, set it as selected
        setState(() {
          _selectedCategory = categoryName;
        });
      }

      // Save the model to the category subcollection
      final categoryRef = _firestore
          .collection("admin")
          .doc("model_categories")
          .collection(categoryName);

      await categoryRef.add({
        "name": _nameController.text.trim(),
        "id": _idController.text.trim(),
        "description": _descriptionController.text.trim(),
        "api_model_name": _apiModelNameController.text.trim(),
        "use_case": _useCaseController.text.trim(),
        "is_active": _isActive,
        "created_at": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Model '${_nameController.text.trim()}' added to '$categoryName' successfully!",
          ),
        ),
      );

      // Clear only model fields, keep category selection
      _nameController.clear();
      _idController.clear();
      _descriptionController.clear();
      _apiModelNameController.clear();
      _useCaseController.clear();
      setState(() {
        _isActive = true; // Reset to default
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Add a new category only (without model)
  Future<void> _addCategoryOnly() async {
    try {
      final categoryName = _categoryController.text.trim();
      if (categoryName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter category name")),
        );
        return;
      }

      await _addCategoryToTracker(categoryName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Category '$categoryName' added successfully!")),
      );

      _categoryController.clear();
      setState(() {
        _selectedCategory = categoryName;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding category: $e")));
    }
  }

  // Clear category selection
  void _clearCategorySelection() {
    setState(() {
      _selectedCategory = null;
      _categoryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Category & Model"),
        actions: [
          if (_selectedCategory != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearCategorySelection,
              tooltip: "Clear Category Selection",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Category Selection Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Category Selection",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selected Category Display (when a category is selected)
                      if (_selectedCategory != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Selected Category:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedCategory!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "You are adding a model to this category",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _clearCategorySelection,
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text("Change Category"),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          "Want to add a different category?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Dropdown for existing categories
                      if (_categories.isNotEmpty) ...[
                        DropdownButtonFormField<String>(
                          value: null, // Always start with no selection
                          decoration: const InputDecoration(
                            labelText: "Select Existing Category",
                            border: OutlineInputBorder(),
                            hintText: "Choose from existing categories",
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text("Select a category"),
                            ),
                            ..._categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCategory = newValue;
                                _categoryController.clear();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_selectedCategory == null)
                          const Center(
                            child: Text(
                              "OR",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],

                      // Text field for new category (only show if no category is selected)
                      if (_selectedCategory == null) ...[
                        TextField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            labelText: "Create New Category",
                            border: OutlineInputBorder(),
                            hintText: "Enter new category name",
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Add Category Only button
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _addCategoryOnly,
                                icon: const Icon(Icons.add),
                                label: const Text("Add Category Only"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Model Details Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Model Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedCategory != null) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                _selectedCategory!,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                            ),
                          ],
                        ],
                      ),
                      if (_selectedCategory == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Please select or create a category first",
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Model Name *",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: "Model ID",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _apiModelNameController,
                        decoration: const InputDecoration(
                          labelText: "API Model Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _useCaseController,
                        decoration: const InputDecoration(
                          labelText: "Use Case",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text("Is Active"),
                        subtitle: const Text(
                          "If disabled, this model will be hidden from users",
                        ),
                        value: _isActive,
                        onChanged: (bool value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed:
                            _selectedCategory != null ||
                                _categoryController.text.trim().isNotEmpty
                            ? _saveData
                            : null,
                        icon: const Icon(Icons.save),
                        label: const Text("Save Model"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Current Categories List
              if (_categories.isNotEmpty) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Available Categories",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Total: ${_categories.length} categories",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((category) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                  _categoryController.clear();
                                });
                              },
                              child: Chip(
                                label: Text(category),
                                backgroundColor: _selectedCategory == category
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.2)
                                    : null,
                                deleteIcon: const Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                ),
                                onDeleted: _selectedCategory == category
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedCategory = category;
                                          _categoryController.clear();
                                        });
                                      },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
