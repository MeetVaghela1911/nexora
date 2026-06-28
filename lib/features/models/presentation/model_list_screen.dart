// import 'package:flutter/material.dart';
//
//
// class ModelListScreen extends StatefulWidget {
//   const ModelListScreen({super.key});
//
//   @override
//   State<ModelListScreen> createState() => _ModelListScreenState();
// }
//
// class _ModelListScreenState extends State<ModelListScreen> {
//   String? _selectedModelId;
//
//   // For now static mock data (replace with API call)
//   final List<Map<String, dynamic>> _modelsData = [
//     {
//       "group": "GPT",
//       "models": [
//         {
//           "id": "gpt-4",
//           "name": "GPT-4",
//           "desc": "Advanced reasoning and problem-solving.",
//           "icon": Icons.auto_awesome
//         },
//         {
//           "id": "gpt-3.5",
//           "name": "GPT-3.5",
//           "desc": "Balanced performance and speed.",
//           "icon": Icons.flash_on
//         },
//       ]
//     },
//     {
//       "group": "Claude",
//       "models": [
//         {
//           "id": "claude-3",
//           "name": "Claude 3",
//           "desc": "Creative writing and text generation.",
//           "icon": Icons.brush
//         },
//         {
//           "id": "claude-2",
//           "name": "Claude 2",
//           "desc": "Excels at long-form content.",
//           "icon": Icons.menu_book
//         },
//       ]
//     },
//     {
//       "group": "Gemini",
//       "models": [
//         {
//           "id": "gemini-pro",
//           "name": "Gemini Pro",
//           "desc": "Fast, efficient, and versatile.",
//           "icon": Icons.stars
//         },
//         {
//           "id": "gemini-1.5",
//           "name": "Gemini 1.5",
//           "desc": "Advanced multimodal capabilities.",
//           "icon": Icons.smart_toy
//         },
//       ]
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Models"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: _modelsData.length,
//         itemBuilder: (context, groupIndex) {
//           final group = _modelsData[groupIndex];
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 group["group"],
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               ...List.generate(group["models"].length, (modelIndex) {
//                 final model = group["models"][modelIndex];
//                 final isSelected = _selectedModelId == model["id"];
//
//                 return Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   elevation: 0,
//                   color: Colors.white,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           backgroundColor: Colors.grey.shade100,
//                           child: Icon(model["icon"], color: Colors.black),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 model["name"],
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 model["desc"],
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         OutlinedButton(
//                           onPressed: () {
//                             setState(() {
//                               _selectedModelId = model["id"];
//                             });
//                           },
//                           style: OutlinedButton.styleFrom(
//                             backgroundColor: isSelected
//                                 ? Colors.black
//                                 : Colors.grey.shade100,
//                             foregroundColor:
//                             isSelected ? Colors.white : Colors.black,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 12,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: Text(isSelected ? "Selected" : "Select"),
//                         )
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//               const SizedBox(height: 16),
//             ],
//           );
//         },
//       ),
//       backgroundColor: Colors.grey.shade50,
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../core/local_storage/LocalStorage.dart';
// import '../bloc/model_list_bloc.dart';
//
// class ModelListScreen extends StatefulWidget {
//   const ModelListScreen({super.key});
//
//   @override
//   State<ModelListScreen> createState() => _ModelListScreenState();
// }
//
// class _ModelListScreenState extends State<ModelListScreen> {
//   String? _previouslySelectedModelId;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPreviouslySelectedModel();
//     // Load categories when screen initializes
//     context.read<ModelListBloc>().add(LoadCategories());
//   }
//
//   Future<void> _loadPreviouslySelectedModel() async {
//     final selectedModelId = await LocalStorage.getSelectedModelId();
//     if (selectedModelId != null) {
//       setState(() {
//         _previouslySelectedModelId = selectedModelId;
//       });
//       // Set the selected model in BLoC
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         context.read<ModelListBloc>().add(SelectModel(selectedModelId));
//       });
//     }
//   }
//
//   Future<void> _saveSelectedModelToLocalStorage(Model model) async {
//     await LocalStorage.setSelectedModel(
//       id: model.id,
//       name: model.name,
//       description: model.description,
//       apiModelName: model.apiModelName,
//       useCase: model.useCase,
//       category: model.category ?? '',
//     );
//   }
//
//   void _showModelSelectedSnackbar(String modelName) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$modelName selected successfully!'),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           title: const Text("Models"),
//           elevation: 0,
//           backgroundColor: Colors.grey[100],
//           surfaceTintColor: Colors.grey[100],
//           foregroundColor: Colors.black,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () {
//                 context.read<ModelListBloc>().add(LoadCategories());
//               },
//             ),
//           ],
//         ),
//         body: BlocListener<ModelListBloc, ModelListState>(
//           listener: (context, state) {
//             if (state is ModelListLoaded && state.selectedModelId != null) {
//               // When a model is selected, find it and save to local storage
//               final selectedModel = _findModelById(state.selectedModelId!, state.categories);
//               if (selectedModel != null) {
//                 _saveSelectedModelToLocalStorage(selectedModel);
//                 _showModelSelectedSnackbar(selectedModel.name);
//               }
//             }
//           },
//           child: BlocBuilder<ModelListBloc, ModelListState>(
//             builder: (context, state) {
//               if (state is ModelListLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (state is ModelListError) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Error: ${state.message}',
//                         style: const TextStyle(color: Colors.red),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           context.read<ModelListBloc>().add(LoadCategories());
//                         },
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               if (state is ModelListLoaded) {
//                 final categories = state.categories;
//
//                 if (categories.isEmpty) {
//                   return const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
//                         SizedBox(height: 16),
//                         Text(
//                           'No models found',
//                           style: TextStyle(fontSize: 18, color: Colors.grey),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           'Add models using the Category Page',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: categories.length,
//                   itemBuilder: (context, groupIndex) {
//                     final group = categories[groupIndex];
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           group.categoryName,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ...List.generate(group.models.length, (modelIndex) {
//                           final model = group.models[modelIndex];
//                           final isSelected = state.selectedModelId == model.id;
//
//                           return Card(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             elevation: 0,
//                             color: Colors.white,
//                             child: Padding(
//                               padding: const EdgeInsets.all(12),
//                               child: Row(
//                                 children: [
//                                   CircleAvatar(
//                                     backgroundColor: Colors.grey.shade100,
//                                     child: Icon(model.icon, color: Colors.black),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           model.name,
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           model.description,
//                                           maxLines: 2,
//                                           style: TextStyle(
//                                             fontSize: 13,
//                                             color: Colors.grey.shade600,
//                                           ),
//                                         ),
//                                         if (model.useCase.isNotEmpty) ...[
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             'Use Case: ${model.useCase}',
//                                             maxLines: 2,
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.grey.shade500,
//                                               fontStyle: FontStyle.italic,
//                                             ),
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   OutlinedButton(
//                                     onPressed: () {
//                                       context.read<ModelListBloc>().add(
//                                         SelectModel(model.id),
//                                       );
//                                     },
//                                     style: OutlinedButton.styleFrom(
//                                       backgroundColor: isSelected
//                                           ? Colors.black
//                                           : Colors.grey.shade100,
//                                       foregroundColor: isSelected
//                                           ? Colors.white
//                                           : Colors.black,
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 20,
//                                         vertical: 12,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                     ),
//                                     child: Text(isSelected ? "Selected" : "Select"),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           );
//                         }),
//                         const SizedBox(height: 16),
//                       ],
//                     );
//                   },
//                 );
//               }
//
//               return const Center(child: Text('Pull to refresh'));
//             },
//           ),
//           // backgroundColor: Colors.grey.shade50,
//         ));
//     }
//
//   // Helper method to find model by ID
//   Model? _findModelById(String modelId, List<CategoryGroup> categories) {
//     for (final category in categories) {
//       for (final model in category.models) {
//         if (model.id == modelId) {
//           return model;
//         }
//       }
//     }
//     return null;
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexora/core/theme/commanMethods.dart';
import '../../../core/local_storage/LocalStorage.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/model_list_bloc.dart';

class ModelListScreen extends StatefulWidget {
  const ModelListScreen({super.key});

  @override
  State<ModelListScreen> createState() => _ModelListScreenState();
}

class _ModelListScreenState extends State<ModelListScreen> {
  String? _previouslySelectedModelId;

  @override
  void initState() {
    super.initState();
    _loadPreviouslySelectedModel();
    // Load categories when screen initializes
    context.read<ModelListBloc>().add(RefreshCategories());
  }

  Future<void> _loadPreviouslySelectedModel() async {
    final selectedModelId = await LocalStorage.getSelectedModelId();
    if (selectedModelId != null) {
      setState(() {
        _previouslySelectedModelId = selectedModelId;
      });
      // Set the selected model in BLoC
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ModelListBloc>().add(SelectModel(selectedModelId));
      });
    }
  }

  Future<void> _saveSelectedModelToLocalStorage(Model model) async {
    await LocalStorage.setSelectedModel(
      id: model.id,
      name: model.name,
      description: model.description,
      apiModelName: model.apiModelName,
      useCase: model.useCase,
      category: model.category ?? '',
    );
  }

  void _showModelSelectedSnackbar(String modelName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$modelName selected successfully!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = getThemeBaseColors(context);

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        title: const Text("Models"),
        elevation: 0,
        backgroundColor: appColors.background,
        surfaceTintColor: appColors.background,
        foregroundColor: appColors.textDark,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: appColors.textDark),
            onPressed: () {
              context.read<ModelListBloc>().add(RefreshCategories());
            },
          ),
        ],
      ),
      body: BlocListener<ModelListBloc, ModelListState>(
        listener: (context, state) {
          if (state is ModelListLoaded && state.selectedModelId != null) {
            // When a model is selected, find it and save to local storage
            final selectedModel = _findModelById(state.selectedModelId!, state.categories);
            if (selectedModel != null) {
              _saveSelectedModelToLocalStorage(selectedModel);
              _showModelSelectedSnackbar(selectedModel.name);
            }
          }
        },
        child: BlocBuilder<ModelListBloc, ModelListState>(
          builder: (context, state) {
            if (state is ModelListLoading) {
              return Center(
                child: CircularProgressIndicator(color: appColors.colorPrimary),
              );
            }

            if (state is ModelListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: appColors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: TextStyle(color: appColors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ModelListBloc>().add(LoadCategories());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.colorPrimary,
                        foregroundColor: appColors.textLight,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ModelListLoaded) {
              final categories = state.categories;

              if (categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 64,
                        color: appColors.gray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No models found',
                        style: TextStyle(
                          fontSize: 18,
                          color: appColors.gray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add models using the Category Page',
                        style: TextStyle(color: appColors.gray),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                itemBuilder: (context, groupIndex) {
                  final group = categories[groupIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.categoryName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: appColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(group.models.length, (modelIndex) {
                        final model = group.models[modelIndex];
                        final isSelected = state.selectedModelId == model.id;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                          color: appColors.grayLight,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: appColors.colorPrimaryLight,
                                  child: Icon(
                                    model.icon,
                                    color: appColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        model.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: appColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        model.description,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: appColors.textGray,
                                        ),
                                      ),
                                      if (model.useCase.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Use Case: ${model.useCase}',
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: appColors.gray,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    context.read<ModelListBloc>().add(
                                      SelectModel(model.id),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? appColors.colorPrimary
                                        : appColors.colorPrimaryLight,
                                    foregroundColor: isSelected
                                        ? appColors.textLight
                                        : appColors.textDark,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? appColors.colorPrimary
                                          : appColors.gray,
                                    ),
                                  ),
                                  child: Text(isSelected ? "Selected" : "Select"),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            }

            return Center(
              child: Text(
                'Pull to refresh',
                style: TextStyle(color: appColors.textGray),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to find model by ID
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
}