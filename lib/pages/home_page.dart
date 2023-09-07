import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fr_app/cubit/home_user/home_user_cubit.dart';
import 'package:fr_app/pages/liveness_camera_page.dart';
import 'package:fr_app/pages/register_face_page.dart';
import 'package:fr_app/pages/registered_faces_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeUserCubit cubit;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () async => context.read<HomeUserCubit>().initializeServices(),
    );
  }

  @override
  void dispose() {
    cubit.disposeServices();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cubit = BlocProvider.of<HomeUserCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition Research'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Information'),
                    content:
                        const Text('Do you want to remove all faces data?'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          cubit.deleteAllUsers();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Deleted users success'),
                            ),
                          );
                        },
                        child: const Text('Remove All'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: BlocBuilder<HomeUserCubit, HomeUserState>(
        builder: (context, state) {
          if (state is HomeUserInitial) return const LinearProgressIndicator();

          if (state is HomeUserLoading) return const LinearProgressIndicator();

          if (state is HomeUserHasInitialized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const LivenessCameraPage();
                          },
                        ),
                      );
                    },
                    child: const Text('Liveness Camera'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const RegisterFacePage();
                          },
                        ),
                      );
                    },
                    child: const Text('Register face'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const RegisteredFacesPage();
                          },
                        ),
                      );
                    },
                    child: const Text('List of registered faces'),
                  ),
                ],
              ),
            );
          }

          return const LinearProgressIndicator();
        },
      ),
    );
  }
}
