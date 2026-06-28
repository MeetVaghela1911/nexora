part of 'model_list_bloc.dart';

abstract class ModelListEvent extends Equatable {
  const ModelListEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends ModelListEvent {}

class RefreshCategories extends ModelListEvent {}

class SelectModel extends ModelListEvent {
  final String modelId;

  const SelectModel(this.modelId);

  @override
  List<Object> get props => [modelId];
}

class LoadSelectedModelFromStorage extends ModelListEvent {}