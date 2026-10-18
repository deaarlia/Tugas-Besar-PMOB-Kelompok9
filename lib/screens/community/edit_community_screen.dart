import 'package:flutter/material.dart';
import 'package:tugas_pmob/models/community.dart';
import 'package:tugas_pmob/screens/community/community_form_screen.dart';

class EditCommunityScreen extends StatelessWidget {
  const EditCommunityScreen({super.key, required this.community});

  final Community community;

  @override
  Widget build(BuildContext context) => CommunityFormScreen(initial: community);
}
