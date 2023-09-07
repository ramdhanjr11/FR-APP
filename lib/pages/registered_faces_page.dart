import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/registered_user/registered_user_cubit.dart';

class RegisteredFacesPage extends StatefulWidget {
  const RegisteredFacesPage({super.key});

  @override
  State<RegisteredFacesPage> createState() => _RegisteredFacesPageState();
}

class _RegisteredFacesPageState extends State<RegisteredFacesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<RegisteredUserCubit>().getRegisteredUsers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Registered Faces'),
          centerTitle: true,
        ),
        body: BlocBuilder<RegisteredUserCubit, RegisteredUserState>(
          builder: (context, state) {
            if (state is RegisteredUserLoading) {
              return const LinearProgressIndicator();
            }

            if (state is RegisteredUserError) {
              return Center(
                child: Text('Error: ${state.message}'),
              );
            }

            if (state is RegisteredUserLoaded) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  final user = state.users?[index];
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(user?.user ?? 'Empty'),
                      subtitle: Text(
                        user?.modelData.toString() ?? 'Empty',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
                itemCount: state.users?.length,
              );
            }
            return Container();
          },
        ));
  }
}
