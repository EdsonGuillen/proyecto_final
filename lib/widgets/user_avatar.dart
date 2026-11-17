import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  const UserAvatar({super.key, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final photo = user?.photoURL;
    final label = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email ?? '?');

    return CircleAvatar(
      radius: radius,
      backgroundImage: photo != null ? NetworkImage(photo) : null,
      child: photo == null
          ? Text(label[0].toUpperCase(), style: TextStyle(fontSize: radius))
          : null,
    );
  }
}