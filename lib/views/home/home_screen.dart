import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Removed import of app_constants.dart
import '../../view_models/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HomeViewModel>().fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: null, // Hide default app bar
      body: SafeArea( // Add SafeArea to handle notches and cutouts properly
        child: Column(
          children: [
            // Custom header similar to booking and explore screens
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF7FD957),
                    const Color(0xFF7FD957).withOpacity(0.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7FD957).withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Text(
                      'Trang chủ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content area
            Expanded(
              child: Consumer<HomeViewModel>(
                builder: (context, homeViewModel, child) {
                  if (homeViewModel.isLoading && homeViewModel.items.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: homeViewModel.refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0), // padding
                      itemCount: homeViewModel.items.length,
                      itemBuilder: (context, index) {
                        final item = homeViewModel.items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2196F3), // primaryColor
                              child: Text(
                                '${item['id']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              item['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(item['description']),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}