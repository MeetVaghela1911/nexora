part of 'model_list_bloc.dart';

abstract class ModelListState extends Equatable {
  const ModelListState();

  @override
  List<Object> get props => [];
}

class ModelListInitial extends ModelListState {}

class ModelListLoading extends ModelListState {}

class ModelListLoaded extends ModelListState {
  final List<CategoryGroup> categories;
  final String? selectedModelId;
  final bool isRefreshing;
  final String? error;

  const ModelListLoaded({
    required this.categories,
    this.selectedModelId,
    this.isRefreshing = false,
    this.error,
  });

  ModelListLoaded copyWith({
    List<CategoryGroup>? categories,
    String? selectedModelId,
    bool? isRefreshing,
    String? error,
  }) {
    return ModelListLoaded(
      categories: categories ?? this.categories,
      selectedModelId: selectedModelId ?? this.selectedModelId,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [
    categories,
    selectedModelId ?? '',
    isRefreshing,
    error ?? '',
  ];
}

class ModelListError extends ModelListState {
  final String message;

  const ModelListError(this.message);

  @override
  List<Object> get props => [message];
}

class CategoryGroup extends Equatable {
  final String categoryName;
  final List<Model> models;
  final String?
  originalCollectionName; // Store the original Firestore collection name

  const CategoryGroup({
    required this.categoryName,
    required this.models,
    this.originalCollectionName,
  });

  @override
  List<Object?> get props => [categoryName, models, originalCollectionName];
}

class Model extends Equatable {
  final String id;
  final String name;
  final String description;
  final String apiModelName;
  final String useCase;
  final IconData icon;
  final DateTime? createdAt;
  final String? category; // Store which category this model belongs to
  final bool isActive;

  const Model({
    required this.id,
    required this.name,
    required this.description,
    required this.apiModelName,
    required this.useCase,
    required this.icon,
    this.createdAt,
    this.category,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    apiModelName,
    useCase,
    icon,
    createdAt,
    category,
    isActive,
  ];
}
