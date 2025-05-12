// lib/presentation/pages/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import '../customers/customers_page.dart';
import '../products/products_page.dart';
import '../quotes/quotes_page.dart';
import '../projects/projects_page.dart';
import '../customers/add_customer_page.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardHomeTab(),
    const CustomersPage(),
    const QuotesPage(),
    const ProjectsPage(),
    const ProductsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoSheet CRM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Quotes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Dashboard FAB pressed, currentIndex: $_currentIndex");
          // Context-aware FAB - changes based on current tab
          switch (_currentIndex) {
            case 0: // Dashboard - no action
              break;
            case 1: // Customers - add customer
          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => const AddCustomerPage(),
          ),
          );
              break;
            case 2: // Quotes - create quote
              break;
            case 3: // Projects - add project
              break;
            case 4: // Products - add product
              break;
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Dashboard home tab (main dashboard content)
class DashboardHomeTab extends StatelessWidget {
  const DashboardHomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats overview
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Customers',
                  value: '24',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Quotes',
                  value: '12',
                  icon: Icons.description,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Projects',
                  value: '8',
                  icon: Icons.build,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Products',
                  value: '36',
                  icon: Icons.inventory,
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          // Recent activity
          const SizedBox(height: 32),
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            context,
            title: 'New Quote Created',
            description: 'Quote #1042 for John Smith',
            time: '2 hours ago',
            icon: Icons.description,
            color: Colors.green,
          ),
          _buildActivityItem(
            context,
            title: 'Project Status Updated',
            description: 'Kitchen Remodel - Changed to In Progress',
            time: '5 hours ago',
            icon: Icons.build,
            color: Colors.orange,
          ),
          _buildActivityItem(
            context,
            title: 'New Customer Added',
            description: 'Jane Doe - Residential Customer',
            time: '1 day ago',
            icon: Icons.person_add,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context, {
        required String title,
        required String description,
        required String time,
        required IconData icon,
        required Color color,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Text(
          time,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}