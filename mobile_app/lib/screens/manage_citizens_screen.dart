import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'citizen_details_screen.dart';
import 'edit_citizen_screen.dart';

class ManageCitizensScreen extends StatefulWidget {
  const ManageCitizensScreen({super.key});

  @override
  State<ManageCitizensScreen> createState() => _ManageCitizensScreenState();
}

class _ManageCitizensScreenState extends State<ManageCitizensScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AuthProvider>(context, listen: false).fetchAllUsers()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Citizens')),
      body: Consumer<AuthProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.users.isEmpty) {
            return const Center(child: Text('No citizens found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.users.length,
            itemBuilder: (ctx, index) {
              final user = provider.users[index];
              final role = user['role'] ?? 'User';

              // Filter out admins from the list if desired, or show all
              // if (role == 'Admin') return const SizedBox.shrink();

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (_) => CitizenDetailsScreen(user: user)
                      )
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: role == 'Admin' ? Colors.indigoAccent : Colors.teal,
                    backgroundImage: (user['profileImage'] != null && (user['profileImage'] as String).isNotEmpty)
                        ? NetworkImage(user['profileImage'])
                        : null,
                    child: (user['profileImage'] == null || (user['profileImage'] as String).isEmpty)
                        ? Icon(
                            role == 'Admin' ? Icons.admin_panel_settings : Icons.person,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  title: Text(
                      (user['fullName'] != null && (user['fullName'] as String).isNotEmpty)
                          ? user['fullName']
                          : (role == 'Admin' ? 'System Admin' : 'Unknown User'),
                      style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  // Subtitle removed as per request to show only name
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                             Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditCitizenScreen(user: user))
                             );
                          },
                        ),
                       if (role == 'User')
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                             showDialog(
                               context: context, 
                               builder: (ctx) => Dialog(
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                 elevation: 0,
                                 backgroundColor: Colors.transparent,
                                 child: Container(
                                   padding: const EdgeInsets.all(20),
                                   decoration: BoxDecoration(
                                     color: Colors.white,
                                     shape: BoxShape.rectangle,
                                     borderRadius: BorderRadius.circular(20),
                                     boxShadow: const [
                                       BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 10)),
                                     ],
                                   ),
                                   child: Column(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       const CircleAvatar(
                                         backgroundColor: Color(0xFFFFEBEE), // Light Red
                                         radius: 30,
                                         child: Icon(Icons.delete_forever, color: Colors.red, size: 30),
                                       ),
                                       const SizedBox(height: 20),
                                       const Text(
                                         'Delete User?',
                                         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                       ),
                                       const SizedBox(height: 10),
                                       Text(
                                         'Are you sure you want to remove \n"${user['fullName']}"?\nThis action cannot be undone.',
                                         textAlign: TextAlign.center,
                                         style: const TextStyle(fontSize: 14, color: Colors.grey),
                                       ),
                                       const SizedBox(height: 24),
                                       Row(
                                         children: [
                                           Expanded(
                                             child: OutlinedButton(
                                               onPressed: () => Navigator.pop(ctx),
                                               style: OutlinedButton.styleFrom(
                                                 padding: const EdgeInsets.symmetric(vertical: 12),
                                                 side: const BorderSide(color: Colors.grey),
                                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                               ),
                                               child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                                             ),
                                           ),
                                           const SizedBox(width: 12),
                                           Expanded(
                                             child: ElevatedButton(
                                               onPressed: () async {
                                                 Navigator.pop(ctx);
                                                 final success = await Provider.of<AuthProvider>(context, listen: false)
                                                    .deleteUser(user['_id']);
                                                 
                                                 if (success && mounted) {
                                                     ScaffoldMessenger.of(context).showSnackBar(
                                                         const SnackBar(
                                                           content: Text('User deleted successfully'),
                                                           backgroundColor: Colors.green,
                                                         )
                                                     );
                                                 }
                                               },
                                               style: ElevatedButton.styleFrom(
                                                 backgroundColor: Colors.red,
                                                 foregroundColor: Colors.white,
                                                 padding: const EdgeInsets.symmetric(vertical: 12),
                                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                               ),
                                               child: const Text('Delete'),
                                             ),
                                           ),
                                         ],
                                       )
                                     ],
                                   ),
                                 ),
                               )
                             );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
