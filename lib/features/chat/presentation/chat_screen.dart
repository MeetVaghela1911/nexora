// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nexora/core/local_storage/LocalStorage.dart';
// import 'package:nexora/core/local_storage/hive/chat_models.dart';
// import 'package:nexora/core/local_storage/hive/chat_storage_service.dart';
// import 'package:nexora/core/service/auth_service.dart';
// import 'package:nexora/core/theme/app_colors.dart';
// import 'package:nexora/routes/app_router.dart';
// import 'package:nexora/core/service/api_service/nvidia_api_service.dart';
// import 'package:nexora/core/utility/MyInstanc.dart';
// import '../../../core/theme/commanMethods.dart';
// import '../bloc/chat_bloc.dart';
// import '../model/code_block.dart';
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _controller = TextEditingController();
//   final TextEditingController _searchController = TextEditingController();
//
//   late AnimationController _sidebarController;
//   bool _isSidebarOpen = false;
//   String selectedModelName = 'Default';
//
//   @override
//   void initState() {
//     super.initState();
//     initVarialable();
//     _sidebarController = AnimationController(
//         vsync: this,
//         duration: const Duration(milliseconds: 300)
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _searchController.dispose();
//     _sidebarController.dispose();
//     super.dispose();
//   }
//
//   Future<void> initVarialable() async {
//     selectedModelName = await LocalStorage.getSelectedModelName() ?? 'Default';
//     setState(() {});
//   }
//
//   void _toggleSidebar(bool open) {
//     setState(() => _isSidebarOpen = open);
//     _sidebarController.animateTo(open ? 1 : 0);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = getThemeBaseColors(context);
//     return BlocProvider(
//       create: (context) => ChatBloc(NvidiaApiService(), authService: getIt<AuthService>()),
//       child: GestureDetector(
//         onHorizontalDragUpdate: (details) {
//           if (details.delta.dx > 6 && !_isSidebarOpen) {
//             _toggleSidebar(true);
//           } else if (details.delta.dx < -6 && _isSidebarOpen) {
//             _toggleSidebar(false);
//           }
//         },
//         child: Stack(
//           children: [
//             _buildSidebar(250.0, colors),
//             _buildMainContent(250.0, colors),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSidebar(double sidebarWidth, AppColorScheme colors) {
//     return AnimatedBuilder(
//       animation: _sidebarController,
//       builder: (context, _) {
//         return Transform.translate(
//           offset: Offset(-sidebarWidth * (1 - _sidebarController.value), 0),
//           child: SizedBox(
//             width: sidebarWidth,
//             height: double.infinity,
//             child: Material(
//               color: colors.background,
//               child: BlocBuilder<ChatBloc, ChatState>(
//                 builder: (context, state) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: kToolbarHeight),
//
//                       // Search field
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         child: TextField(
//                           controller: _searchController,
//                           decoration: InputDecoration(
//                             hintText: "Search history...",
//                             hintStyle: TextStyle(color: colors.textGray),
//                             prefixIcon: Icon(Icons.search, size: 20, color: colors.textGray),
//                             filled: true,
//                             fillColor: colors.searchBg,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                           ),
//                           style: TextStyle(color: colors.textDark),
//                           onChanged: (query) {
//                             if (query.trim().isEmpty) {
//                               context.read<ChatBloc>().add(LoadChatHistory());
//                             } else {
//                               context.read<ChatBloc>().add(SearchChats(query));
//                             }
//                           },
//                         ),
//                       ),
//
//                       // New Chat Button
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         child: SizedBox(
//                           width: double.infinity,
//                           child: OutlinedButton.icon(
//                             onPressed: () {
//                               context.read<ChatBloc>().add(CreateNewChat(modelUsed: selectedModelName));
//                               _searchController.clear();
//                             },
//                             icon: Icon(Icons.add, color: colors.textDark),
//                             label: Text("New Chat", style: TextStyle(color: colors.textDark)),
//                             style: OutlinedButton.styleFrom(
//                               side: BorderSide(color: colors.gray),
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       Divider(height: 1, color: colors.divider),
//
//                       // Models section
//                       InkWell(
// //                         onTap: () => context.push(AppRoutes.models),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Row(
//                             children: [
//                               Icon(Icons.dashboard_customize_outlined, size: 20, color: colors.textDark),
//                               const SizedBox(width: 8),
//                               Text("Models", style: TextStyle(fontWeight: FontWeight.w500, color: colors.textDark)),
//                               const Spacer(),
//                               Icon(Icons.chevron_right, size: 20, color: colors.textGray),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Divider(height: 1, color: colors.divider),
//
//                       // Chat History Header
//                       Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Text("CHAT HISTORY",
//                             style: TextStyle(fontSize: 12, color: colors.textGray)),
//                       ),
//
//                       // Chat History List
//                       Expanded(
//                         child: state.chatHistory.isEmpty
//                             ? Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Text(
//                               "No chat history yet.\nStart a new conversation!",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(color: colors.textGray),
//                             ),
//                           ),
//                         )
//                             : ListView.builder(
//                           padding: EdgeInsets.zero,
//                           itemCount: state.chatHistory.length,
//                           itemBuilder: (context, index) {
//                             final chat = state.chatHistory[index];
//                             final isSelected = state is ChatLoaded &&
//                                 (state as ChatLoaded).currentChatId == chat.id;
//
//                             return InkWell(
//                               onTap: () {
//                                 if (_isSidebarOpen) _toggleSidebar(false);
//                                 context.read<ChatBloc>().add(LoadSpecificChat(chat.id));
//                                 _searchController.clear();
//                               },
//                               onLongPress: () {
//                                 _showChatOptions(context, chat);
//                               },
//                               child: Container(
//                                 color: isSelected ? colors.colorPrimaryLight : Colors.transparent,
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       chat.title,
//                                       style: TextStyle(
//                                         color: isSelected ? colors.colorPrimary : colors.textDark,
//                                         fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                                       ),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       _formatDate(chat.updatedAt),
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                         color: colors.textGray,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//
//                       // Profile section
//                       _buildUserProfileSection(context, colors),
//
//                       SizedBox(height: kToolbarHeight / 2),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildUserProfileSection(BuildContext context, AppColorScheme colors) {
//     return BlocBuilder<ChatBloc, ChatState>(
//       builder: (context, state) {
//         User? currentUser;
//         if (state is ChatUserProfile) {
//           currentUser = state.user;
//         } else if (state is ChatLoaded) {
//           currentUser = state.user;
//         } else if (state is ChatStreaming) {
//           currentUser = state.user;
//         } else if (state is ChatLoading) {
//           currentUser = state.user;
//         } else if (state is ChatError) {
//           currentUser = state.user;
//         }
//
//         if (currentUser != null) {
//           return Padding(
//             padding: const EdgeInsets.all(12),
//             child: GestureDetector(
//               onTap: () {
//                 context.push(AppRoutes.profile).then((value){
//                   context.read<ChatBloc>().add(LoadUserProfile());
//                 });
//               },
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: colors.colorPrimaryLight,
//                     backgroundImage: currentUser.photoURL != null
//                         ? NetworkImage(currentUser.photoURL!)
//                         : null,
//                     child: currentUser.photoURL == null
//                         ? Icon(
//                       Icons.person,
//                       color: colors.gray,
//                       size: 20,
//                     )
//                         : null,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           currentUser.displayName ?? 'User',
//                           style: TextStyle(
//                             color: colors.textDark,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         if (currentUser.email != null)
//                           Text(
//                             currentUser.email!,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: colors.textGray,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.settings,
//                       size: 18,
//                       color: colors.gray,
//                     ),
//                     onPressed: (){},
//                     // onPressed: () => context.push(AppRoutes.profile),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//
//         return Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundColor: colors.gray,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation(colors.white),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Loading...",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: colors.textDark,
//                     ),
//                   ),
//                   Text(
//                     "Fetching profile",
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: colors.textGray,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildMainContent(double sidebarWidth, AppColorScheme colors) {
//     return AnimatedBuilder(
//       animation: _sidebarController,
//       builder: (context, _) {
//         final slide = sidebarWidth * _sidebarController.value;
//         return Transform.translate(
//           offset: Offset(slide, 0),
//           child: Scaffold(
//             appBar: AppBar(
//               backgroundColor: colors.background,
//               surfaceTintColor: colors.background,
//               leading: IconButton(
//                 icon: Icon(Icons.menu, color: colors.textDark),
//                 onPressed: () => _toggleSidebar(!_isSidebarOpen),
//               ),
//               title: Text(
//                 "Nexora",
//                 style: TextStyle(fontWeight: FontWeight.bold, color: colors.textDark),
//               ),
//               actions: [
//                 IconButton(
//                   icon: Icon(Icons.add, color: colors.textDark),
//                   onPressed: () => context.read<ChatBloc>().add(CreateNewChat(modelUsed: selectedModelName)),
//                 ),
//                 const SizedBox(width: 8),
//                 _modelChip(selectedModelName, colors),
//                 const SizedBox(width: 12),
//               ],
//             ),
//             backgroundColor: colors.background,
//             body: BlocConsumer<ChatBloc, ChatState>(
//               listener: (context, state) {
//                 if (state is ChatError) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error: ${state.error}'),
//                       backgroundColor: colors.red,
//                     ),
//                   );
//                 }
//               },
//               builder: (context, state) {
//                 return SafeArea(
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: state.messages.isEmpty && state is! ChatLoading
//                             ? _buildEmptyScreen(context, colors)
//                             : ListView.builder(
//                           padding: const EdgeInsets.all(16),
//                           itemCount: state.messages.length +
//                               (state is ChatStreaming || state is ChatLoading ? 1 : 0),
//                           itemBuilder: (context, index) {
//                             if (index >= state.messages.length) {
//                               return const Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: ChatLoader(),
//                               );
//                             }
//
//                             final msg = state.messages[index];
//                             final isUser = msg.role == 'user';
//
//                             return Align(
//                               alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//                               child: Container(
//                                 constraints: BoxConstraints(
//                                   maxWidth: isUser
//                                       ? MediaQuery.of(context).size.width * 0.8
//                                       : MediaQuery.of(context).size.width * 0.9,
//                                 ),
//                                 margin: const EdgeInsets.symmetric(vertical: 4),
//                                 decoration: isUser
//                                     ? BoxDecoration(
//                                   color: colors.colorPrimaryLight,
//                                   borderRadius: BorderRadius.circular(12),
//                                 )
//                                     : null,
//                                 child: _buildSmartMessage(msg, context, isUser, colors),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//
//                       // Input field
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         color: colors.background,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 controller: _controller,
//                                 maxLines: 3,
//                                 minLines: 1,
//                                 style: TextStyle(color: colors.textDark),
//                                 decoration: InputDecoration(
//                                   hintText: "Message Nexora...",
//                                   hintStyle: TextStyle(color: colors.textGray),
//                                   filled: true,
//                                   fillColor: colors.searchBg,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(24),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                                   suffixIcon: Padding(
//                                     padding: const EdgeInsets.only(right: 4),
//                                     child: Card(
//                                       shape: const CircleBorder(),
//                                       elevation: 2,
//                                       color: colors.colorPrimary,
//                                       child: IconButton(
//                                         icon: Icon(Icons.send, color: colors.white),
//                                         onPressed: () {
//                                           if (_controller.text.trim().isNotEmpty) {
//                                             context.read<ChatBloc>().add(SendMessage(_controller.text.trim()));
//                                             _controller.clear();
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 onSubmitted: (text) {
//                                   if (text.trim().isNotEmpty) {
//                                     context.read<ChatBloc>().add(SendMessage(text.trim()));
//                                     _controller.clear();
//                                   }
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSmartMessage(ChatMessage msg, BuildContext context, bool isUser, AppColorScheme colors) {
//     if (isUser) {
//       return Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             if (msg.isThinking)
//               Text('Thinking...', style: TextStyle(fontStyle: FontStyle.italic, color: colors.textGray)),
//             SelectableText(
//               msg.content,
//               style: TextStyle(fontSize: 16, height: 1.4, color: colors.textDark),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return _buildAIMessage(msg, context, colors);
//     }
//   }
//
//   Widget _buildAIMessage(ChatMessage msg, BuildContext context, AppColorScheme colors) {
//     final content = msg.content;
//     final codeBlocks = _extractCodeBlocks(content);
//
//     if (codeBlocks.isEmpty) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: MarkdownBody(
//               data: content,
//               selectable: true,
//               styleSheet: MarkdownStyleSheet(
//                 p: TextStyle(fontSize: 16, height: 1.4, color: colors.textDark),
//                 strong: TextStyle(fontWeight: FontWeight.bold, color: colors.textDark),
//                 em: TextStyle(fontStyle: FontStyle.italic, color: colors.textDark),
//                 h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textDark),
//                 h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textDark),
//                 h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textDark),
//                 blockquote: TextStyle(
//                   fontStyle: FontStyle.italic,
//                   color: colors.textDark,
//                   backgroundColor: colors.colorPrimaryLight,
//                 ),
//                 listBullet: TextStyle(fontSize: 16, color: colors.textDark),
//                 code: TextStyle(
//                   backgroundColor: colors.colorPrimaryLight,
//                   color: colors.textDark,
//                   fontFamily: 'RobotoMono',
//                 ),
//                 blockquoteDecoration: BoxDecoration(
//                   color: colors.colorPrimaryLight,
//                   border: Border(left: BorderSide(color: colors.colorPrimary, width: 4)),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 codeblockDecoration: BoxDecoration(
//                   color: colors.colorPrimaryLight,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//           MessageActionBar(
//             message: msg,
//             context: context,
//             colors: colors,
//             isUser: false,
//           ),
//         ],
//       );
//     } else {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildMessageWithCodeBlocks(content, codeBlocks, context, colors),
//           MessageActionBar(
//             message: msg,
//             context: context,
//             colors: colors,
//             isUser: false,
//           ),
//         ],
//       );
//     }
//   }
//   Widget _buildMessageWithCodeBlocks(String content, List<CodeBlock> codeBlocks, BuildContext context, AppColorScheme colors) {
//     final parts = <Widget>[];
//     int currentPosition = 0;
//
//     for (final block in codeBlocks) {
//       if (block.start > currentPosition) {
//         final textBefore = content.substring(currentPosition, block.start);
//         if (textBefore.trim().isNotEmpty) {
//           parts.add(
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
//               child: MarkdownBody(
//                 data: textBefore,
//                 selectable: true,
//                 styleSheet: MarkdownStyleSheet(
//                   p: TextStyle(fontSize: 16, height: 1.4, color: colors.textDark),
//                   strong: TextStyle(fontWeight: FontWeight.bold, color: colors.textDark),
//                   em: TextStyle(fontStyle: FontStyle.italic, color: colors.textDark),
//                   h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textDark),
//                   h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textDark),
//                   h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textDark),
//                   blockquote: TextStyle(
//                     fontStyle: FontStyle.italic,
//                     color: colors.textDark,
//                     backgroundColor: colors.colorPrimaryLight,
//                   ),
//                   code: TextStyle(
//                     backgroundColor: colors.colorPrimaryLight,
//                     color: colors.textDark,
//                     fontFamily: 'RobotoMono',
//                   ),
//                   blockquoteDecoration: BoxDecoration(
//                     color: colors.colorPrimaryLight,
//                     border: Border(left: BorderSide(color: colors.colorPrimary, width: 4)),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }
//       }
//
//       parts.add(Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         child: _buildCodeBlockCard(block, context, colors),
//       ));
//
//       currentPosition = block.end;
//     }
//
//     if (currentPosition < content.length) {
//       final textAfter = content.substring(currentPosition);
//       if (textAfter.trim().isNotEmpty) {
//         parts.add(
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//             child: MarkdownBody(
//               data: textAfter,
//               selectable: true,
//               styleSheet: MarkdownStyleSheet(
//                 p: TextStyle(fontSize: 16, height: 1.4, color: colors.textDark),
//                 strong: TextStyle(fontWeight: FontWeight.bold, color: colors.textDark),
//                 em: TextStyle(fontStyle: FontStyle.italic, color: colors.textDark),
//                 h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textDark),
//                 h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textDark),
//                 h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textDark),
//                 blockquote: TextStyle(
//                   fontStyle: FontStyle.italic,
//                   color: colors.textDark,
//                   backgroundColor: colors.colorPrimaryLight,
//                 ),
//                 code: TextStyle(
//                   backgroundColor: colors.colorPrimaryLight,
//                   color: colors.textDark,
//                   fontFamily: 'RobotoMono',
//                 ),
//                 blockquoteDecoration: BoxDecoration(
//                   color: colors.colorPrimaryLight,
//                   border: Border(left: BorderSide(color: colors.colorPrimary, width: 4)),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }
//     }
//
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: parts);
//   }
//
//   Widget _buildCodeBlockCard(CodeBlock block, BuildContext context, AppColorScheme colors) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
//               borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
//             ),
//             child: Row(
//               children: [
//                 Text(
//                   block.language == 'text' ? 'TEXT' : block.language.toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//                   ),
//                 ),
//                 const Spacer(),
//                 MouseRegion(
//                   cursor: SystemMouseCursors.click,
//                   child: GestureDetector(
//                     onTap: () => _copyToClipboard(block.code, context),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.content_copy, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Copy',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: SelectableText(
//                 block.code,
//                 style: TextStyle(
//                   fontFamily: 'RobotoMono',
//                   fontSize: 14,
//                   color: isDark ? const Color(0xFFD4D4D4) : const Color(0xFF2D2D2D),
//                   height: 1.4,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyScreen(BuildContext context, AppColorScheme colors) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.chat_bubble_outline, size: 60, color: colors.textGray),
//           const SizedBox(height: 16),
//           Text("Start a new conversation with Nexora",
//               style: TextStyle(fontSize: 16, color: colors.textGray)),
//           const SizedBox(height: 24),
//           Wrap(
//             spacing: 8,
//             children: [
//               _suggestionChip("Summarize text", context, colors),
//               _suggestionChip("Create email", context, colors),
//               _suggestionChip("Explain code", context, colors),
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _suggestionChip(String text, BuildContext context, AppColorScheme colors) {
//     return GestureDetector(
//       onTap: () {
//         _controller.text = text;
//         context.read<ChatBloc>().add(SendMessage(text));
//         _controller.clear();
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: colors.colorPrimaryLight,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(text, style: TextStyle(color: colors.textDark)),
//       ),
//     );
//   }
//
//   Widget _modelChip(String text, AppColorScheme colors) {
//     return InkWell(
//       onTap: () => context.push(AppRoutes.models),
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: colors.colorPrimaryLight,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(text, style: TextStyle(color: colors.textDark)),
//       ),
//     );
//   }
//
//   List<CodeBlock> _extractCodeBlocks(String content) {
//     final codeBlockRegex = RegExp(r'```(\w+)?\s*([\s\S]*?)```', multiLine: true);
//     final matches = codeBlockRegex.allMatches(content);
//     final codeBlocks = <CodeBlock>[];
//
//     for (final match in matches) {
//       final language = match.group(1)?.trim() ?? 'text';
//       var code = match.group(2)?.trim() ?? '';
//       if (code.isNotEmpty) {
//         codeBlocks.add(CodeBlock(
//           language: language.isEmpty ? 'text' : language,
//           code: code,
//           start: match.start,
//           end: match.end,
//         ));
//       }
//     }
//     return codeBlocks;
//   }
//
//   void _copyToClipboard(String text, BuildContext context) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Copied to clipboard'),
//         backgroundColor: getThemeBaseColors(context).green,
//       ),
//     );
//   }
//
//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
//     if (difference.inDays == 0) return 'Today';
//     if (difference.inDays == 1) return 'Yesterday';
//     if (difference.inDays < 7) return '${difference.inDays} days ago';
//     return '${date.day}/${date.month}/${date.year}';
//   }
//
//   void _showChatOptions(BuildContext context, Chat chat) {
//     final colors = getThemeBaseColors(context);
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: colors.background,
//       builder: (sheetContext) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(Icons.edit, color: colors.textDark),
//               title: Text('Rename', style: TextStyle(color: colors.textDark)),
//               onTap: () {
//                 Navigator.pop(sheetContext);
//                 _showRenameDialog(context, chat);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.delete, color: colors.red),
//               title: Text('Delete', style: TextStyle(color: colors.red)),
//               onTap: () {
//                 Navigator.pop(sheetContext);
//                 _showDeleteDialog(context, chat);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showRenameDialog(BuildContext context, Chat chat) {
//     final colors = getThemeBaseColors(context);
//     final textController = TextEditingController(text: chat.title);
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         backgroundColor: colors.background,
//         title: Text('Rename Chat', style: TextStyle(color: colors.textDark)),
//         content: TextField(
//           controller: textController,
//           style: TextStyle(color: colors.textDark),
//           decoration: InputDecoration(
//             hintText: 'Enter new name',
//             hintStyle: TextStyle(color: colors.textGray),
//           ),
//           autofocus: true,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: TextStyle(color: colors.textGray)),
//           ),
//           TextButton(
//             onPressed: () async {
//               if (textController.text.trim().isNotEmpty) {
//                 await ChatStorageService.updateChatTitle(chat.id, textController.text.trim());
//                 context.read<ChatBloc>().add(LoadChatHistory());
//                 Navigator.pop(dialogContext);
//               }
//             },
//             child: Text('Save', style: TextStyle(color: colors.colorPrimary)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showDeleteDialog(BuildContext context, Chat chat) {
//     final colors = getThemeBaseColors(context);
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         backgroundColor: colors.background,
//         title: Text('Delete Chat', style: TextStyle(color: colors.textDark)),
//         content: Text('Are you sure you want to delete "${chat.title}"?', style: TextStyle(color: colors.textDark)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: Text('Cancel', style: TextStyle(color: colors.textGray)),
//           ),
//           TextButton(
//             onPressed: () async {
//               await ChatStorageService.deleteChat(chat.id);
//               context.read<ChatBloc>().add(LoadChatHistory());
//               Navigator.pop(dialogContext);
//             },
//             style: TextButton.styleFrom(foregroundColor: colors.red),
//             child: Text('Delete', style: TextStyle(color: colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Update ChatLoader to use theme colors
// class ChatLoader extends StatefulWidget {
//   const ChatLoader({super.key});
//
//   @override
//   State<ChatLoader> createState() => _ChatLoaderState();
// }
//
// class _ChatLoaderState extends State<ChatLoader> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = getThemeBaseColors(context);
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: List.generate(3, (index) {
//         return AnimatedBuilder(
//           animation: _controller,
//           builder: (_, __) {
//             final value = (index * 0.2 + _controller.value) % 1.0;
//             final offset = (value < 0.5 ? value : 1 - value) * 8;
//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 2),
//               width: 8,
//               height: 8,
//               transform: Matrix4.translationValues(0, -offset, 0),
//               decoration: BoxDecoration(
//                 color: colors.gray,
//                 shape: BoxShape.circle,
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }
//
// class MessageActionBar extends StatelessWidget {
//   final ChatMessage message;
//   final BuildContext context;
//   final AppColorScheme colors;
//   final bool isUser;
//
//   const MessageActionBar({
//     required this.message,
//     required this.context,
//     required this.colors,
//     required this.isUser,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (isUser) return SizedBox.shrink();
//
//     return Padding(
//       padding: const EdgeInsets.only(top: 8, left: 12),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildActionButton(
//             icon: Icons.content_copy,
//             tooltip: 'Copy',
//             onPressed: () => _copyEntireResponse(),
//           ),
//           const SizedBox(width: 8),
//           _buildActionButton(
//             icon: Icons.share,
//             tooltip: 'Share',
//             onPressed: () => _shareChat(),
//           ),
//           const SizedBox(width: 8),
//           _buildActionButton(
//             icon: Icons.refresh,
//             tooltip: 'Regenerate',
//             onPressed: () => _regenerateResponse(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required String tooltip,
//     required VoidCallback onPressed,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       child: GestureDetector(
//         onTap: onPressed,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//           decoration: BoxDecoration(
//             color: colors.colorPrimaryLight,
//             borderRadius: BorderRadius.circular(6),
//             border: Border.all(color: colors.gray, width: 0.5),
//           ),
//           child: Icon(
//             icon,
//             size: 16,
//             color: colors.textGray,
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _copyEntireResponse() {
//     Clipboard.setData(ClipboardData(text: message.content));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Response copied to clipboard'),
//         backgroundColor: getThemeBaseColors(context).green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _shareChat() {
//     // Implement share functionality
//     // You can use the share package or native share
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: colors.background,
//           title: Text('Share Chat', style: TextStyle(color: colors.textDark)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Share this conversation',
//                 style: TextStyle(color: colors.textDark),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 readOnly: true,
//                 controller: TextEditingController(text: message.content),
//                 maxLines: 3,
//                 style: TextStyle(color: colors.textDark),
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: colors.searchBg,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: Text('Close', style: TextStyle(color: colors.textGray)),
//             ),
//             TextButton(
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(text: message.content));
//                 Navigator.pop(dialogContext);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: const Text('Copied to clipboard'),
//                     backgroundColor: getThemeBaseColors(context).green,
//                   ),
//                 );
//               },
//               child: Text('Copy', style: TextStyle(color: colors.colorPrimary)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _regenerateResponse() {
//     // Find the last user message and resend it
//     final chatBloc = context.read<ChatBloc>();
//     // You may need to track the last user message in your BLoC
//     // For now, showing a simple implementation
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Regenerating response...'),
//         backgroundColor: getThemeBaseColors(context).colorPrimary,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//     // TODO: Implement regenerate logic based on your BLoC architecture
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:share_plus/share_plus.dart';
// import 'package:sharere_plus/share_plus.dart';

import '../../../core/local_storage/LocalStorage.dart';
import '../../../core/local_storage/hive/chat_models.dart';
import '../../../core/local_storage/hive/chat_storage_service.dart';
import '../../../core/service/api_service/nvidia_api_service.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/commanMethods.dart';
import '../../../core/utility/MyInstanc.dart';
import '../../../routes/app_router.dart';
import '../../../core/utility/navigation_helper.dart';
import '../bloc/chat_bloc.dart';
import '../../models/bloc/model_list_bloc.dart';
import '../model/code_block.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _sidebarController;
  bool _isSidebarOpen = false;
  String selectedModelName = 'Default';
  bool _isInitialized = false;
  bool _isNearBottom = true;

  @override
  void initState() {
    super.initState();
    initVarialable();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NavigationHelper.executePendingCallbacks(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _sidebarController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> initVarialable() async {
    selectedModelName = await LocalStorage.getSelectedModelName() ?? 'Default';
    setState(() {});
  }

  void _toggleSidebar(bool open) {
    setState(() => _isSidebarOpen = open);
    _sidebarController.animateTo(open ? 1 : 0, curve: Curves.easeInOutCubic);
  }

  void _initializeFreshChat(ChatBloc chatBloc) {
    if (!_isInitialized) {
      chatBloc.add(CreateNewChat(modelUsed: selectedModelName));
      _isInitialized = true;
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 100.0) {
        _isNearBottom = true;
      } else {
        _isNearBottom = false;
      }
    }
  }

  void _scrollToBottom({bool isStreaming = false}) {
    // if (_scrollController.hasClients) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     // Double check hasClients after the frame callback
    //     if (_scrollController.hasClients) {
    //       _scrollController.animateTo(
    //         _scrollController.position.maxScrollExtent,
    //         duration: const Duration(milliseconds: 200),
    //         curve: Curves.easeOut,
    //       );
    //     }
    //   });
    // }
    if (_scrollController.hasClients) {
      if (isStreaming && !_isNearBottom) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Double check hasClients after the frame callback
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build called');
    final colors = getThemeBaseColors(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: colors.background,
        statusBarColor: colors.background,
      ),
    );
    return BlocProvider(
      create: (context) =>
          ChatBloc(NvidiaApiService(), authService: getIt<AuthService>()),
      child: Builder(
        builder: (context) {
          // Initialize fresh chat when bloc is first built
          _initializeFreshChat(context.read<ChatBloc>());

          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 6 && !_isSidebarOpen) {
                _toggleSidebar(true);
              } else if (details.delta.dx < -6 && _isSidebarOpen) {
                _toggleSidebar(false);
              }
            },
            child: Stack(
              children: [
                _buildSidebar(250.0, colors),
                _buildDivider(250.0, colors),
                _buildMainContent(250.0, colors),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar(double sidebarWidth, AppColorScheme colors) {
    return AnimatedBuilder(
      animation: _sidebarController,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(-sidebarWidth * (1 - _sidebarController.value), 0),
          child: SizedBox(
            width: sidebarWidth,
            height: double.infinity,
            child: Material(
              color: colors.background,
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: kToolbarHeight),

                            // Search field
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: "Search...",
                                  hintStyle: TextStyle(color: colors.textGray),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 20,
                                    color: colors.textGray,
                                  ),
                                  filled: true,
                                  fillColor: colors.searchBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                  ),
                                ),
                                style: TextStyle(color: colors.textDark),
                                onChanged: (query) {
                                  if (query.trim().isEmpty) {
                                    context.read<ChatBloc>().add(
                                      LoadChatHistory(),
                                    );
                                  } else {
                                    context.read<ChatBloc>().add(
                                      SearchChats(query),
                                    );
                                  }
                                },
                              ),
                            ),

                            // New Chat Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context.read<ChatBloc>().add(
                                      CreateNewChat(
                                        modelUsed: selectedModelName,
                                      ),
                                    );
                                    _searchController.clear();
                                    if (_scrollController.hasClients) {
                                      _scrollController.jumpTo(0);
                                    }
                                    _isNearBottom = true;
                                  },
                                  icon: Icon(Icons.add, color: colors.textDark),
                                  label: Text(
                                    "New Chat",
                                    style: TextStyle(color: colors.textDark),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: colors.gray),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Divider(height: 1, color: colors.searchBg),

                            // Models section
                            InkWell(
                              onTap: () {
                                NavigationHelper.navigateToWithCallback(
                                  context,
                                  AppRoutes.models,
                                  () async {
                                    final newModelName =
                                        await LocalStorage.getSelectedModelName() ??
                                        'Default';
                                    if (newModelName != selectedModelName) {
                                      setState(() {
                                        selectedModelName = newModelName;
                                      });
                                      if (context.mounted) {
                                        context.read<ChatBloc>().add(
                                          CreateNewChat(
                                            modelUsed: selectedModelName,
                                          ),
                                        );
                                        _searchController.clear();
                                        if (_scrollController.hasClients) {
                                          _scrollController.jumpTo(0);
                                        }
                                      }
                                    }
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.dashboard_customize_outlined,
                                      size: 20,
                                      color: colors.textDark,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Models",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: colors.textDark,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 20,
                                      color: colors.textGray,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(height: 1, color: colors.searchBg),

                            // Chat History Header
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                "CHAT HISTORY",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textGray,
                                ),
                              ),
                            ),

                            // Chat History List
                            Expanded(
                              child: state.chatHistory.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          "No chat history yet.\nStart a new conversation!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: colors.textGray,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: state.chatHistory.length,
                                      itemBuilder: (context, index) {
                                        final chat = state.chatHistory[index];
                                        final isSelected = switch (state) {
                                          ChatLoaded(
                                            currentChatId: final chatId,
                                          ) =>
                                            chatId == chat.id,
                                          _ => false,
                                        };

                                        return InkWell(
                                          onTap: () {
                                            context.read<ChatBloc>().add(
                                              LoadSpecificChat(chat.id),
                                            );
                                            _toggleSidebar(false);
                                            _searchController.clear();
                                            if (_scrollController.hasClients) {
                                              _scrollController.jumpTo(0);
                                            }
                                          },
                                          onLongPress: () {
                                            _showChatOptions(context, chat);
                                          },
                                          child: Container(
                                            color: isSelected
                                                ? colors.colorPrimaryLight
                                                : Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  chat.title,
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? colors.colorPrimary
                                                        : colors.textDark,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _formatDate(chat.updatedAt),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: colors.textGray,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),

                            // Profile section
                            _buildUserProfileSection(context, colors),

                            SizedBox(height: kToolbarHeight / 2),
                          ],
                        ),
                      ),
                      Expanded(child: _buildDivider(24, colors)),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserProfileSection(BuildContext context, AppColorScheme colors) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        User? currentUser;
        if (state is ChatUserProfile) {
          currentUser = state.user;
        } else if (state is ChatLoaded) {
          currentUser = state.user;
        } else if (state is ChatStreaming) {
          currentUser = state.user;
        } else if (state is ChatLoading) {
          currentUser = state.user;
        } else if (state is ChatError) {
          currentUser = state.user;
        }

        if (currentUser != null) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () {
                NavigationHelper.navigateToWithCallback(
                  context,
                  AppRoutes.profile,
                  () {
                    context.read<ChatBloc>().add(LoadUserProfile());
                  },
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.colorPrimaryLight,
                    backgroundImage: currentUser.photoURL != null
                        ? NetworkImage(currentUser.photoURL!)
                        : null,
                    child: currentUser.photoURL == null
                        ? Icon(Icons.person, color: colors.gray, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.displayName ?? 'User',
                          style: TextStyle(
                            color: colors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (currentUser.email != null)
                          Text(
                            currentUser.email!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.settings,
                  //     size: 18,
                  //     color: colors.gray,
                  //   ),
                  //   onPressed: (){},
                  // ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.gray,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Loading...",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colors.textDark,
                    ),
                  ),
                  Text(
                    "Fetching profile",
                    style: TextStyle(fontSize: 12, color: colors.textGray),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider(double sidebarWidth, AppColorScheme colors) {
    return AnimatedBuilder(
      animation: _sidebarController,
      builder: (context, _) {
        final slide = sidebarWidth * _sidebarController.value;
        return Transform.translate(
          offset: Offset(slide, 0),
          child: Container(
            width: 1,
            height: double.infinity,
            color: colors.searchBg,
          ),
        );
      },
    );
  }

  Widget _buildMainContent(double sidebarWidth, AppColorScheme colors) {
    return AnimatedBuilder(
      animation: _sidebarController,
      builder: (context, _) {
        final slide = sidebarWidth * _sidebarController.value;
        return Transform.translate(
          offset: Offset(slide, 0),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: colors.background,
              surfaceTintColor: colors.background,
              leadingWidth: double.infinity,
              leading: Row(
                children: [
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 12,
                        top: 6,
                        bottom: 6,
                        right: 12,
                      ),
                      child: Image.asset(
                        'assets/HomeDashboard/sort.png',
                        color: colors.textDark,
                        width: 30,
                      ),
                    ),
                    onTap: () => _toggleSidebar(!_isSidebarOpen),
                  ),
                  // SizedBox(width: 12,),
                  // Text(
                  //   "Nexora",
                  //   style: TextStyle(
                  //       // fontWeight: FontWeight.bold,
                  //       // color: colors.textDark,
                  //     fontSize: 18
                  //   ),
                  // )
                ],
              ),
              // title: ,
              actions: [
                BlocBuilder<ModelListBloc, ModelListState>(
                  builder: (context, modelState) {
                    final currentModelName =
                        modelState is ModelListLoaded &&
                            modelState.selectedModelId != null
                        ? context
                                  .read<ModelListBloc>()
                                  .getModelById(modelState.selectedModelId!)
                                  ?.name ??
                              selectedModelName
                        : selectedModelName;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // IconButton(
                        //   icon: Icon(Icons.add, color: colors.textDark),
                        //   onPressed: () => context.read<ChatBloc>().add(CreateNewChat(modelUsed: currentModelName)),
                        // ),
                        // const SizedBox(width: 8),
                        _modelChip(currentModelName, colors),
                        const SizedBox(width: 12),
                      ],
                    );
                  },
                ),
              ],
            ),
            backgroundColor: colors.background,
            body: BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.error}'),
                      backgroundColor: colors.red,
                    ),
                  );
                }
                // Auto-scroll when streaming or loading
                // Auto-scroll when streaming or loading
                if (state is ChatStreaming) {
                  _scrollToBottom(isStreaming: true);
                } else if (state is ChatLoading) {
                  _scrollToBottom();
                }
              },
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  return SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: state.messages.isEmpty && state is ChatLoading
                              ? const Center(
                                  child: ChatLoader(),
                                ) // Show loader when loading
                              : state.messages.isEmpty
                              ? _buildEmptyScreen(context, colors)
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount:
                                      state.messages.length +
                                      (state is ChatStreaming ||
                                              state is ChatLoading
                                          ? 1
                                          : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= state.messages.length) {
                                      return const Align(
                                        alignment: Alignment.centerLeft,
                                        child: ChatLoader(),
                                      );
                                    }

                                    final msg = state.messages[index];
                                    final isUser = msg.role == 'user';

                                    return Align(
                                      alignment: isUser
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: isUser
                                              ? MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.8
                                              : MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.9,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        decoration: isUser
                                            ? BoxDecoration(
                                                color: colors.colorPrimaryLight,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              )
                                            : null,
                                        child: _buildSmartMessage(
                                          msg,
                                          context,
                                          isUser,
                                          colors,
                                          state,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // Input field
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          color: colors.background,
                          child: Row(
                            children: [
                              // IconButton(
                              //   icon: Icon(Icons.add, color: colors.textDark),
                              //   style: IconButton.styleFrom(
                              //   backgroundColor: colors.searchBg
                              //   ),
                              //   padding: EdgeInsets.all(14),
                              //   onPressed: () => context.read<ChatBloc>().add(CreateNewChat(modelUsed: selectedModelName)),
                              // ),
                              SizedBox(width: 2),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  maxLines: 6,
                                  minLines: 1,
                                  style: TextStyle(color: colors.textDark),
                                  decoration: InputDecoration(
                                    hintText: "Message Nexora...",
                                    hintStyle: TextStyle(
                                      color: colors.textGray,
                                    ),
                                    filled: true,
                                    fillColor: colors.searchBg,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(44),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 0),
                                      child: Card(
                                        shape: const CircleBorder(),
                                        elevation: 2,
                                        color: colors.colorPrimary,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.send,
                                            color: colors.white,
                                          ),
                                          onPressed: () {
                                            if (_controller.text
                                                .trim()
                                                .isNotEmpty) {
                                              context.read<ChatBloc>().add(
                                                SendMessage(
                                                  _controller.text.trim(),
                                                ),
                                              );
                                              _controller.clear();
                                              _scrollToBottom();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (text) {
                                    if (text.trim().isNotEmpty) {
                                      context.read<ChatBloc>().add(
                                        SendMessage(text.trim()),
                                      );
                                      _controller.clear();
                                      _scrollToBottom();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmartMessage(
    ChatMessage msg,
    BuildContext context,
    bool isUser,
    AppColorScheme colors,
    ChatState state,
  ) {
    if (isUser) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (msg.isThinking)
              Text(
                'Thinking...',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: colors.textGray,
                ),
              ),
            SelectableText(
              msg.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: colors.textDark,
              ),
            ),
          ],
        ),
      );
    } else {
      return _buildAIMessage(msg, context, colors, state);
    }
  }

  Widget _buildAIMessage(
    ChatMessage msg,
    BuildContext context,
    AppColorScheme colors,
    ChatState state,
  ) {
    final content = msg.content;
    final codeBlocks = _extractCodeBlocks(content);

    if (codeBlocks.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: MarkdownBody(
              data: content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(fontSize: 16, height: 1.4, color: colors.textDark),
                strong: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
                em: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: colors.textDark,
                ),
                h1: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
                h2: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
                h3: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
                blockquote: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: colors.textDark,
                  backgroundColor: colors.colorPrimaryLight,
                ),
                listBullet: TextStyle(fontSize: 16, color: colors.textDark),
                code: TextStyle(
                  backgroundColor: colors.colorPrimaryLight,
                  color: colors.textDark,
                  fontFamily: 'RobotoMono',
                ),
                blockquoteDecoration: BoxDecoration(
                  color: colors.colorPrimaryLight,
                  border: Border(
                    left: BorderSide(color: colors.colorPrimary, width: 4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                codeblockDecoration: BoxDecoration(
                  color: colors.colorPrimaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          MessageActionBar(
            message: msg,
            context: context,
            colors: colors,
            state: state,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageWithCodeBlocks(content, codeBlocks, context, colors),
          MessageActionBar(
            message: msg,
            context: context,
            colors: colors,
            state: state,
          ),
        ],
      );
    }
  }

  Widget _buildMessageWithCodeBlocks(
    String content,
    List<CodeBlock> codeBlocks,
    BuildContext context,
    AppColorScheme colors,
  ) {
    final parts = <Widget>[];
    int currentPosition = 0;

    for (final block in codeBlocks) {
      if (block.start > currentPosition) {
        final textBefore = content.substring(currentPosition, block.start);
        if (textBefore.trim().isNotEmpty) {
          parts.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: MarkdownBody(
                data: textBefore,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: colors.textDark,
                  ),
                  strong: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textDark,
                  ),
                  em: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colors.textDark,
                  ),
                  h1: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.textDark,
                  ),
                  h2: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textDark,
                  ),
                  h3: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textDark,
                  ),
                  blockquote: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colors.textDark,
                    backgroundColor: colors.colorPrimaryLight,
                  ),
                  code: TextStyle(
                    backgroundColor: colors.colorPrimaryLight,
                    color: colors.textDark,
                    fontFamily: 'RobotoMono',
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: colors.colorPrimaryLight,
                    border: Border(
                      left: BorderSide(color: colors.colorPrimary, width: 4),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          );
        }
      }

      parts.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: _buildCodeBlockCard(block, context, colors),
        ),
      );

      currentPosition = block.end;
    }

    if (currentPosition < content.length) {
      final textAfter = content.substring(currentPosition);
      if (textAfter.trim().isNotEmpty) {
        parts.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: MarkdownBody(
              data: textAfter,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(fontSize: 16, height: 1.4, color: colors.textDark),
                strong: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
                em: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: colors.textDark,
                ),
                h1: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
                h2: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
                h3: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textDark,
                ),
                blockquote: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: colors.textDark,
                  backgroundColor: colors.colorPrimaryLight,
                ),
                code: TextStyle(
                  backgroundColor: colors.colorPrimaryLight,
                  color: colors.textDark,
                  fontFamily: 'RobotoMono',
                ),
                blockquoteDecoration: BoxDecoration(
                  color: colors.colorPrimaryLight,
                  border: Border(
                    left: BorderSide(color: colors.colorPrimary, width: 4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts,
    );
  }

  Widget _buildCodeBlockCard(
    CodeBlock block,
    BuildContext context,
    AppColorScheme colors,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  block.language == 'text'
                      ? 'TEXT'
                      : block.language.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _copyToClipboard(block.code, context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.content_copy,
                            size: 14,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                block.code,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFD4D4D4)
                      : const Color(0xFF2D2D2D),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen(BuildContext context, AppColorScheme colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/HomeDashboard/chat-bubble.png',
            width: 60,
            height: 60,
          ),
          // Icon(Icons.chat_bubble_outline, size: 60, color: colors.textGray),
          const SizedBox(height: 16),
          Text(
            "Start a new conversation with Nexora",
            style: TextStyle(fontSize: 16, color: colors.textGray),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: [
              _suggestionChip("Summarize text", context, colors),
              _suggestionChip("Create email", context, colors),
              _suggestionChip("Explain code", context, colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(
    String text,
    BuildContext context,
    AppColorScheme colors,
  ) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        context.read<ChatBloc>().add(SendMessage(text));
        _controller.clear();
        _scrollToBottom();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.colorPrimaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(color: colors.textDark)),
      ),
    );
  }

  Widget _modelChip(String text, AppColorScheme colors) {
    return InkWell(
      onTap: () => NavigationHelper.navigateTo(context, AppRoutes.models),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: colors.colorPrimaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: colors.textDark, fontSize: 12),
        ),
      ),
    );
  }

  List<CodeBlock> _extractCodeBlocks(String content) {
    if (!content.contains('```')) return [];

    final codeBlockRegex = RegExp(
      r'```(\w+)?\s*([\s\S]*?)```',
      multiLine: true,
    );
    final matches = codeBlockRegex.allMatches(content);
    final codeBlocks = <CodeBlock>[];

    for (final match in matches) {
      final language = match.group(1)?.trim() ?? 'text';
      var code = match.group(2)?.trim() ?? '';
      if (code.isNotEmpty) {
        codeBlocks.add(
          CodeBlock(
            language: language.isEmpty ? 'text' : language,
            code: code,
            start: match.start,
            end: match.end,
          ),
        );
      }
    }
    return codeBlocks;
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: getThemeBaseColors(context).green,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showChatOptions(BuildContext context, Chat chat) {
    final colors = getThemeBaseColors(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: colors.textDark),
              title: Text('Rename', style: TextStyle(color: colors.textDark)),
              onTap: () {
                Navigator.pop(sheetContext);
                _showRenameDialog(context, chat);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: colors.red),
              title: Text('Delete', style: TextStyle(color: colors.red)),
              onTap: () {
                Navigator.pop(sheetContext);
                _showDeleteDialog(context, chat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Chat chat) {
    final colors = getThemeBaseColors(context);
    final textController = TextEditingController(text: chat.title);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Rename Chat', style: TextStyle(color: colors.textDark)),
        content: TextField(
          controller: textController,
          style: TextStyle(color: colors.textDark),
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: colors.textGray),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: colors.textGray)),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.trim().isNotEmpty) {
                await ChatStorageService.updateChatTitle(
                  chat.id,
                  textController.text.trim(),
                );
                context.read<ChatBloc>().add(LoadChatHistory());
                Navigator.pop(dialogContext);
              }
            },
            child: Text('Save', style: TextStyle(color: colors.colorPrimary)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Chat chat) {
    final colors = getThemeBaseColors(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Delete Chat', style: TextStyle(color: colors.textDark)),
        content: Text(
          'Are you sure you want to delete "${chat.title}"?',
          style: TextStyle(color: colors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: colors.textGray)),
          ),
          TextButton(
            onPressed: () async {
              await ChatStorageService.deleteChat(chat.id);
              context.read<ChatBloc>().add(LoadChatHistory());
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: colors.red),
            child: Text('Delete', style: TextStyle(color: colors.red)),
          ),
        ],
      ),
    );
  }
}

// Message Action Bar Widget
class MessageActionBar extends StatelessWidget {
  final ChatMessage message;
  final BuildContext context;
  final AppColorScheme colors;
  final ChatState state;

  const MessageActionBar({
    required this.message,
    required this.context,
    required this.colors,
    required this.state,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.content_copy,
            tooltip: 'Copy',
            onPressed: () => _copyEntireResponse(),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.share,
            tooltip: 'Share',
            onPressed: () => _shareEntireChat(),
          ),
          // const SizedBox(width: 8),
          // _buildActionButton(
          //   icon: Icons.refresh,
          //   tooltip: 'Regenerate',
          //   onPressed: () => _regenerateResponse(),
          // ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: colors.colorPrimaryLight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: colors.gray, width: 0.5),
          ),
          child: Icon(icon, size: 16, color: colors.textGray),
        ),
      ),
    );
  }

  void _copyEntireResponse() {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Response copied to clipboard'),
        backgroundColor: getThemeBaseColors(context).green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareEntireChat() {
    // Build the entire conversation text
    String conversationText = '';

    for (final msg in state.messages) {
      if (msg.role == 'user') {
        conversationText += 'You: ${msg.content}\n\n';
      } else {
        conversationText += 'Nexora: ${msg.content}\n\n';
      }
    }

    // Use share_plus to share across platforms
    Share.share(conversationText, subject: 'Nexora Chat Conversation');
  }

  void _regenerateResponse() {
    context.read<ChatBloc>().add(RegenerateResponse());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Regenerating response...'),
        backgroundColor: getThemeBaseColors(context).colorPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Chat Loader Widget
class ChatLoader extends StatefulWidget {
  const ChatLoader({super.key});

  @override
  State<ChatLoader> createState() => _ChatLoaderState();
}

class _ChatLoaderState extends State<ChatLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = getThemeBaseColors(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final value = (index * 0.2 + _controller.value) % 1.0;
            final offset = (value < 0.5 ? value : 1 - value) * 8;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              transform: Matrix4.translationValues(0, -offset, 0),
              decoration: BoxDecoration(
                color: colors.gray,
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
