import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dar_al_fajr_portal/features/home/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
  ],
);
