import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'live_safe.dart';
import 'relative_entry_page.dart';
import 'emergency_page.dart';
import 'alert.dart';
import 'risk.dart';
import 'manual.dart';
import 'auth/auth_service.dart';
import 'auth/login_screen.dart';
import 'dart:async';
import 'emergency_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController pageController;
  int pageNo = 0;
  Timer? carouselTimer;
  final EmergencyService _emergencyService = EmergencyService();

  final List<String> motivationalQuotes = [
    "A woman is the full circle. Within her is the power to create, nurture and transform. – Diane Mariechild",
    "The most courageous act is still to think for yourself. Aloud. – Coco Chanel",
    "You are more powerful than you know; you are beautiful just as you are. – Melissa Etheridge",
    "Women are the real architects of society. – Harriet Beecher Stowe"
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0, viewportFraction: 0.85);
    carouselTimer = getTimer();
    _emergencyService.initialize(context);
  }

  @override
  void dispose() {
    pageController.dispose();
    carouselTimer?.cancel();
    super.dispose();
  }

  Timer getTimer() {
    return Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pageNo == motivationalQuotes.length - 1) {
        pageNo = 0;
      } else {
        pageNo++;
      }
      pageController.animateToPage(
        pageNo,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOutCirc,
      );
    });
  }

  void _logout(BuildContext context) async {
    final auth = AuthService();
    await auth.signout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EmpowerHer',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ManualPage()));
        },
        backgroundColor: Colors.orange[600],
        child: const Icon(Icons.menu_book, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[300]!, Colors.blue[100]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildWelcomeCard(),
                const SizedBox(height: 20),
                _buildQuoteCarousel(),
                const SizedBox(height: 20),
                const LiveSafe(),
                const SizedBox(height: 20),
                _buildButtonGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[300]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/women_logo.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/women_logo.jpg'),
              ),
            ),
            title: Text(
              "Welcome Femme",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              "Stay safe and empowered!",
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                pageNo = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.blue[300],
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        motivationalQuotes[index],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
            itemCount: motivationalQuotes.length,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            motivationalQuotes.length,
            (index) => Container(
              margin: const EdgeInsets.all(3),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pageNo == index ? Colors.blue[600] : Colors.blue[200],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2, // Number of buttons in each row
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 5, // Adjust spacing between rows
            crossAxisSpacing: 5, // Adjust spacing between columns
            childAspectRatio: 1.3, // Adjusted the aspect ratio to reduce button size
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AlertPage()));
                },
                child:
                    _buildButtonCard(Icons.warning, 'Alert', Colors.red[600]!),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RiskPage()));
                },
                child: _buildButtonCard(
                    Icons.warning, 'Risk Assessment', Colors.orange[600]!),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RelativeEntryPage()));
                },
                child: _buildButtonCard(
                    Icons.group, 'Add Relatives', Colors.green[600]!),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EmergencyPage()));
                },
                child: _buildButtonCard(
                    Icons.call, 'Emergency', Colors.blue[600]!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonCard(IconData icon, String title, Color color) {
    return Card(
      elevation: 3, // Adjust elevation for button depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 35), // Smaller icon size
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
