import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_pmob/repositories/community_repository.dart';
import 'package:tugas_pmob/repositories/in_memory_community_repository.dart';
import 'package:tugas_pmob/screens/community/community_explore_screen.dart';
import 'package:tugas_pmob/theme/app_colors.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<CommunityRepository>(
      create: (_) => InMemoryCommunityRepository(),
      child: MaterialApp(
        title: 'UnandSpace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        home: const CommunityExploreScreen(),
      ),
    );
  }
}
