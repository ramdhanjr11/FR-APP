import 'package:flutter/material.dart';
import 'package:fr_app/db/databse_helper.dart';
import 'package:fr_app/locator.dart';

import '../models/user_model.dart';

class RegisteredFacesPage extends StatefulWidget {
  const RegisteredFacesPage({super.key});

  @override
  State<RegisteredFacesPage> createState() => _RegisteredFacesPageState();
}

class _RegisteredFacesPageState extends State<RegisteredFacesPage> {
  DatabaseHelper dbHelper = locator<DatabaseHelper>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Faces'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<User>>(
        future: dbHelper.queryAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }

          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            return ListView.builder(
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ListTile(
                  title: Text(user.user),
                  subtitle: Text(
                    user.modelData.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              itemCount: snapshot.data?.length,
            );
          }

          return const LinearProgressIndicator();
        },
      ),
    );
  }
}
