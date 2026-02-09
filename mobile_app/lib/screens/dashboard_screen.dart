import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'registration_form_screen.dart';
import 'records_list_screen.dart';
import 'id_request_screen.dart';
import 'profile_screen.dart';
import 'admin_dashboard_screen.dart';
import 'manage_citizens_screen.dart';
import 'nira_info_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      _buildDashboardGrid(),
      const RegistrationFormScreen(),
      const IDRequestScreen(),
      const RecordsListScreen(), 
      const ProfileScreen(),
    ];
    
    // Profile Tab Logic removed (moved to ProfileScreen logout button)

    return Scaffold(
      // Only show Dashboard AppBar on Home tab (index 0)
      appBar: _selectedIndex == 0 ? AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false, // Don't show back button on dashboard
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          )
        ],
      ) : null, 
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Required for 4+ items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Birth',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.add_card),
            label: 'ID',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboardGrid() {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isAdmin = user['role'] == 'Admin';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Welcome ${isAdmin ? "Admin" : "Citizen"}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
           const SizedBox(height: 8),
          Text(isAdmin ? 'Manage System' : 'Choose a service below'),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
               children: [
                if (isAdmin) ...[
                     // Admin Tiles


                    _DashboardCard(
                      title: 'Manage Citizens',
                      icon: Icons.people,
                      color: Colors.indigo,
                      onTap: () {
                         Navigator.of(context).push(
                           MaterialPageRoute(builder: (_) => const ManageCitizensScreen())
                         );
                      },
                    ),


                    _DashboardCard(
                      title: 'All Requests',
                      icon: Icons.list_alt,
                      color: Colors.teal,
                      onTap: () {
                         Navigator.of(context).push(
                           MaterialPageRoute(builder: (_) => const AdminDashboardScreen())
                         );
                      },
                    ),
                    _DashboardCard(
                      title: 'System Reports',
                      icon: Icons.analytics,
                      color: Colors.deepOrange,
                      onTap: () {
                          // Switch to Records Tab (Index 3) reusing for now
                         setState(() {
                           _selectedIndex = 3;
                         });
                      },
                    ),
                     _DashboardCard(
                      title: 'Settings',
                      icon: Icons.settings,
                      color: Colors.blueGrey,
                      onTap: () {
                         // Switch to Profile Tab (Index 4)
                         setState(() {
                           _selectedIndex = 4; // Profile is index 4
                         });
                      },
                    ),
                ] else ...[
                    // User Tiles (Normal Citizen)
                    _DashboardCard(
                      title: 'Birth Registration',
                      icon: Icons.child_care,
                      color: Colors.blue,
                      onTap: () {
                        // Switch to Birth Tab (Index 1)
                         setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                    _DashboardCard(
                      title: 'My Records',
                      icon: Icons.folder_shared,
                      color: Colors.orange,
                      onTap: () {
                        // Switch to Records Tab (Index 3)
                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                    ),
                    _DashboardCard(
                      title: 'ID Request',
                      icon: Icons.badge,
                      color: Colors.green,
                      onTap: () {
                         // Switch to ID Tab (Index 2)
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                    ),
                    _DashboardCard(
                      title: 'Status Tracking',
                      icon: Icons.track_changes,
                      color: Colors.purple,
                      onTap: () {
                         // Switch to Records Tab (Index 3)
                         setState(() {
                           _selectedIndex = 3;
                         });
                      },
                    ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 20),
          // NIRA Ad Banner
          // NIRA Ad Banner
          Center(
            child: InkWell(
              onTap: () {
                 Navigator.of(context).push(
                   MaterialPageRoute(builder: (_) => const NiraInfoScreen())
                 );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity, 
                // Increased height/padding for better visibility
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF4189E0), Colors.blue.shade900], 
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24), // More rounded
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center row content
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user, color: Color(0xFF4189E0), size: 36),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                           Text(
                            'Ku soo dhawaada NIRA!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18, // Larger font
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Is-diiwaangeli oo qaado Kaarkaaga Aqoonsiga Qaran maanta.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final MaterialColor color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.shade50,
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
