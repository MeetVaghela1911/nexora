// import 'package:nexora/routes/app_router.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             // Profile Avatar
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: AssetImage("assets/avatar.png"), // replace with your image
//             ),
//             const SizedBox(height: 12),
//             // Name
//             const Text(
//               "Ethan Carter",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             // Email
//             const Text(
//               "ethan.carter@email.com",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Account Section
//             _SectionCard(
//               title: "Account",
//               items: [
//                 _SectionItem(title: "My Details"),
//                 _SectionItem(title: "Subscription"),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             // Preferences Section
//             _SectionCard(
//               title: "Preferences",
//               items: [
//                 _SectionItem(
//                   title: "Theme",
//                   trailing: Icon(Icons.settings, size: 18, color: Colors.grey),
//                 ),
//                 _SectionItem(title: "Notifications"),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // Logout Button
//             TextButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.logout, color: Colors.red),
//               label: const Text(
//                 "Logout",
//                 style: TextStyle(color: Colors.red, fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//
//     );
//   }
// }
//
// class _SectionCard extends StatelessWidget {
//   final String title;
//   final List<_SectionItem> items;
//
//   const _SectionCard({required this.title, required this.items});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//           const SizedBox(height: 10),
//           Column(
//             children: items,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SectionItem extends StatelessWidget {
//   final String title;
//   final Widget? trailing;
//
//   const _SectionItem({required this.title, this.trailing});
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         context.push(AppRoutes.editProfile);
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
//         child: Row(
//           children: [
//             Text(title, style: const TextStyle(fontSize: 15)),
//             const Spacer(),
//             trailing ??
//                 const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:nexora/core/local_storage/LocalStorage.dart';
// import 'package:nexora/routes/app_router.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../auth/bloc/singup/sign_up_bloc.dart';
// import '../../auth/bloc/singup/sign_up_event.dart';
// import '../../auth/bloc/singup/sign_up_state.dart';
// import '../bloc/profile/profile_bloc.dart';
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     final userMobile = LocalStorage.getUserMobile();
//
//     return BlocProvider(
//       create: (context) => ProfileBloc(user: user!)..add(LoadProfile()),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: Text('Back'),
//           backgroundColor: Colors.white,
//           surfaceTintColor: Colors.white,
//         ),
//         body: SafeArea(
//           child: BlocBuilder<ProfileBloc, ProfileState>(
//             builder: (context, state) {
//               if (state is ProfileLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (state is ProfileError) {
//                 return Center(
//                   child: Text('Error: ${state.message}'),
//                 );
//               }
//
//               final userData = state is ProfileLoaded ? state.userData : {
//                 'name': user?.displayName ?? 'User',
//                 'email': user?.email ?? '',
//                 'photoUrl': user?.photoURL,
//                 'phoneNo': user?.phoneNumber,
//               };
//
//               return _buildProfileContent(context, userData);
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileContent(BuildContext context, Map<String, dynamic> userData) {
//     return Column(
//       children: [
//         const SizedBox(height: 20),
//         // Profile Avatar
//         CircleAvatar(
//           radius: 50,
//           backgroundImage: userData['photoUrl'] != null
//               ? NetworkImage(userData['photoUrl']!)
//               : const AssetImage("assets/avatar.png") as ImageProvider,
//         ),
//         const SizedBox(height: 12),
//         // Name
//         Text(
//           userData['name'] ?? "User",
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         // Email
//         Text(
//           userData['email'] ?? "",
//           style: const TextStyle(
//             fontSize: 14,
//             color: Colors.grey,
//           ),
//         ),
//         const SizedBox(height: 24),
//
//         // Profile Items List
//         Expanded(
//           child: ListView(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             children: [
//               // User Info Section
//               _ProfileSectionCard(
//                 items: [
//                   _ProfileListItem(
//                     icon: Icons.person_outline,
//                     title: "Username",
//                     subtitle: userData['name'] ?? "User",
//                     onTap: () => _showEditProfileDialog(context, userData['name'] ?? ''),
//                   ),
//                   _ProfileListItem(
//                     icon: Icons.email_outlined,
//                     title: "Email",
//                     subtitle: userData['email'] ?? "No email",
//                     onTap: () {}, // You can add email editing functionality
//                   ),
//                   _ProfileListItem(
//                     icon: Icons.phone_outlined,
//                     title: "Mobile No",
//                     subtitle: userData['phoneNo'] ?? 'No Mobile Number.', // You can add phone number to user data
//                     onTap: () => _showEditPhoneDialog(context),
//                   ),
//                   // _ProfileListItem(
//                   //   icon: Icons.info_outline,
//                   //   title: "About",
//                   //   subtitle: "Hey there! I am using Nexora", // Default about text
//                   //   onTap: () => context.push(AppRoutes.about),
//                   // ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//
//               // // Security Section
//               _ProfileSectionCard(
//                 items: [
//                   _ProfileListItem(
//                     icon: Icons.security_outlined,
//                     title: "Security",
//                     subtitle: "Privacy, security, change password",
//                     onTap: () => context.push(AppRoutes.about),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               //
//               // Voice & Settings Section
//               // _ProfileSectionCard(
//               //   items: [
//               //     _ProfileListItem(
//               //       icon: Icons.record_voice_over_outlined,
//               //       title: "Voice",
//               //       subtitle: "Voice settings and preferences",
//               //       onTap: () => context.push(AppRoutes.voiceSettings),
//               //     ),
//               //     _ProfileListItem(
//               //       icon: Icons.settings_outlined,
//               //       title: "Settings",
//               //       subtitle: "App settings and preferences",
//               //       onTap: () => context.push(AppRoutes.settings),
//               //     ),
//               //   ],
//               // ),
//               // const SizedBox(height: 20),
//
//               // Sign Out Button
//               _SignOutButton(
//                 onTap: () => _showLogoutDialog(context),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showEditProfileDialog(BuildContext context, String currentName) {
//     final nameController = TextEditingController(text: currentName);
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Username'),
//         content: TextField(
//           controller: nameController,
//           decoration: const InputDecoration(
//             labelText: 'Username',
//             border: OutlineInputBorder(),
//             hintText: 'Enter your username',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (nameController.text.trim().isNotEmpty) {
//                 context.read<ProfileBloc>().add(
//                   UpdateProfile(name: nameController.text.trim()),
//                 );
//                 Navigator.of(context).pop();
//               }
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showEditPhoneDialog(BuildContext context) {
//     final phoneController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Mobile Number'),
//         content: TextField(
//           controller: phoneController,
//           keyboardType: TextInputType.phone,
//           decoration: const InputDecoration(
//             labelText: 'Mobile Number',
//             border: OutlineInputBorder(),
//             hintText: '+1 234 567 8900',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Handle phone number update
//               Navigator.of(context).pop();
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showEditAboutDialog(BuildContext context) {
//     final aboutController = TextEditingController(text: "Hey there! I am using Nexora");
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit About'),
//         content: TextField(
//           controller: aboutController,
//           maxLines: 3,
//           decoration: const InputDecoration(
//             labelText: 'About',
//             border: OutlineInputBorder(),
//             hintText: 'Tell something about yourself',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Handle about text update
//               Navigator.of(context).pop();
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               context.read<AuthBloc>().add(SignOutRequested());
//             },
//             child: const Text(
//               'Logout',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _ProfileSectionCard extends StatelessWidget {
//   final List<_ProfileListItem> items;
//
//   const _ProfileSectionCard({required this.items});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: items,
//       ),
//     );
//   }
// }
//
// class _ProfileListItem extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;
//
//   const _ProfileListItem({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//         child: Row(
//           children: [
//             // Icon on left
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 size: 20,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(width: 16),
//
//             // Title and subtitle
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//
//             // Chevron icon
//             Icon(
//               Icons.chevron_right,
//               size: 20,
//               color: Colors.grey[400],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SignOutButton extends StatelessWidget {
//   final VoidCallback onTap;
//
//   const _SignOutButton({required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         BlocListener<AuthBloc, AuthState>(
//           listener: (context, state) {
//             if (state is AuthUnauthenticated) {
//               context.go(AppRoutes.login);
//             }
//           },
//         ),
//       ],
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           // margin: const EdgeInsets.symmetric(horizontal: 16),
//           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               // Sign out icon
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.logout,
//                   size: 20,
//                   color: Colors.red[400],
//                 ),
//               ),
//               const SizedBox(width: 16),
//
//               // Sign out text
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Sign Out",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.red,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       "Logout from your account",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Chevron icon
//               Icon(
//                 Icons.chevron_right,
//                 size: 20,
//                 color: Colors.grey[400],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:nexora/core/local_storage/LocalStorage.dart';
import 'package:nexora/core/theme/commanMethods.dart';
import 'package:nexora/core/utility/MyInstanc.dart';
import 'package:nexora/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utility/navigation_helper.dart';
import '../../auth/bloc/singup/sign_up_bloc.dart';
import '../../auth/bloc/singup/sign_up_event.dart';
import '../../auth/bloc/singup/sign_up_state.dart';
import '../bloc/profile/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Execute any pending callbacks registered during navigation (Web only)
    NavigationHelper.executePendingCallbacks(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = getIt<FirebaseAuth>().currentUser;
    final appColors = getThemeBaseColors(context);

    return BlocProvider(
      create: (context) =>
      ProfileBloc(user: user!)
        ..add(LoadProfile()),
      child: Scaffold(
        backgroundColor: appColors.background,
        appBar: AppBar(
          title: Text('Back', style: TextStyle(color: appColors.textDark)),
          backgroundColor: appColors.background,
          surfaceTintColor: appColors.background,
          foregroundColor: appColors.textDark,
          iconTheme: IconThemeData(color: appColors.textDark),
        ),
        body: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: appColors.colorPrimary,
                  ),
                );
              }

              if (state is ProfileError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: appColors.red),
                  ),
                );
              }

              final userData = state is ProfileLoaded
                  ? state.userData
                  : {
                'name': user?.displayName ?? 'User',
                'email': user?.email ?? '',
                'photoUrl': user?.photoURL,
                'phoneNo': user?.phoneNumber,
              };

              return _buildProfileContent(context, userData, appColors);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context,
      Map<String, dynamic> userData,
      AppColorScheme appColors,) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Profile Avatar
        // CircleAvatar(
        //   radius: 50,
        //   backgroundColor: appColors.colorPrimaryLight,
        //   backgroundImage: userData['photoUrl'] != null
        //       ? NetworkImage(userData['photoUrl']!)
        //       : const AssetImage("assets/avatar.png") as ImageProvider,
        // ),
        CircleAvatar(
          radius: 50,
          backgroundColor: appColors.colorPrimaryLight,
          child: const Icon(Icons.person, size: 50),
        ),
        const SizedBox(height: 12),
        // Name
        Text(
          userData['name'] ?? "User",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: appColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        // Email
        Text(
          userData['email'] ?? "",
          style: TextStyle(fontSize: 14, color: appColors.textGray),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            NavigationHelper.navigateToWithCallback(
              context,
              AppRoutes.editProfile,
                  () => context.read<ProfileBloc>().add(LoadProfile()),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getThemeBaseColors(context).grayLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text('Edit'), Icon(Icons.chevron_right_rounded)],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Profile Items List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // User Info Section
              _ProfileSectionCard(
                appColors: appColors,
                items: [
                  _ProfileListItem(
                    appColors: appColors,
                    icon: Icons.person_outline,
                    title: "Username",
                    subtitle: userData['name'] ?? "User",
                    onTap: () => () {},
                  ),
                  _ProfileListItem(
                    appColors: appColors,
                    icon: Icons.email_outlined,
                    title: "Email",
                    subtitle: userData['email'] ?? "No email",
                    onTap: () {}, // You can add email editing functionality
                  ),
                  _ProfileListItem(
                    appColors: appColors,
                    icon: Icons.phone_outlined,
                    title: "Mobile No",
                    subtitle: userData['phoneNo'] ?? 'No Mobile Number.',
                    onTap: () => () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Security Section
              _ProfileSectionCard(
                appColors: appColors,
                items: [
                  _ProfileListItem(
                    appColors: appColors,
                    icon: Icons.security_outlined,
                    title: "Security",
                    subtitle: "Privacy, security, change password",
                    onTap: () =>
                        NavigationHelper.navigateTo(context, AppRoutes.about),
                    isRightBtnVisible: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sign Out Button
              _SignOutButton(
                appColors: appColors,
                onTap: () => _showLogoutDialog(context, appColors),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context,
      String currentName,
      AppColorScheme appColors,) {
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: appColors.background,
            surfaceTintColor: appColors.background,
            title: Text(
              'Edit Username',
              style: TextStyle(color: appColors.textDark),
            ),
            content: TextField(
              controller: nameController,
              style: TextStyle(color: appColors.textDark),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: appColors.textGray),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: appColors.gray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: appColors.gray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: appColors.colorPrimary),
                ),
                hintText: 'Enter your username',
                hintStyle: TextStyle(color: appColors.textGray),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                    'Cancel', style: TextStyle(color: appColors.textGray)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text
                      .trim()
                      .isNotEmpty) {
                    context.read<ProfileBloc>().add(
                      UpdateProfile(name: nameController.text.trim()),
                    );
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.colorPrimary,
                  foregroundColor: appColors.textLight,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showEditPhoneDialog(BuildContext context, AppColorScheme appColors) {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: appColors.background,
            surfaceTintColor: appColors.background,
            title: Text(
              'Edit Mobile Number',
              style: TextStyle(color: appColors.textDark),
            ),
            content: TextField(
              controller: phoneController,
              style: TextStyle(color: appColors.textDark),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                labelStyle: TextStyle(color: appColors.textGray),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: appColors.gray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: appColors.gray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: appColors.colorPrimary),
                ),
                hintText: '+1 234 567 8900',
                hintStyle: TextStyle(color: appColors.textGray),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                    'Cancel', style: TextStyle(color: appColors.textGray)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle phone number update
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.colorPrimary,
                  foregroundColor: appColors.textLight,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppColorScheme appColors) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: appColors.background,
            surfaceTintColor: appColors.background,
            title: Text('Logout', style: TextStyle(color: appColors.textDark)),
            content: Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: appColors.textDark),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                    'Cancel', style: TextStyle(color: appColors.textGray)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<AuthBloc>().add(SignOutRequested());
                },
                child: Text('Logout', style: TextStyle(color: appColors.red)),
              ),
            ],
          ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  final AppColorScheme appColors;
  final List<_ProfileListItem> items;

  const _ProfileSectionCard({required this.appColors, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.grayLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: appColors.semiTransparentBlack,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  final AppColorScheme appColors;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  bool isRightBtnVisible;

  _ProfileListItem({
    required this.appColors,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isRightBtnVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            // Icon on left
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appColors.colorPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: appColors.textDark),
            ),
            const SizedBox(width: 16),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: appColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: appColors.textGray),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Chevron icon
            if (isRightBtnVisible)
              Icon(Icons.chevron_right, size: 20, color: appColors.gray),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final AppColorScheme appColors;
  final VoidCallback onTap;

  const _SignOutButton({required this.appColors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              context.go(AppRoutes.login);
            }
          },
        ),
      ],
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: appColors.grayLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: appColors.semiTransparentBlack,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Sign out icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appColors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout, size: 20, color: appColors.red),
              ),
              const SizedBox(width: 16),

              // Sign out text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sign Out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: appColors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Logout from your account",
                      style: TextStyle(fontSize: 14, color: appColors.textGray),
                    ),
                  ],
                ),
              ),

              // Chevron icon
              Icon(Icons.chevron_right, size: 20, color: appColors.gray),
            ],
          ),
        ),
      ),
    );
  }
}
