import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CitizenDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const CitizenDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Citizen Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blueAccent,
                  backgroundImage: (user['profileImage'] != null && user['profileImage'].isNotEmpty)
                      ? NetworkImage(user['profileImage']) // In real app this would be a URL
                      : null,
                  child: (user['profileImage'] == null || user['profileImage'].isEmpty) 
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
             Text(
              user['fullName'] ?? 'Unknown',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              user['email'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildDetailCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRow(Icons.email, 'Email', user['email'] ?? 'N/A'),
            const Divider(),
            _buildRow(Icons.person, 'Full Name', user['fullName'] ?? 'N/A'),
            const Divider(),
            _buildRow(Icons.place, 'Place of Birth', user['birthPlace'] ?? 'N/A'),
             const Divider(),
            _buildRow(Icons.location_on, 'Address', user['address'] ?? 'N/A'),
            const Divider(),
             _buildRow(Icons.admin_panel_settings, 'Role', user['role'] ?? 'User'),
             const Divider(),
             _buildRow(Icons.calendar_today, 'Joined', _formatDate(user['createdAt'])),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }
}
