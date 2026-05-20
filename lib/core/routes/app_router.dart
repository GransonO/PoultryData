import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/camera/screens/camera_screen.dart';
import '../../features/gallery/screens/capture_detail_screen.dart';
import '../../features/gallery/screens/gallery_screen.dart';
import '../../features/home/screens/home_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isOnLogin = state.matchedLocation == '/';

        if (!isLoggedIn && !isOnLogin) return '/';
        if (isLoggedIn && isOnLogin) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/camera',
          builder: (_, __) => const CameraScreen(),
        ),
        GoRoute(
          path: '/gallery',
          builder: (_, __) => const GalleryScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) {
                final id = state.pathParameters['id']!;
                return CaptureDetailScreen(captureId: id);
              },
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri}'),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
