// In the DashboardHomeTab class
@override
Widget build(BuildContext context) {
  // Load dashboard data when tab is built
  context.read<DashboardBloc>().add(LoadDashboardData());

  return BlocBuilder<DashboardBloc, DashboardState>(
    builder: (context, state) {
      if (state is DashboardLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is DashboardLoaded) {
        return _buildLoadedDashboard(context, state);
      } else if (state is DashboardError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${state.message}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<DashboardBloc>().add(RefreshDashboardData());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return const Center(child: CircularProgressIndicator());
    },
  );
}

Widget _buildLoadedDashboard(BuildContext context, DashboardLoaded state) {
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
                value: state.customerCount.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Quotes',
                value: state.quoteCount.toString(),
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
                value: state.projectCount.toString(),
                icon: Icons.build,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Products',
                value: state.productCount.toString(),
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

        // Display real recent activities
        state.recentActivities.isEmpty
            ? const Center(
          child: Text('No recent activity'),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.recentActivities.length,
          itemBuilder: (context, index) {
            final activity = state.recentActivities[index];

            // Determine icon and color based on activity type
            IconData icon;
            Color color;

            switch (activity['type']) {
              case 'customer':
                icon = Icons.person_add;
                color = Colors.blue;
                break;
              case 'quote':
                icon = Icons.description;
                color = Colors.green;
                break;
              case 'project':
                icon = Icons.build;
                color = Colors.orange;
                break;
              default:
                icon = Icons.notifications;
                color = Colors.grey;
            }

            // Calculate relative time
            final now = DateTime.now();
            final time = activity['time'];
            final difference = now.difference(time);

            String timeAgo;
            if (difference.inDays > 0) {
              timeAgo = '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
            } else if (difference.inHours > 0) {
              timeAgo = '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
            } else {
              timeAgo = '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
            }

            return _buildActivityItem(
              context,
              title: activity['title'],
              description: activity['description'],
              time: timeAgo,
              icon: icon,
              color: color,
            );
          },
        ),
      ],
    ),
  );
}