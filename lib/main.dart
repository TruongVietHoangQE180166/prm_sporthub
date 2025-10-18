import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/home_view_model.dart';
import 'view_models/profile_view_model.dart';
import 'view_models/voucher_view_model.dart';
import 'view_models/order_view_model.dart';
import 'view_models/field_view_model.dart';
import 'view_models/team_view_model.dart';
import 'view_models/theme_view_model.dart';
import 'views/auth/login_screen.dart';
import 'views/main/main_screen.dart';
import 'views/find_team/find_team_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => VoucherViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => FieldViewModel()),
        ChangeNotifierProvider(create: (_) => TeamViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return MaterialApp(
            title: 'Flutter MVVM',
            debugShowCheckedModeBanner: false,
            theme: themeViewModel.lightTheme,
            darkTheme: themeViewModel.darkTheme,
            themeMode: themeViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            navigatorObservers: [FindTeamScreen.routeObserver],
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final FlutterSecureStorage _secureStorage;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _secureStorage = const FlutterSecureStorage();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Check if user data exists in secure storage
      final userId = await _secureStorage.read(key: 'userId');
      final username = await _secureStorage.read(key: 'username');
      final email = await _secureStorage.read(key: 'email');
      final accessToken = await _secureStorage.read(key: 'accessToken');

      setState(() {
        _isLoading = false;
        _isLoggedIn = userId != null && username != null && email != null && accessToken != null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isLoggedIn) {
      // Set user data in the AuthViewModel after widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeUserData(context);
      });
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }

  Future<void> _initializeUserData(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    // Read user data from secure storage
    final userId = await _secureStorage.read(key: 'userId');
    final username = await _secureStorage.read(key: 'username');
    final email = await _secureStorage.read(key: 'email');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    // Only set user data if all values are present
    if (userId != null && username != null && email != null && accessToken != null) {
      authViewModel.setUserFromStorage(userId, username, email, accessToken);
    }
  }
}