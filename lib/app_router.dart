import 'package:book_review_final/navigation/app_navigation.dart';
import 'package:book_review_final/screens/auth/login_screen.dart';
import 'package:book_review_final/screens/auth/register_screen.dart';
import 'package:book_review_final/screens/main/mybook_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation:
      FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
  routes: [
    GoRoute(
      path: '/main',
      builder: (context, state) {
        final tabIndex =
            int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
        return MainNavigation(initialTab: tabIndex);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => MainNavigation(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/mislibros',
      builder: (context, state) => MyBooksScreen(),
    )
  ],
  //redirect: (context, state) {
  //  if (!isAutenticate && state.fullPath != '/login') {
  //    return '/login';
  //  }
  //  return null;
  //},
);
