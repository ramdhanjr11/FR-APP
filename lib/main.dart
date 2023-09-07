import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fr_app/cubit/register_user/register_user_cubit.dart';
import 'package:fr_app/cubit/registered_user/registered_user_cubit.dart';

import 'locator.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RegisteredUserCubit(locator())),
        BlocProvider(
          create: (_) => RegisterUserCubit(
            locator(),
            locator(),
            locator(),
            locator(),
          ),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
