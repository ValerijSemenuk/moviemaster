import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moviemaster/presentation/blocs/theme_bloc/theme_bloc.dart';
class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: () {
            context.read<ThemeBloc>().add(ToggleThemeEvent());
          },
        );
      },
    );
  }
}