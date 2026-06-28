// bloc/model_list_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/local_storage/LocalStorage.dart';

part 'model_list_event.dart';
part 'model_list_state.dart';

class ModelListBloc extends Bloc<ModelListEvent, ModelListState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ModelListBloc() : super(ModelListInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<SelectModel>(_onSelectModel);
    on<RefreshCategories>(_onRefreshCategories);
    on<LoadSelectedModelFromStorage>(_onLoadSelectedModelFromStorage);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<ModelListState> emit,
  ) async {
    emit(ModelListLoading());

    try {
      List<CategoryGroup> categoryGroups = await _fetchAllCategoriesAndModels();

      // Load the selected model ID from local storage
      final selectedModelId = await LocalStorage.getSelectedModelId();

      emit(
        ModelListLoaded(
          categories: categoryGroups,
          selectedModelId: selectedModelId,
        ),
      );
    } catch (e) {
      print("Error loading categories: $e");
      emit(ModelListError('Failed to load categories: $e'));
    }
  }

  Future<void> _onLoadSelectedModelFromStorage(
    LoadSelectedModelFromStorage event,
    Emitter<ModelListState> emit,
  ) async {
    if (state is ModelListLoaded) {
      final currentState = state as ModelListLoaded;
      final selectedModelId = await LocalStorage.getSelectedModelId();

      emit(currentState.copyWith(selectedModelId: selectedModelId));
    }
  }

  Future<void> _onRefreshCategories(
    RefreshCategories event,
    Emitter<ModelListState> emit,
  ) async {
    if (state is ModelListLoaded) {
      final currentState = state as ModelListLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    }

    try {
      List<CategoryGroup> categoryGroups = await _fetchAllCategoriesAndModels();

      // Preserve the current selection during refresh
      String? currentSelectedModelId;
      if (state is ModelListLoaded) {
        currentSelectedModelId = (state as ModelListLoaded).selectedModelId;
      }

      emit(
        ModelListLoaded(
          categories: categoryGroups,
          selectedModelId: currentSelectedModelId,
        ),
      );
    } catch (e) {
      print("Error refreshing categories: $e");
      // Keep the current state but show error
      if (state is ModelListLoaded) {
        final currentState = state as ModelListLoaded;
        emit(
          currentState.copyWith(
            isRefreshing: false,
            error: 'Failed to refresh categories: $e',
          ),
        );
      }
    }
  }

  Future<List<CategoryGroup>> _fetchAllCategoriesAndModels() async {
    try {
      // Get categories from the tracking document
      final categoriesTracker = await _firestore
          .collection("admin")
          .doc("model_categories")
          .get();

      // Log the complete categoriesTracker data
      print("=== CATEGORIES TRACKER DATA ===");
      print("Document exists: ${categoriesTracker.exists}");

      if (categoriesTracker.exists && categoriesTracker.data() != null) {
        final data = categoriesTracker.data()!;
        print("Document ID: ${categoriesTracker.id}");
        print("Document data: $data");

        // Log specific fields if they exist
        if (data.containsKey('model_categories_list')) {
          print(
            "model_categories_list field: ${data['model_categories_list']}",
          );
          print(
            "model_categories_list type: ${data['model_categories_list'].runtimeType}",
          );
          if (data['model_categories_list'] is List) {
            print(
              "Number of categories: ${(data['model_categories_list'] as List).length}",
            );
          }
        }

        // Log all fields for inspection
        data.forEach((key, value) {
          print("Field '$key': $value (type: ${value.runtimeType})");
        });
      } else {
        print("Document does not exist or has no data");
      }
      print("=== END CATEGORIES TRACKER DATA ===");

      List<String> categoryNames = [];

      if (categoriesTracker.exists && categoriesTracker.data() != null) {
        // Get categories from tracker - using model_categories_list now
        final data = categoriesTracker.data()!;
        categoryNames = List<String>.from(data['model_categories_list'] ?? []);

        // Log the parsed category names
        print("Parsed category names: $categoryNames");
        print("Number of categories found: ${categoryNames.length}");
      } else {
        // If no tracker exists, try common categories
        print("No tracker found, discovering categories...");
        categoryNames = await _discoverCategories();
        print("Discovered categories: $categoryNames");
      }

      // Fetch models for each category
      List<CategoryGroup> categoryGroups = [];

      for (final categoryName in categoryNames) {
        print("Fetching models for category: $categoryName");
        final models = await _fetchModelsForCategory(categoryName);
        print("Found ${models.length} models in category $categoryName");

        // Add category even if it has no models (so admin knows it exists)
        categoryGroups.add(
          CategoryGroup(
            categoryName: _formatCategoryName(categoryName),
            models: models,
            originalCollectionName:
                categoryName, // Store original name for reference
          ),
        );
      }

      // Sort categories alphabetically
      categoryGroups.sort((a, b) => a.categoryName.compareTo(b.categoryName));

      print("Total category groups created: ${categoryGroups.length}");

      // Log summary
      for (final group in categoryGroups) {
        print("${group.categoryName}: ${group.models.length} models");
      }

      return categoryGroups;
    } catch (e) {
      print("Error fetching categories (using fallback): $e");
      return [];
      // return _getFallbackCategories();
    }
  }

  List<CategoryGroup> _getFallbackCategories() {
    return [
      CategoryGroup(
        categoryName: 'OpenAI',
        originalCollectionName: 'gpt',
        models: [
          Model(
            id: 'gpt-4o',
            name: 'GPT-4o',
            description: 'Most advanced, multimodal flagship model',
            apiModelName: 'gpt-4o',
            useCase: 'Complex tasks, coding, creative writing',
            icon: Icons.auto_awesome,
            createdAt: DateTime.now(),
            category: 'gpt',
          ),
          Model(
            id: 'gpt-4o-mini',
            name: 'GPT-4o Mini',
            description: 'Affordable and intelligent',
            apiModelName: 'gpt-4o-mini',
            useCase: 'Fast responses, simple tasks',
            icon: Icons.flash_on,
            createdAt: DateTime.now(),
            category: 'gpt',
          ),
        ],
      ),
      CategoryGroup(
        categoryName: 'Anthropic',
        originalCollectionName: 'claude',
        models: [
          Model(
            id: 'claude-3-5-sonnet',
            name: 'Claude 3.5 Sonnet',
            description: 'Highly intelligent and fast',
            apiModelName: 'claude-3-5-sonnet-20240620',
            useCase: 'Reasoning, coding, nuance',
            icon: Icons.brush,
            createdAt: DateTime.now(),
            category: 'claude',
          ),
        ],
      ),
      CategoryGroup(
        categoryName: 'Google',
        originalCollectionName: 'gemini',
        models: [
          Model(
            id: 'gemini-1.5-pro',
            name: 'Gemini 1.5 Pro',
            description: 'Mid-size multimodal model',
            apiModelName: 'gemini-1.5-pro',
            useCase: 'General purpose, long context',
            icon: Icons.stars,
            createdAt: DateTime.now(),
            category: 'gemini',
          ),
          Model(
            id: 'gemini-1.5-flash',
            name: 'Gemini 1.5 Flash',
            description: 'Fast and versatile',
            apiModelName: 'gemini-1.5-flash',
            useCase: 'High speed, low latency',
            icon: Icons.flash_on,
            createdAt: DateTime.now(),
            category: 'gemini',
          ),
        ],
      ),
      CategoryGroup(
        categoryName: 'Nvidia',
        originalCollectionName: 'nvidia',
        models: [
          Model(
            id: 'nvidia-llama-3-1-nemotron-70b-instruct',
            name: 'Nvidia Llama 3.1 Nemotron 70b Instruct',
            description: 'Nvidia Llama 3.1 Nemotron 70b Instruct',
            apiModelName: 'nvidia/llama-3.1-nemotron-70b-instruct',
            useCase: 'General purpose, long context',
            icon: Icons.stars,
            createdAt: DateTime.now(),
            category: 'nvidia',
          ),
        ],
      ),
    ];
  }

  // Keep the original _fetchAllCategoriesAndModels logic as part of the try block mostly
  // But since I'm replacing the whole block, I don't need to redeclare it.
  // The above ReplacementContent includes the method signature and body.
  // Wait, I strictly followed the tool instructions.
  // The tool replaces a block. I will target the method start to the return.

  Future<List<String>> _discoverCategories() async {
    // Try to discover categories by checking common names
    final possibleCategories = [
      'gpt',
      'claude',
      'gemini',
      'language',
      'vision',
      'audio',
      'multimodal',
      'text',
      'image',
    ];
    List<String> foundCategories = [];

    for (final category in possibleCategories) {
      try {
        final snapshot = await _firestore
            .collection("admin")
            .doc("model_categories")
            .collection(category)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          foundCategories.add(category);
          print("Discovered category: $category");
        }
      } catch (e) {
        // Collection might not exist, continue to next
        continue;
      }
    }

    return foundCategories;
  }

  Future<List<Model>> _fetchModelsForCategory(String categoryName) async {
    try {
      final modelsSnapshot = await _firestore
          .collection("admin")
          .doc("model_categories")
          .collection(categoryName)
          .orderBy('name') // Sort models by name
          .get();

      return modelsSnapshot.docs
          .map((modelDoc) {
            final data = modelDoc.data();
            return Model(
              id: modelDoc.id,
              name: data['name'] ?? 'Unnamed Model',
              description: data['description'] ?? 'No description',
              apiModelName: data['api_model_name'] ?? '',
              useCase: data['use_case'] ?? '',
              icon: _getIconForCategory(categoryName),
              createdAt: data['created_at'] != null
                  ? (data['created_at'] as Timestamp).toDate()
                  : DateTime.now(),
              // Store the original category name for reference
              category: categoryName,
              isActive: data['is_active'] ?? true,
            );
          })
          .where((model) => model.isActive)
          .toList();
    } catch (e) {
      print("Error fetching models for category $categoryName: $e");
      return [];
    }
  }

  IconData _getIconForCategory(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('gpt')) {
      return Icons.auto_awesome;
    } else if (lowerName.contains('claude')) {
      return Icons.brush;
    } else if (lowerName.contains('gemini')) {
      return Icons.stars;
    } else if (lowerName.contains('vision') || lowerName.contains('image')) {
      return Icons.visibility;
    } else if (lowerName.contains('audio')) {
      return Icons.audiotrack;
    } else if (lowerName.contains('language') || lowerName.contains('text')) {
      return Icons.text_fields;
    } else if (lowerName.contains('multimodal')) {
      return Icons.view_in_ar;
    } else {
      return Icons.smart_toy;
    }
  }

  void _onSelectModel(SelectModel event, Emitter<ModelListState> emit) async {
    if (state is ModelListLoaded) {
      final currentState = state as ModelListLoaded;

      // Toggle selection: if same model is clicked again, deselect it
      final newSelectedModelId = currentState.selectedModelId == event.modelId
          ? null
          : event.modelId;

      // If a model is selected, save it to local storage
      if (newSelectedModelId != null) {
        final selectedModel = _findModelById(
          newSelectedModelId,
          currentState.categories,
        );
        if (selectedModel != null) {
          await LocalStorage.setSelectedModel(
            id: selectedModel.id,
            name: selectedModel.name,
            description: selectedModel.description,
            apiModelName: selectedModel.apiModelName,
            useCase: selectedModel.useCase,
            category: selectedModel.category ?? '',
          );
        }
      } else {
        // If deselected, clear from local storage
        await LocalStorage.clearSelectedModel();
      }

      emit(currentState.copyWith(selectedModelId: newSelectedModelId));
    }
  }

  String _formatCategoryName(String collectionName) {
    return collectionName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // Helper method to find model by ID in categories
  Model? _findModelById(String modelId, List<CategoryGroup> categories) {
    for (final category in categories) {
      for (final model in category.models) {
        if (model.id == modelId) {
          return model;
        }
      }
    }
    return null;
  }

  // Helper method to get a specific model by ID
  Model? getModelById(String modelId) {
    if (state is ModelListLoaded) {
      final currentState = state as ModelListLoaded;
      return _findModelById(modelId, currentState.categories);
    }
    return null;
  }

  // Helper method to get models by category
  List<Model> getModelsByCategory(String categoryName) {
    if (state is ModelListLoaded) {
      final currentState = state as ModelListLoaded;
      final category = currentState.categories.firstWhere(
        (cat) =>
            cat.originalCollectionName == categoryName ||
            cat.categoryName == categoryName,
        orElse: () => CategoryGroup(categoryName: '', models: []),
      );
      return category.models;
    }
    return [];
  }

  // Method to check if a model is currently selected
  bool isModelSelected(String modelId) {
    if (state is ModelListLoaded) {
      return (state as ModelListLoaded).selectedModelId == modelId;
    }
    return false;
  }

  // Method to get currently selected model
  Model? getSelectedModel() {
    if (state is ModelListLoaded) {
      final currentState = state as ModelListLoaded;
      if (currentState.selectedModelId != null) {
        return _findModelById(
          currentState.selectedModelId!,
          currentState.categories,
        );
      }
    }
    return null;
  }
}
