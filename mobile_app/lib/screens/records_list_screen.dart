import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/registration_provider.dart';
import '../services/pdf_service.dart';
import '../utils/constants.dart';

class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({super.key});

  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen> {
  final Set<String> _notifiedRequests = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final regProvider = Provider.of<RegistrationProvider>(context, listen: false);
      
      final isAdmin = authProvider.currentUser != null && authProvider.currentUser['role'] == 'Admin';

      if (isAdmin) {
         await regProvider.fetchAllRequests();
         // If you have a fetchAllRegistrations endpoint, call it here too
         // await regProvider.fetchAllRegistrations(); 
      } else {
         await regProvider.fetchRegistrations();
         await regProvider.fetchRequests();
      }

      if (mounted) {
        _checkNotifications(regProvider);
      }
    });
  }

  void _checkNotifications(RegistrationProvider provider) async {
    // Check if current user is admin
    final isAdmin = Provider.of<AuthProvider>(context, listen: false).currentUser?['role'] == 'Admin';
    if (isAdmin) return;

    final prefs = await SharedPreferences.getInstance();
    final notifiedList = prefs.getStringList('notified_requests') ?? [];

    for (var request in provider.requests) {
      // Check if Completed and not yet notified (ever)
      if (request['status'] == 'Completed' && !notifiedList.contains(request['_id'])) {
        
        // Add to persistent storage immediately to prevent double swipe
        notifiedList.add(request['_id']);
        await prefs.setStringList('notified_requests', notifiedList);

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade50,
                    ),
                    child: const Icon(Icons.celebration, size: 50, color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hambalyo! 🎉',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Codsigaagii waa la aqbalay (Completed). Hadda waad soo rogan kartaa (Download) ID-gaaga.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () { 
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Mahadsanid', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break; // Show only one at a time per session check
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context).currentUser?['role'] == 'Admin';

    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? 'System Reports' : 'My Records')),
      body: Consumer<RegistrationProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final allRecords = [...provider.registrations, ...provider.requests]; // Combine both lists logic if needed, or just show requests for now
          // The user asked specifically for ID Request tracking.
          // Let's prioritize showing requests from the new backend endpoint.
          
          if (provider.requests.isEmpty) {
             return const Center(child: Text('No records found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.requests.length,
            itemBuilder: (ctx, index) {
              final item = provider.requests[index];
              final details = item['details'] ?? {};
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.lightBlue,
                                child: Icon(
                                  item['type'] == 'National ID' ? Icons.badge : Icons.child_friendly, 
                                  color: AppColors.primaryBlue
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['type'] ?? 'Request',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    DateFormat('MMM d, yyyy').format(DateTime.parse(item['createdAt'])),
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _StatusBadge(status: item['status'] ?? 'Starting'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildDetailRow('Name:', details['fullName'] ?? details['childFullName'] ?? 'N/A'),
                      const SizedBox(height: 4),
                      _buildDetailRow('ID Type:', item['type'] ?? 'N/A'),
                      
                      if (item['status'] == 'Completed') ...[
                         const SizedBox(height: 16),
                         SizedBox(
                           width: double.infinity,
                           child: ElevatedButton.icon(
                             icon: const Icon(Icons.download),
                             label: const Text('Download PDF'),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.green,
                               foregroundColor: Colors.white,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                             ),
                             onPressed: () async {
                               final pdfService = PDFService();
                               if (item['type'] == 'National ID') {
                                 await pdfService.generateIDCard(details);
                               } else {
                                 await pdfService.generateBirthCertificate(details);
                               }
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('PDF Generated! Check your Downloads/Print.')),
                               );
                             },
                           ),
                         )
                      ]
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text('$label ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    switch (status) {
      case 'Completed':
        color = Colors.green;
        textColor = Colors.green;
        break;
      case 'In Progress':
        color = Colors.orange;
        textColor = Colors.orange;
        break;
      case 'Starting':
      default:
        color = Colors.blue;
        textColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
