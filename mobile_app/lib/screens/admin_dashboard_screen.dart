import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/registration_provider.dart';
import '../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<RegistrationProvider>(context, listen: false).fetchAllRequests()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Requests')),
      body: Consumer<RegistrationProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.requests.isEmpty) {
            return const Center(child: Text('No requests found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.requests.length,
            itemBuilder: (ctx, index) {
              final request = provider.requests[index];
              final user = request['user'] ?? {};
              final details = request['details'] ?? {};

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            request['type'] ?? 'Request',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 20, 
                              color: AppColors.primaryBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                          _buildStatusDropdown(request),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Applicant: ${user['fullName'] ?? user['email'] ?? 'N/A'}'),
                      const SizedBox(height: 4),
                       Text('Citizen Name: ${details['fullName'] ?? details['childFullName'] ?? 'N/A'}'),
                       const SizedBox(height: 4),
                      Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(request['createdAt']))}'),
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

  Widget _buildStatusDropdown(Map<String, dynamic> request) {
    final currentStatus = request['status'];
    final provider = Provider.of<RegistrationProvider>(context, listen: false);

    return DropdownButton<String>(
      value: currentStatus,
      items: ['Starting', 'In Progress', 'Completed', 'Rejected']
          .map((status) => DropdownMenuItem(
                value: status,
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ))
          .toList(),
      onChanged: (newStatus) async {
        if (newStatus != null && newStatus != currentStatus) {
            
            // Default update action
            Future<void> performUpdate({String? note}) async {
                final success = await provider.updateRequestStatus(request['_id'], newStatus, adminNote: note);
                if (success) {
                     if (mounted) {
                        showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 16,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Success!',
                                    style: TextStyle(
                                      fontSize: 24, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Status has been updated to "$newStatus" successfully.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () => Navigator.pop(ctx), 
                                      child: const Text('OK', style: TextStyle(fontSize: 16, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        );
                     }
                } else {
                     if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update status')),
                        );
                     }
                }
            }

            // Logic: If status was 'Completed' AND new status is 'In Progress' or 'Rejected'
            if (currentStatus == 'Completed' && (newStatus == 'In Progress' || newStatus == 'Rejected')) {
                 final reasonController = TextEditingController();
                 showDialog(
                   context: context,
                   builder: (ctx) => Dialog(
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                     elevation: 0,
                     backgroundColor: Colors.transparent,
                     child: Container(
                       padding: const EdgeInsets.all(24),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(20),
                         boxShadow: const [
                           BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 10)),
                         ],
                       ),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           CircleAvatar(
                             backgroundColor: newStatus == 'Rejected' ? Colors.red.shade50 : Colors.orange.shade50,
                             radius: 30,
                             child: Icon(
                               newStatus == 'Rejected' ? Icons.cancel : Icons.history, 
                               color: newStatus == 'Rejected' ? Colors.red : Colors.orange, 
                               size: 30
                             ),
                           ),
                           const SizedBox(height: 20),
                           Text(
                             newStatus == 'Rejected' ? 'Reject Request?' : 'Revert Status?',
                             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                           ),
                           const SizedBox(height: 10),
                           Text(
                             'Please provide a reason for changing status to "$newStatus".',
                             textAlign: TextAlign.center,
                             style: const TextStyle(fontSize: 14, color: Colors.grey),
                           ),
                           const SizedBox(height: 20),
                           TextField(
                             controller: reasonController,
                             decoration: InputDecoration(
                               hintText: 'Enter reason here...',
                               filled: true,
                               fillColor: Colors.grey.shade50,
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: BorderSide.none,
                               ),
                               contentPadding: const EdgeInsets.all(16),
                             ),
                             maxLines: 3,
                           ),
                           const SizedBox(height: 24),
                           Row(
                             children: [
                               Expanded(
                                 child: OutlinedButton(
                                   onPressed: () => Navigator.pop(ctx),
                                   style: OutlinedButton.styleFrom(
                                     padding: const EdgeInsets.symmetric(vertical: 14),
                                     side: const BorderSide(color: Colors.grey),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                   ),
                                   child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                                 ),
                               ),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: ElevatedButton(
                                   onPressed: () {
                                     if (reasonController.text.trim().isEmpty) {
                                       ScaffoldMessenger.of(ctx).showSnackBar(
                                         const SnackBar(content: Text('Please enter a reason')),
                                       );
                                       return;
                                     }
                                     Navigator.pop(ctx);
                                     performUpdate(note: reasonController.text.trim());
                                   },
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: AppColors.primaryBlue,
                                     foregroundColor: Colors.white,
                                     padding: const EdgeInsets.symmetric(vertical: 14),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                   ),
                                   child: const Text('Submit'),
                                 ),
                               ),
                             ],
                           )
                         ],
                       ),
                     ),
                   )
                 );
            } else {
               // Normal update
               await performUpdate();
            }
        }
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'In Progress': return Colors.orange;
      case 'Rejected': return Colors.red;
      default: return Colors.blue;
    }
  }
}
