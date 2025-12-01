import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'providers/chat_provider.dart';
import 'providers/user_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const FoodAIApp());
}

class FoodAIApp extends StatelessWidget {
  const FoodAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate a unique user ID (in production, this would come from authentication)
    final userId = const Uuid().v4();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(userId: userId),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(userId: userId),
        ),
      ],
      child: MaterialApp(
        title: 'FoodAI Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFEA1D2C),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFEA1D2C),
            primary: const Color(0xFFEA1D2C),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFEA1D2C),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: const Color(0xFFEA1D2C),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
