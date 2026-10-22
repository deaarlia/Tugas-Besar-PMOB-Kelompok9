import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unand_space/repositories/community_repository.dart';
import 'package:unand_space/repositories/in_memory_community_repository.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() => runApp(const UnandSpaceApp());

class UnandSpaceApp extends StatelessWidget {
  const UnandSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<CommunityRepository>(
      create: (_) => InMemoryCommunityRepository(),
      child: MaterialApp(
        title: 'UnandSpace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
  }
}
