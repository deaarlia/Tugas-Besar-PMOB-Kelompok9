import 'package:flutter/material.dart';
import 'package:unand_space/models/community.dart';
import 'package:unand_space/screens/community/community_form_screen.dart';

class EditCommunityScreen extends StatelessWidget {
  const EditCommunityScreen({super.key, required this.community});

  final Community community;

  @override
  Widget build(BuildContext context) => CommunityFormScreen(initial: community);
}
