import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final List<Model> models;

  CategoryModel({required this.id, required this.name, required this.models});

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(id: id, name: data['name'] ?? '', models: []);
  }
}

class Model {
  final String id;
  final String name;
  final String description;
  final String apiModelName;
  final String useCase;
  final IconData icon;

  Model({
    required this.id,
    required this.name,
    required this.description,
    required this.apiModelName,
    required this.useCase,
    required this.icon,
  });

  factory Model.fromFirestore(String docId, Map<String, dynamic> data) {
    return Model(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      apiModelName: data['api_model_name'] ?? '',
      useCase: data['use_case'] ?? '',
      icon: _getIconData(data['name']?.toString().toLowerCase() ?? ''),
    );
  }

  static IconData _getIconData(String modelName) {
    if (modelName.contains('gpt')) {
      return Icons.auto_awesome;
    } else if (modelName.contains('claude')) {
      return Icons.brush;
    } else if (modelName.contains('gemini')) {
      return Icons.stars;
    } else {
      return Icons.smart_toy;
    }
  }
}
