import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'database_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sqflite/sqflite.dart';

// Global variable to track current logged-in user
int? currentUserId;
String? currentUserName;
String? currentUserEmail;

// Splash Screen - Shows for 4 seconds with logo
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
    
    // Navigate to intro screen after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => IntroScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryGreen,
              AppColors.darkGreen,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.handshake,
                            size: 80,
                            color: AppColors.white,
                          );
                        },
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // App Name
                  Text(
                    'Etbara3',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Tagline
                  Text(
                    'Your Gateway to Making a Difference',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Intro Screen with Slideshow
class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late PageController _pageController;
  
  int _currentPage = 0;
  final int _numPages = 3;
  
  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Welcome to Etbara3',
      'subtitle': 'Your Gateway to Making a Difference',
      'description': 'Join our community of volunteers and donors who are changing lives every day.',
      'icon': Icons.favorite,
    },
    {
      'title': 'Volunteer & Donate',
      'subtitle': 'Multiple Ways to Help',
      'description': 'Choose from volunteering opportunities, medical donations, or financial contributions.',
      'icon': Icons.volunteer_activism,
    },
    {
      'title': 'Track Your Impact',
      'subtitle': 'See Your Progress',
      'description': 'Monitor your donations, volunteering activities, and the positive impact you\'re making.',
      'icon': Icons.trending_up,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginSignupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _numPages,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
                physics: BouncingScrollPhysics(),
                pageSnapping: true,
              ),
            ),
            
            // Page Indicators
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_numPages, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.white : AppColors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            
            // Navigation Buttons
            Container(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  // Previous Button
                  if (_currentPage > 0)
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  
                  // Next/Get Started Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentPage == _numPages - 1 ? 'Get Started' : 'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> slide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          
          // Logo/Icon - Bigger and at top
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: slide['title'] == 'Welcome to Etbara3' 
              ? Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Icon(
                          Icons.handshake,
                          size: 80,
                          color: AppColors.white,
                        );
                      },
                    ),
                  ),
                )
              : Icon(
                  slide['icon'],
                  size: 80,
                  color: AppColors.white,
                ),
          ),
          
          SizedBox(height: 60),
          
          // Title
          Text(
            slide['title'],
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 16),
          
          // Subtitle
          Text(
            slide['subtitle'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 24),
          
          // Description
          Text(
            slide['description'],
            style: TextStyle(
              fontSize: 16,
              color: AppColors.white.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Modern color scheme inspired by the logo
class AppColors {
  static const Color primaryGreen = Color(0xFF1B5E20); // Darker main green
  static const Color darkGreen = Color(0xFF0D4B14); // Even darker green for logo
  static const Color lightGreen = Color(0xFF2E7D32); // Darker light green
  static const Color accentGreen = Color(0xFF388E3C); // Darker accent green
  static const Color backgroundGreen = Color(0xFFE8F5E8);
  static const Color textDark = Color(0xFF0D4B14); // Darker text
  static const Color textLight = Color(0xFF1B5E20); // Darker medium text
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFF5F5F5);
}

// Modern text styles
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.gray,
  );
}

// Modern button styles
class AppButtonStyles {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: AppColors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    elevation: 2,
  );
  
  static ButtonStyle secondary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.lightGreen,
    foregroundColor: AppColors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    elevation: 1,
  );
  
  static ButtonStyle outline = ElevatedButton.styleFrom(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.primaryGreen,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: AppColors.primaryGreen, width: 2),
    ),
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    elevation: 0,
  );
}

// Modern input decoration
InputDecoration modernInputDecoration(String label, IconData icon, {String? errorText}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: AppColors.textDark),
    prefixIcon: Icon(icon, color: AppColors.primaryGreen),
    filled: true,
    fillColor: AppColors.backgroundGreen,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.lightGreen),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.lightGreen),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
    ),
    errorText: errorText,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

// Modern card style
class AppCardStyle {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
}

// Helper function to get progress bar color based on completion percentage
Color getProgressBarColor(double progress) {
  double percentage = progress * 100;
  if (percentage < 25) {
    return Colors.red;
  } else if (percentage < 50) {
    return Colors.orange;
  } else if (percentage < 75) {
    return Colors.yellow;
  } else {
    return Colors.green;
  }
}



Future<void> showAddDialog(BuildContext context, String title, String nameLabel, String amountLabel, {bool isEvent = false, bool isProject = false, Function? onAdded}) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController? descController = (isEvent || isProject) ? TextEditingController() : null;
  final TextEditingController? locationController = isEvent ? TextEditingController() : null;
  final TextEditingController? equipmentController = isEvent ? TextEditingController() : null;
  String? errorText;
  List<String> uploadedFiles = []; // Store uploaded file names
  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Fields marked with * are required',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '$nameLabel *'),
            ),
            SizedBox(height: 16),
            if (isEvent || isProject) ...[
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: '${isEvent ? 'Description' : 'Illness/Description'} *'),
                maxLines: 2,
              ),
              SizedBox(height: 16),
            ],
            if (isProject) ...[
            Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGreen),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.backgroundGreen,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Documents (PDF)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (uploadedFiles.isNotEmpty) ...[
                      ...uploadedFiles.map((fileName) => Padding(
                        padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                          children: [
                            Icon(Icons.description, color: AppColors.primaryGreen, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fileName,
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 16, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  uploadedFiles.remove(fileName);
                                });
                              },
                            ),
                          ],
                        ),
                      )),
                      SizedBox(height: 8),
                    ],
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                            allowMultiple: true,
                          );
                          if (result != null) {
                            setState(() {
                              uploadedFiles.addAll(result.files.map((file) => file.name));
                            });
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error picking files: $e')),
                          );
                        }
                      },
                      icon: Icon(Icons.upload_file, size: 16),
                      label: Text('Select PDF Files'),
                      style: AppButtonStyles.outline.copyWith(
                        minimumSize: WidgetStateProperty.all(Size(double.infinity, 40)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            if (isEvent) ...[
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location *'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: equipmentController,
                decoration: InputDecoration(
                  labelText: 'Equipment needed (optional)',
                  hintText: 'Leave empty if no equipment needed',
                ),
              ),
              SizedBox(height: 16),
            ],
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: '$amountLabel *',
                hintText: isEvent ? 'Enter number of volunteers' : 'Enter amount in dollars',
              ),
              keyboardType: TextInputType.number,
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(errorText!, style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              print('Add button pressed - isEvent: $isEvent, isProject: $isProject');
              if (isEvent) {
                print('Validating event fields...');
                if (nameController.text.trim().isEmpty || descController!.text.trim().isEmpty || locationController!.text.trim().isEmpty || amountController.text.trim().isEmpty) {
                  print('Event validation failed');
                  setState(() => errorText = 'Please fill in all required fields.');
                  return;
                }
                // Validate that volunteers needed is a valid number
                final volunteers = int.tryParse(amountController.text);
                if (volunteers == null || volunteers <= 0) {
                  print('Event validation failed - invalid volunteers number');
                  setState(() => errorText = 'Please enter a valid number of volunteers needed.');
                  return;
                }
                print('Event validation passed, inserting event...');
                await DatabaseHelper().insertEvent({
                  'name': nameController.text,
                  'activity': descController.text,
                  'volunteers': volunteers,
                  'signedUp': 0,
                  'location': locationController.text,
                  'equipment': equipmentController!.text.trim().isEmpty ? 'None' : equipmentController!.text,
                });
                print('Event inserted successfully');
                if (onAdded != null) onAdded();
              } else if (isProject) {
                if (nameController.text.trim().isEmpty || descController!.text.trim().isEmpty || amountController.text.trim().isEmpty) {
                  setState(() => errorText = 'Please fill in all required fields.');
                  return;
                }
                // Validate that amount needed is a valid number
                final amount = int.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  setState(() => errorText = 'Please enter a valid amount needed.');
                  return;
                }
                await DatabaseHelper().insertProject({
                  'name': nameController.text,
                  'illness': descController!.text,
                  'description': descController.text,
                  'amount': amount,
                  'collected': 0,
                  'documents': uploadedFiles.join(','), // Store file names as comma-separated string
                });
                if (onAdded != null) onAdded();
              }
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showPlanDialog(BuildContext context, List<String> organizations) async {
  String? selectedOrg = organizations.isNotEmpty ? organizations[0] : null;
  String? selectedFreq = 'Daily';
  final TextEditingController amountController = TextEditingController();
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Make a Donation Plan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedOrg,
            items: organizations
                .map((org) => DropdownMenuItem(value: org, child: Text(org)))
                .toList(),
            onChanged: (val) => selectedOrg = val,
            decoration: InputDecoration(labelText: 'Organization'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: amountController,
            decoration: InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedFreq,
            items: ['Daily', 'Weekly', 'Monthly', 'Annually']
                .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
                .toList(),
            onChanged: (val) => selectedFreq = val,
            decoration: InputDecoration(labelText: 'Frequency'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            print('Plan: Org = $selectedOrg, Amount = ${amountController.text}, Freq = $selectedFreq');
            Navigator.of(context).pop();
          },
          child: Text('Create'),
        ),
      ],
    ),
  );
}

class ChooseOrganizationScreen extends StatefulWidget {
  @override
  _ChooseOrganizationScreenState createState() => _ChooseOrganizationScreenState();
}

class _ChooseOrganizationScreenState extends State<ChooseOrganizationScreen> {
  final List<Map<String, String>> organizations = [
    {'name': 'Bait El Zakat w El Sadakat', 'icon': '🏛️'},
    {'name': '57357 Children Cancer Hospital', 'icon': '⛵'},
    {'name': 'Magdi Yacoub Heart Foundation', 'icon': '❤️'},
    {'name': 'Misr El Kheir Foundation', 'icon': '🟩'},
    {'name': 'Baheya Zayed Hospital', 'icon': '🏥'},
    {'name': 'Egyptian Food Bank', 'icon': '🍞'},
    {'name': 'Resala Charity Organization', 'icon': '🤲'},
    {'name': 'Ahl Masr Foundation', 'icon': '🌟'},
    {'name': 'Orman Charity Association', 'icon': '🌳'},
    {'name': 'Al Nas Hospital', 'icon': '🏨'},
    {'name': 'Tanta Cancer Center', 'icon': '🧬'},
            {'name': 'Children\'s Cancer Hospital Foundation', 'icon': '👶'},
    {'name': 'Cairo University Hospitals', 'icon': '🏫'},
    {'name': 'Dar Al-Orman Hospital', 'icon': '🏩'},
    {'name': 'Egyptian Cure Bank', 'icon': '💊'},
  ];
  String search = '';
  TextEditingController searchController = TextEditingController();

  List<Map<String, String>> get filteredOrgs {
    if (search.isEmpty) return organizations;
    return organizations
        .where((org) => org['name']!.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Organization', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
            Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                  Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    child: Row(
                        children: [
                        Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: AppColors.primaryGreen,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Organization',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Choose where your donation will make the most impact',
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Search Bar
                  Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (val) => setState(() => search = val),
                        decoration: InputDecoration(
                          hintText: 'Search organizations...',
                          hintStyle: TextStyle(color: AppColors.textLight),
                          prefixIcon: Icon(Icons.search, color: AppColors.primaryGreen),
                          filled: true,
                          fillColor: AppColors.backgroundGreen,
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.lightGreen),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.lightGreen),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Organizations List
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: filteredOrgs.isEmpty
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColors.textLight,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No organizations found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try adjusting your search terms',
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(top: 16, bottom: 24),
                          itemCount: filteredOrgs.length,
                          itemBuilder: (context, idx) {
                            final org = filteredOrgs[idx];
                            return _buildOrganizationCard(org);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationCard(Map<String, String> org) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.backgroundGreen, width: 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              org['icon'] ?? '🏛️',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          org['name']!,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          'Tap to donate',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primaryGreen,
            size: 16,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => DonateToOrganizationScreen(orgName: org['name']!),
          ));
        },
      ),
    );
  }
}

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  bool loading = true;
  String selectedFilter = 'All';
  List<String> selectedLocationFilters = ['All'];
  String selectedVolunteerFilter = 'All';
  final List<String> filterOptions = ['All', 'Available', 'Full'];
  final List<String> locationFilterOptions = ['All', 'Dokki', 'Tagamo3', 'Maadi', 'Zayed', 'Giza', 'Mokattam', 'October', 'Agouza', 'Rehab'];
  final List<String> volunteerFilterOptions = ['All', '1-5', '6-10', '11-20', '20+'];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await DatabaseHelper().insertDefaultData();
    final data = await DatabaseHelper().getEvents();
    setState(() {
      events = data;
      _applyFilter();
      loading = false;
    });
  }

  void _applyFilter() {
    setState(() {
      List<Map<String, dynamic>> tempEvents = events;

      // Apply status filter
      switch (selectedFilter) {
        case 'Available':
          tempEvents = tempEvents.where((e) {
            final signedUp = e['signedUp'] ?? 0;
            final volunteers = e['volunteers'] ?? 0;
            return signedUp < volunteers;
          }).toList();
          break;
        case 'Full':
          tempEvents = tempEvents.where((e) {
            final signedUp = e['signedUp'] ?? 0;
            final volunteers = e['volunteers'] ?? 0;
            return signedUp >= volunteers;
          }).toList();
          break;
        default:
          break;
      }

      // Apply location filter
      if (!selectedLocationFilters.contains('All')) {
        tempEvents = tempEvents.where((e) {
          final location = e['location'] ?? '';
          return selectedLocationFilters.any((filter) => 
            location.toLowerCase().contains(filter.toLowerCase())
          );
        }).toList();
      }

      // Apply remaining volunteers filter
      if (selectedVolunteerFilter != 'All') {
        tempEvents = tempEvents.where((e) {
          final volunteers = e['volunteers'] ?? 0;
          final signedUp = e['signedUp'] ?? 0;
          final remaining = volunteers - signedUp;
          switch (selectedVolunteerFilter) {
            case '1-5':
              return remaining >= 1 && remaining <= 5;
            case '6-10':
              return remaining >= 6 && remaining <= 10;
            case '11-20':
              return remaining >= 11 && remaining <= 20;
            case '20+':
              return remaining > 20;
            default:
              return true;
          }
        }).toList();
      }

      filteredEvents = tempEvents;
    });
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Filter Events'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: filterOptions.map((option) => ChoiceChip(
                  label: Text(option),
                  selected: selectedFilter == option,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => selectedFilter = option);
                    }
                  },
                )).toList(),
              ),
              SizedBox(height: 16),
              Text('Location:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: locationFilterOptions.map((option) => ChoiceChip(
                  label: Text(option),
                  selected: selectedLocationFilters.contains(option),
                  onSelected: (selected) {
                    setState(() {
                      if (option == 'All') {
                        if (selected) {
                          selectedLocationFilters = ['All'];
                        }
                      } else {
                        if (selected) {
                          selectedLocationFilters.remove('All');
                          selectedLocationFilters.add(option);
                        } else {
                          selectedLocationFilters.remove(option);
                          if (selectedLocationFilters.isEmpty) {
                            selectedLocationFilters = ['All'];
                          }
                        }
                      }
                    });
                  },
                )).toList(),
              ),
              SizedBox(height: 16),
              Text('Remaining Spaces:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: volunteerFilterOptions.map((option) => ChoiceChip(
                  label: Text(option),
                  selected: selectedVolunteerFilter == option,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => selectedVolunteerFilter = option);
                    }
                  },
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedFilter = 'All';
                  selectedLocationFilters = ['All'];
                  selectedVolunteerFilter = 'All';
                });
              },
              child: Text('Reset'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {
                  _applyFilter();
                });
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showVolunteerDialog(Map<String, dynamic> event) async {
    final TextEditingController numberController = TextEditingController();
    final maxVolunteers = (event['volunteers'] ?? 0) - (event['signedUp'] ?? 0);
    String? errorText;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Volunteer for ${event['name']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remaining spots: $maxVolunteers', style: TextStyle(fontSize: 14, color: Colors.blueGrey[700])),
                SizedBox(height: 8),
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of volunteers',
                    hintText: 'Enter number to volunteer',
                    errorText: errorText,
                  ),
                  onChanged: (_) {
                    if (errorText != null) setState(() => errorText = null);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final entered = int.tryParse(numberController.text) ?? 0;
                  if (entered <= 0) {
                    setState(() => errorText = 'Please enter a valid number.');
                    return;
                  }
                  if (entered > maxVolunteers) {
                    setState(() => errorText = 'Cannot exceed remaining spots.');
                    return;
                  }
                  final newSignedUp = (event['signedUp'] ?? 0) + entered;
                  await DatabaseHelper().insertEvent({
                    ...event,
                    'signedUp': newSignedUp,
                  });
                  
                  // Save user volunteering activity
                  await DatabaseHelper().insertUserVolunteering({
                    'user_id': currentUserId!,
                    'event_name': event['name'],
                    'event_activity': event['activity'],
                    'volunteers_count': entered,
                    'volunteer_date': DateTime.now().toIso8601String(),
                  });
                  
                  Navigator.of(context).pop();
                  await _loadEvents();
                },
                child: Text('Volunteer'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Events', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list, color: AppColors.white),
              onPressed: () => _showFilterDialog(),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading events...',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : filteredEvents.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No events found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or add a new event',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                      Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        child: Row(
                            children: [
                            Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.volunteer_activism,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Volunteer Opportunities',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${filteredEvents.length} events available',
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        // Events List
                        ...filteredEvents.map((e) => _buildEventCard(e)).toList(),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.darkGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, color: AppColors.white, size: 28),
          onPressed: () {
            showAddDialog(context, 'Add Event', 'Event Name', 'Volunteers Needed', isEvent: true, onAdded: _loadEvents);
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final int signedUp = event['signedUp'] ?? 0;
    final int volunteers = event['volunteers'] ?? 1;
    final double progress = (signedUp / volunteers).clamp(0.0, 1.0);
    final bool isFull = signedUp >= volunteers;
    final int remaining = volunteers - signedUp;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        event['activity'],
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFull ? Colors.red.withOpacity(0.1) : AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isFull ? Colors.red.withOpacity(0.3) : AppColors.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    isFull ? 'Full' : '$remaining spots left',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isFull ? Colors.red : AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Details
            _buildDetailRow(Icons.location_on, 'Location', event['location'] ?? 'Not specified'),
            SizedBox(height: 12),
            _buildDetailRow(Icons.build, 'Equipment', event['equipment'] ?? 'None'),
            SizedBox(height: 20),
            
            // Progress Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '$signedUp / $volunteers volunteers',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.lightGreen.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(getProgressBarColor(progress)),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Action Button
            SizedBox(
      width: double.infinity,
              height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
                  backgroundColor: isFull ? Colors.grey : AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: isFull ? 0 : 2,
                ),
                onPressed: isFull ? null : () => _showVolunteerDialog(event),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFull ? Icons.block : Icons.volunteer_activism,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isFull ? 'Event Full' : 'Volunteer Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primaryGreen,
        ),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ),
      ],
    );
  }
}

class ProjectsScreen extends StatefulWidget {
  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Map<String, dynamic>> cases = [];
  List<Map<String, dynamic>> filteredCases = [];
  bool loading = true;
  String selectedFilter = 'All';
  final List<String> filterOptions = ['All', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    await DatabaseHelper().insertDefaultData();
    final data = await DatabaseHelper().getProjects();
    setState(() {
      cases = data;
      _applyFilter();
      loading = false;
    });
  }

  void _applyFilter() {
    setState(() {
      switch (selectedFilter) {
        case 'In Progress':
          filteredCases = cases.where((c) {
            final collected = c['collected'] ?? 0;
            final amount = c['amount'] ?? 0;
            return collected < amount;
          }).toList();
          break;
        case 'Completed':
          filteredCases = cases.where((c) {
            final collected = c['collected'] ?? 0;
            final amount = c['amount'] ?? 0;
            return collected >= amount;
          }).toList();
          break;
        default:
          filteredCases = cases;
      }
    });
  }

  Future<void> _showDonateDialog(Map<String, dynamic> project) async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController cardNumberController = TextEditingController();
    final TextEditingController cardNameController = TextEditingController();
    final TextEditingController expiryController = TextEditingController();
    final TextEditingController cvvController = TextEditingController();
    final TextEditingController pickupAddressController = TextEditingController();
    
    final maxAmount = (project['amount'] ?? 0) - (project['collected'] ?? 0);
    String? errorText;
    String selectedPaymentMethod = 'Card'; // 'Card' or 'Pickup'
    DateTime? pickupDate;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
                Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header with back button
                        Row(
                          children: [
                            // Back Button
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  size: 32,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                            // Empty space for balance
                            SizedBox(width: 36),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          project['name'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your donation will make a real difference',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                      Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                          ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Remaining needed: \$${maxAmount}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form Container
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Amount Field
                            _buildFormField(
                              controller: amountController,
                              label: 'Donation Amount *',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              hint: 'Enter amount in dollars',
                              errorText: errorText,
                              onChanged: (_) { if (errorText != null) setState(() => errorText = null); },
                            ),
                            SizedBox(height: 24),
                            
                            // Payment Method Selection
                            Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPaymentMethodButton(
                                    title: 'Pay by Card',
                                    icon: Icons.credit_card,
                                    isSelected: selectedPaymentMethod == 'Card',
                                    onTap: () => setState(() => selectedPaymentMethod = 'Card'),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildPaymentMethodButton(
                                    title: 'Pay by Pickup',
                                    icon: Icons.location_on,
                                    isSelected: selectedPaymentMethod == 'Pickup',
                                    onTap: () => setState(() => selectedPaymentMethod = 'Pickup'),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            
                            // Payment Details
                            if (selectedPaymentMethod == 'Card') ...[
                              // Card Details Section
                              Text(
                                'Card Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 16),
                              _buildFormField(
                                controller: cardNumberController,
                                label: 'Card Number *',
                                icon: Icons.credit_card,
                                keyboardType: TextInputType.number,
                                hint: '1234 5678 9012 3456',
                              ),
                              SizedBox(height: 16),
                              _buildFormField(
                                controller: cardNameController,
                                label: 'Cardholder Name *',
                                icon: Icons.person,
                                hint: 'John Doe',
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormField(
                                      controller: expiryController,
                                      label: 'Expiry (MM/YY) *',
                                      icon: Icons.calendar_today,
                                      hint: '12/25',
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFormField(
                                      controller: cvvController,
                                      label: 'CVV *',
                                      icon: Icons.security,
                                      keyboardType: TextInputType.number,
                                      hint: '123',
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (selectedPaymentMethod == 'Pickup') ...[
                              // Pickup Details Section
                              Text(
                                'Pickup Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 16),
                              _buildFormField(
                                controller: pickupAddressController,
                                label: 'Pickup Address *',
                                icon: Icons.location_on,
                                hint: 'Enter your address for pickup',
                              ),
                              SizedBox(height: 16),
                            Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: pickupDate != null ? AppColors.primaryGreen : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: pickupDate != null ? AppColors.primaryGreen : AppColors.lightGreen,
                                    width: 2,
                                  ),
                                  boxShadow: pickupDate != null ? [
                                    BoxShadow(
                                      color: AppColors.primaryGreen.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ] : null,
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () async {
                                    final now = DateTime.now();
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: now,
                                      firstDate: now,
                                      lastDate: now.add(Duration(days: 365)),
                                    );
                                    if (picked != null) {
                                      setState(() => pickupDate = picked);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.calendar_today,
                                    color: pickupDate != null ? AppColors.white : AppColors.primaryGreen,
                                    size: 20,
                                  ),
                                  label: Text(
                                    pickupDate == null 
                                        ? 'Choose pickup date *' 
                                        : 'Pickup: ${pickupDate!.toLocal().toString().split(" ")[0]}',
                                    style: TextStyle(
                                      color: pickupDate == null ? AppColors.white : AppColors.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            
                            SizedBox(height: 32),
                            // Submit Button
                          Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primaryGreen, AppColors.darkGreen],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  final entered = int.tryParse(amountController.text) ?? 0;
                                  if (entered <= 0) {
                                    setState(() => errorText = 'Please enter a valid amount.');
                                    return;
                                  }
                                  if (entered > maxAmount) {
                                    setState(() => errorText = 'Cannot exceed remaining money needed.');
                                    return;
                                  }
                                  
                                  // Validate required fields based on payment method
                                  if (selectedPaymentMethod == 'Card') {
                                    if (cardNumberController.text.trim().isEmpty || 
                                        cardNameController.text.trim().isEmpty || 
                                        expiryController.text.trim().isEmpty || 
                                        cvvController.text.trim().isEmpty) {
                                      setState(() => errorText = 'Please fill in all card details.');
                                      return;
                                    }
                                  } else if (selectedPaymentMethod == 'Pickup') {
                                    if (pickupAddressController.text.trim().isEmpty || pickupDate == null) {
                                      setState(() => errorText = 'Please fill in pickup address and date.');
                                      return;
                                    }
                                  }
                                  
                                  final newCollected = (project['collected'] ?? 0) + entered;
                                  await DatabaseHelper().insertProject({
                                    ...project,
                                    'collected': newCollected,
                                  });
                                  
                                  // Save user project donation activity
                                  await DatabaseHelper().insertUserProjectDonation({
                                    'user_id': currentUserId!,
                                    'project_name': project['name'],
                                    'project_illness': project['illness'],
                                    'amount': entered,
                                    'donation_date': DateTime.now().toIso8601String(),
                                  });
                                  
                                  Navigator.of(context).pop();
                                  await _loadCases();
                                  
                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Thank you for your donation!'),
                                      backgroundColor: AppColors.primaryGreen,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.favorite, color: AppColors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Complete Donation',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16), // Extra padding at bottom for scroll
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? errorText,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorText != null ? Colors.red.withOpacity(0.3) : AppColors.lightGreen,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textDark),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorText: errorText,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGreen,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.primaryGreen,
              size: 18,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Cases', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.filter_list, color: AppColors.white),
              onSelected: (String value) {
                setState(() {
                  selectedFilter = value;
                  _applyFilter();
                });
              },
              itemBuilder: (BuildContext context) {
                return filterOptions.map((String option) {
                  return PopupMenuItem<String>(
                    value: option,
                  child: Row(
                      children: [
                        if (selectedFilter == option)
                          Icon(Icons.check, color: AppColors.primaryGreen, size: 20),
                        SizedBox(width: 8),
                        Text(option),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading cases...',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : filteredCases.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No cases found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or add a new case',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                      Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        child: Row(
                            children: [
                            Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.medical_services,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Medical Cases',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${filteredCases.length} cases need your help',
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        // Cases List
                        ...filteredCases.map((c) => _buildCaseCard(c)).toList(),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.darkGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, color: AppColors.white, size: 28),
          onPressed: () {
            showAddDialog(context, 'Add Case', 'Case Name', 'Amount Needed', isProject: true, onAdded: _loadCases);
          },
        ),
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> caseData) {
    final int collected = caseData['collected'] ?? 0;
    final int amount = caseData['amount'] ?? 1;
    final double progress = (collected / amount).clamp(0.0, 1.0);
    final bool isCompleted = collected >= amount;
    final int remaining = amount - collected;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseData['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        caseData['illness'],
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primaryGreen.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted ? AppColors.primaryGreen.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : '\$${remaining} needed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? AppColors.primaryGreen : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Description
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                caseData['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Documents Section
            if (caseData['documents'] != null && caseData['documents'].toString().isNotEmpty) ...[
            Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGreen),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: AppColors.primaryGreen, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Documents',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ...(caseData['documents'].toString().split(',')..removeWhere((s) => s.isEmpty)).map((fileName) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileName.trim(),
                              style: TextStyle(fontSize: 12, color: AppColors.textDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
            
            // Progress Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '\$${collected} / \$${amount} collected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.lightGreen.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(getProgressBarColor(progress)),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey : AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: isCompleted ? 0 : 2,
                ),
                onPressed: isCompleted ? null : () => _showDonateDialog(caseData),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.favorite,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isCompleted ? 'Case Completed' : 'Help Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChooseOptionScreen extends StatefulWidget {
  @override
  _ChooseOptionScreenState createState() => _ChooseOptionScreenState();
}

class _ChooseOptionScreenState extends State<ChooseOptionScreen> {
  DateTime? _lastTapTime;
  static const Duration _doubleTapTime = Duration(milliseconds: 300);
  bool _hasShownFirstMessage = false;
  
  @override
  void initState() {
    super.initState();
    // Check if user is logged in
    if (currentUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginSignupScreen()),
        );
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
              Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back, ${currentUserName ?? 'User'}!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Choose how you\'d like to make a difference today',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Main Options Grid
                Expanded(
                  child: Column(
                    children: [
                      // Top row with Donation and Projects
                      Expanded(
                        flex: 1,
                      child: Row(
                          children: [
                            Expanded(
                              child: _buildMenuCard(
                                icon: Icons.favorite,
                                title: 'Donation',
                                subtitle: 'Support causes',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => DonationTypeScreen()),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: _buildMenuCard(
                                icon: Icons.medical_services,
                                title: 'Projects',
                                subtitle: 'Medical cases',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => ProjectsScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Bottom row with Events centered
                      Expanded(
                        flex: 1,
                      child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(), // Left spacer
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildMenuCard(
                                icon: Icons.volunteer_activism,
                                title: 'Events',
                                subtitle: 'Volunteer',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => EventsScreen()),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: SizedBox(), // Right spacer
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Bottom Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.history,
                        title: 'My Activity',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => MyActivityScreen()),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.support_agent,
                        title: 'Support',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Support feature coming soon!')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Logout Button
                _buildActionButton(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    // Clear current user data
                    currentUserId = null;
                    currentUserName = null;
                    currentUserEmail = null;
                    
                    // Navigate back to login screen
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginSignupScreen()),
                      (route) => false,
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logged out successfully'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primaryGreen,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyActivityScreen extends StatefulWidget {
  @override
  _MyActivityScreenState createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _donations = [];
  List<Map<String, dynamic>> _volunteering = [];
  List<Map<String, dynamic>> _projectDonations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserActivity();
  }

  Future<void> _loadUserActivity() async {
    // Use the current logged-in user's ID
    final userId = currentUserId ?? 1;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final donations = await DatabaseHelper().getUserDonations(userId);
      final volunteering = await DatabaseHelper().getUserVolunteering(userId);
      final projectDonations = await DatabaseHelper().getUserProjectDonations(userId);

      setState(() {
        _donations = donations;
        _volunteering = volunteering;
        _projectDonations = projectDonations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Activity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Top navigation buttons
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedIndex == 0 ? AppColors.primaryGreen : AppColors.lightGray,
                        foregroundColor: _selectedIndex == 0 ? AppColors.white : AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      child: Text(
                        'Donations', 
                        style: TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedIndex == 1 ? AppColors.primaryGreen : AppColors.lightGray,
                        foregroundColor: _selectedIndex == 1 ? AppColors.white : AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: Text(
                        'Events', 
                        style: TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedIndex == 2 ? AppColors.primaryGreen : AppColors.lightGray,
                        foregroundColor: _selectedIndex == 2 ? AppColors.white : AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                      child: Text(
                        'Projects', 
                        style: TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDonationsContent();
      case 1:
        return _buildEventsContent();
      case 2:
        return _buildProjectsContent();
      default:
        return Container();
    }
  }

  Widget _buildDonationsContent() {
    if (_donations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('😢', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('Still no donations', style: TextStyle(fontSize: 18, color: AppColors.textDark)),
            SizedBox(height: 24),
            ElevatedButton(
              style: AppButtonStyles.primary.copyWith(
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DonationTypeScreen()),
                );
              },
              child: Text('Start Donating', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _donations.length,
      itemBuilder: (context, index) {
        final donation = _donations[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      donation['donation_type'] == 'Money' ? Icons.attach_money : Icons.checkroom,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        donation['donation_type'] == 'Money' ? 'Money Donation' : 'Clothes Donation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('Organization: ${donation['organization_name'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                if (donation['donation_type'] == 'Money') ...[
                  Text('Amount: \$${donation['amount'] ?? 0}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                ] else ...[
                  Text('Items: ${donation['items_count'] ?? 0}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                  Text('Pickup Address: ${donation['pickup_address'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                  Text('Pickup Date: ${donation['pickup_date'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                ],
                SizedBox(height: 8),
                Text('Date: ${donation['donation_date'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsContent() {
    if (_volunteering.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('😢', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('Still no volunteering', style: TextStyle(fontSize: 18, color: AppColors.textDark)),
            SizedBox(height: 24),
            ElevatedButton(
              style: AppButtonStyles.primary.copyWith(
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EventsScreen()),
                );
              },
              child: Text('Start Volunteering', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _volunteering.length,
      itemBuilder: (context, index) {
        final volunteer = _volunteering[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.volunteer_activism, color: AppColors.primaryGreen, size: 24),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Volunteered',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('Event: ${volunteer['event_name'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                Text('Activity: ${volunteer['event_activity'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                Text('Volunteers Count: ${volunteer['volunteers_count'] ?? 0}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                SizedBox(height: 8),
                Text('Date: ${volunteer['volunteer_date'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectsContent() {
    if (_projectDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('😢', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('Still no project donations', style: TextStyle(fontSize: 18, color: AppColors.textDark)),
            SizedBox(height: 24),
            ElevatedButton(
              style: AppButtonStyles.primary.copyWith(
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProjectsScreen()),
                );
              },
              child: Text('Start Helping', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _projectDonations.length,
      itemBuilder: (context, index) {
        final projectDonation = _projectDonations[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, color: AppColors.primaryGreen, size: 24),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Project Donation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('Project: ${projectDonation['project_name'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                Text('Illness: ${projectDonation['project_illness'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                Text('Amount: \$${projectDonation['amount'] ?? 0}', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                SizedBox(height: 8),
                Text('Date: ${projectDonation['donation_date'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+1';
  bool _isLogin = true;
  bool _useDatePicker = true;

  String? _emailError;
  String? _passwordError;
  String? _generalError;
  String? _reenterPasswordError;

  bool _showPassword = false;
  bool _showReenterPassword = false;

  final LocalAuthentication _localAuth = LocalAuthentication();
  final GoogleSignIn _googleSignIn = GoogleSignIn();



  Future<void> _selectDateOfBirth() async {
    DateTime selectedDate = DateTime.now().subtract(Duration(days: 6570)); // 18 years ago
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDatePickerDialog(
          initialDate: selectedDate,
          onDateSelected: (DateTime date) {
            setState(() {
              _dateOfBirthController.text = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
            });
          },
        );
      },
    );
  }

  void _toggleFormMode() {
    setState(() {
      _isLogin = !_isLogin;
      _emailError = null;
      _passwordError = null;
      _generalError = null;
      _reenterPasswordError = null;
    });
  }

  bool _validateEmail(String email) {
    // Simple regex for email validation
    final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+");
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    // At least 8 chars, one uppercase, one special char
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$&*~%^()_+=\-\[\]{};:\",.<>/?\\|]'));
    return password.length >= 8 && hasUpper && hasSpecial;
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
      _reenterPasswordError = null;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final reenterPassword = _reenterPasswordController.text;
    bool valid = true;
    // Check required fields
    if (_isLogin) {
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _generalError = 'Please fill in all required fields.';
        });
        return;
      }
    } else {
      if (email.isEmpty || password.isEmpty || _nameController.text.trim().isEmpty || _addressController.text.trim().isEmpty || _dateOfBirthController.text.trim().isEmpty) {
        setState(() {
          _generalError = 'Please fill in all required fields.';
        });
        return;
      }
      if (_phoneController.text.trim().isEmpty) {
        setState(() {
          _generalError = 'Please fill in all required fields.';
        });
        return;
      }
      if (password != reenterPassword) {
        setState(() {
          _reenterPasswordError = 'Passwords do not match.';
        });
        valid = false;
      }
    }
    if (!_validateEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address.';
      });
      valid = false;
    }
    if (_isLogin) {
      if (!valid) return;
      final user = await DatabaseHelper().getUserByEmailAndPassword(email, password);
      if (user == null) {
        setState(() {
          _generalError = 'Invalid email or password.';
        });
        return;
      }
      // Store current user information
      currentUserId = user['id'];
      currentUserName = user['name'];
      currentUserEmail = user['email'];
      
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ChooseOptionScreen()),
      );
    } else {
      if (!_validatePassword(password)) {
        setState(() {
          _passwordError = 'Password must be at least 8 characters, include a capital letter and a special character.';
        });
        valid = false;
      }
      if (!valid) return;
      final existing = await DatabaseHelper().getUserByEmail(email);
      if (existing != null) {
        setState(() {
          _generalError = 'An account with this email already exists.';
        });
        return;
      }
      final userId = await DatabaseHelper().insertUser({
        'name': _nameController.text.trim(),
        'email': email,
        'password': password,
        'address': _addressController.text.trim(),
        'date_of_birth': _dateOfBirthController.text.trim(),
        'phone': _phoneController.text.trim(),
        'country_code': _countryCode,
      });
      
      // Store current user information
      currentUserId = userId;
      currentUserName = _nameController.text.trim();
      currentUserEmail = email;
      
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ChooseOptionScreen()),
      );
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final TextEditingController emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password'),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Enter your email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset link sent to ${emailController.text} (not really, demo only)')),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _loginWithFaceID() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      bool isAvailable = await _localAuth.isDeviceSupported();
      if (!canCheck || !isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Face ID/biometric authentication not available on this device.')),
        );
        return;
      }
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (authenticated) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ChooseOptionScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometric authentication failed: \n$e')),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    // Dummy Google login - just show success message and navigate
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully signed in with Google! (Demo Mode)'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Add a small delay to show the message
    await Future.delayed(Duration(milliseconds: 500));
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChooseOptionScreen()),
    );
  }

  Future<void> _loginWithFacebook() async {
    // Dummy Facebook login - just show success message and navigate
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully signed in with Facebook! (Demo Mode)'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Add a small delay to show the message
    await Future.delayed(Duration(milliseconds: 500));
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChooseOptionScreen()),
    );
  }

  InputDecoration _formalDecoration(String label, IconData icon, {String? errorText}) {
    return modernInputDecoration(label, icon, errorText: errorText);
  }

  // Password strength checks
  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasSpecial => _passwordController.text.contains(RegExp(r'[!@#\$&*~%^()_+=\-\[\]{};:\",.<>/?\\|]'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),

                // Header Section
              Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isLogin ? 'Welcome Back!' : 'Join Our Community',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        _isLogin ? 'Sign in to continue making a difference' : 'Create an account to start helping others',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Form Container
              Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_generalError != null) ...[
                        _buildErrorContainer(_generalError!),
                        SizedBox(height: 20),
                      ],
                      if (!_isLogin) ...[
                        _buildFormField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person,
                        ),
                        SizedBox(height: 20),
                      ],
                      _buildFormField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      _buildFormField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        errorText: _passwordError,
                        obscureText: true,
                        showToggle: true,
                        showPassword: _showPassword,
                        onToggle: () => setState(() => _showPassword = !_showPassword),
                        onChanged: (value) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                          setState(() {});
                        },
                      ),
                      if (!_isLogin) ...[
                        SizedBox(height: 16),
                        _buildFormField(
                          controller: _reenterPasswordController,
                          label: 'Re-enter Password',
                          icon: Icons.lock_outline,
                          errorText: _reenterPasswordError,
                          obscureText: true,
                          showToggle: true,
                          showPassword: _showReenterPassword,
                          onToggle: () => setState(() => _showReenterPassword = !_showReenterPassword),
                          onChanged: (value) {
                            if (_reenterPasswordError != null) {
                              setState(() => _reenterPasswordError = null);
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        _buildPasswordChecklist(),
                        SizedBox(height: 20),
                        _buildFormField(
                          controller: _addressController,
                          label: 'Address',
                          icon: Icons.home,
                        ),
                        SizedBox(height: 20),
                        // Date of Birth Field with Toggle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Date of Birth',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _useDatePicker = !_useDatePicker;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                                    ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _useDatePicker ? Icons.calendar_today : Icons.edit,
                                          size: 16,
                                          color: AppColors.primaryGreen,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          _useDatePicker ? 'Picker' : 'Type',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            _useDatePicker
                                ? GestureDetector(
                                    onTap: _selectDateOfBirth,
                                    child: AbsorbPointer(
                                      child: _buildFormField(
                                        controller: _dateOfBirthController,
                                        label: 'Tap to select date',
                                        icon: Icons.cake,
                                        keyboardType: TextInputType.datetime,
                                      ),
                                    ),
                                  )
                                : _buildFormField(
                                    controller: _dateOfBirthController,
                                    label: 'Enter date (DD/MM/YYYY)',
                                    icon: Icons.cake,
                                    keyboardType: TextInputType.datetime,
                                  ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildPhoneField(),
                      ],
                      SizedBox(height: 32),
                      _buildPrimaryButton(
                        text: _isLogin ? 'Log In' : 'Create Account',
                        onPressed: _submit,
                      ),
                      if (_isLogin) ...[
                        SizedBox(height: 20),
                        _buildDivider(),
                        SizedBox(height: 20),
                        _buildBiometricButton(),
                        SizedBox(height: 20),
                        _buildSocialLoginButtons(),
                      ],
                      SizedBox(height: 24),
                      _buildToggleButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    bool showToggle = false,
    bool showPassword = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorText != null ? Colors.red.withOpacity(0.3) : AppColors.lightGreen,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText && !showPassword,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textDark),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorText: errorText,
          suffixIcon: showToggle
              ? IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.primaryGreen,
                  ),
                  onPressed: onToggle,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: IntlPhoneField(
        controller: _phoneController,
        decoration: InputDecoration(
          labelText: 'Phone Number',
          labelStyle: TextStyle(color: AppColors.textDark),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        initialCountryCode: 'US',
        onChanged: (phone) {
          _countryCode = phone.countryCode;
        },
        onCountryChanged: (country) {
          _countryCode = '+${country.dialCode}';
        },
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Center(
      child: TextButton(
        onPressed: _showForgotPasswordDialog,
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _loginWithFaceID,
        icon: Icon(Icons.face, color: AppColors.primaryGreen, size: 24),
        label: Text(
          'Login with Face ID',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // Google Login Button
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Do nothing when clicked
            },
            icon: Icon(Icons.g_mobiledata, color: Colors.red[600], size: 24),
            label: Text(
              'Continue with Google',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        // Facebook Login Button
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Do nothing when clicked
            },
            icon: Icon(Icons.facebook, color: Colors.blue[600], size: 24),
            label: Text(
              'Continue with Facebook',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.lightGreen, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.lightGreen, thickness: 1)),
      ],
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: _toggleFormMode,
      child: Text(
        _isLogin ? "Don't have an account? Sign Up" : 'Already have an account? Log In',
        style: TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorContainer(String error) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordChecklist() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          _buildChecklistItem('At least 8 characters', _hasMinLength),
          _buildChecklistItem('One uppercase letter', _hasUppercase),
          _buildChecklistItem('One special character', _hasSpecial),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isCompleted) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? AppColors.primaryGreen : AppColors.textLight,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isCompleted ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordChecklist extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasSpecial;
  const _PasswordChecklist({required this.hasMinLength, required this.hasUppercase, required this.hasSpecial});

  Widget _item(bool met, String text) {
    return Row(
      children: [
        Icon(met ? Icons.check_circle : Icons.cancel, size: 18, color: met ? Colors.green : Colors.red),
        SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: met ? Colors.green : Colors.red)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _item(hasMinLength, 'At least 8 characters'),
        _item(hasUppercase, 'At least one uppercase letter'),
        _item(hasSpecial, 'At least one special character'),
      ],
    );
  }
}

class DonationTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Donation Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
              Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Make a Difference',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Choose how you\'d like to help others today',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                
                // Donation Options
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDonationCard(
                          context: context,
                          icon: Icons.attach_money,
                          title: 'Money Donation',
                          subtitle: 'Support causes with financial contribution',
                          color: AppColors.primaryGreen,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ChooseOrganizationScreen()),
                            );
                          },
                        ),
                        SizedBox(height: 24),
                        _buildDonationCard(
                          context: context,
                          icon: Icons.checkroom,
                          title: 'Clothes Donation',
                          subtitle: 'Donate clothing items for those in need',
                          color: AppColors.accentGreen,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ClothesDonationScreen()),
                            );
                          },
                        ),
                        SizedBox(height: 24),
                        _buildDonationCard(
                          context: context,
                          icon: Icons.schedule,
                          title: 'Donation Plan',
                          subtitle: 'Set up recurring donations with flexible payment options',
                          color: AppColors.lightGreen,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => DonationPlanScreen()),
                            );
                          },
                        ),
                        SizedBox(height: 24),
                        _buildDonationCard(
                          context: context,
                          icon: Icons.list_alt,
                          title: 'My Donation Plans',
                          subtitle: 'View and manage your recurring donation plans',
                          color: AppColors.accentGreen,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => MyDonationPlansScreen()),
                            );
                          },
                        ),
                        SizedBox(height: 24), // Add bottom padding for scrolling
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDonationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            children: [
            Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClothesDonationScreen extends StatefulWidget {
  @override
  State<ClothesDonationScreen> createState() => _ClothesDonationScreenState();
}

class _ClothesDonationScreenState extends State<ClothesDonationScreen> {
  final TextEditingController itemsController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  DateTime? pickupDate;
  Offset? pickedOffset;
  String? errorText;

  Future<void> _submit() async {
    final items = int.tryParse(itemsController.text) ?? 0;
    if (items <= 0 || (addressController.text.trim().isEmpty && pickedOffset == null) || pickupDate == null) {
      setState(() => errorText = 'Please fill in all fields.');
      return;
    }
    
    // Save user clothes donation activity
    await DatabaseHelper().insertUserDonation({
      'user_id': currentUserId!,
      'donation_type': 'Clothes',
      'organization_name': 'General Clothes Donation',
      'amount': 0,
      'items_count': items,
      'pickup_address': addressController.text.isNotEmpty ? addressController.text : (pickedOffset != null ? 'Picked location on map' : ''),
      'pickup_date': pickupDate!.toLocal().toString().split(" ")[0],
      'donation_date': DateTime.now().toIso8601String(),
    });
    
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thank you for donating $items items of clothes! We will pick them up at ${addressController.text.isNotEmpty ? addressController.text : (pickedOffset != null ? 'Picked location on map' : '')} on ${pickupDate!.toLocal().toString().split(" ")[0]}')),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => pickupDate = picked);
    }
  }

  Future<void> _pickOnMap() async {
    final Offset? result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FakeMapPickerScreen()),
    );
    if (result != null) {
      setState(() {
        pickedOffset = result;
        addressController.text = 'Picked location on map';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate Clothes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
              Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                    Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.checkroom,
                          size: 32,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Clothes Donation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Help those in need by donating clothing items',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Form Container
              Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFormField(
                        controller: itemsController,
                        label: 'Number of Items',
                        icon: Icons.inventory_2,
                        keyboardType: TextInputType.number,
                        hint: 'Enter number of clothing items',
                      ),
                      SizedBox(height: 20),
                      
                      // Address Section
                      Text(
                        'Pickup Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField(
                              controller: addressController,
                              label: 'Address',
                              icon: Icons.location_on,
                              hint: 'Enter pickup address',
                            ),
                          ),
                          SizedBox(width: 12),
                        Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _pickOnMap,
                              icon: Icon(Icons.map, color: AppColors.white, size: 20),
                              label: Text(
                                'Map',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      
                      // Date Section
                      Text(
                        'Pickup Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 12),
                    Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: pickupDate != null ? AppColors.primaryGreen : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: pickupDate != null ? AppColors.primaryGreen : AppColors.lightGreen,
                            width: 2,
                          ),
                          boxShadow: pickupDate != null ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ] : null,
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _pickDate,
                          icon: Icon(
                            Icons.calendar_today,
                            color: pickupDate != null ? AppColors.white : AppColors.primaryGreen,
                            size: 20,
                          ),
                          label: Text(
                            pickupDate == null 
                                ? 'Choose pickup date' 
                                : 'Pickup: ${pickupDate!.toLocal().toString().split(" ")[0]}',
                            style: TextStyle(
                              color: pickupDate != null ? AppColors.white : AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      
                      if (errorText != null) ...[
                        SizedBox(height: 16),
                        _buildErrorContainer(errorText!),
                      ],
                      
                      SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textDark),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildErrorContainer(String error) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _submit,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, color: AppColors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Submit Donation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonationPlanScreen extends StatefulWidget {
  @override
  State<DonationPlanScreen> createState() => _DonationPlanScreenState();
}

class _DonationPlanScreenState extends State<DonationPlanScreen> {
  final TextEditingController amountController = TextEditingController();
  String selectedFrequency = 'Monthly';
  String selectedPaymentMethod = 'Card';
  String selectedOrganization = 'Bait El Zakat w El Sadakat';
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController pickupAddressController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  DateTime? pickupDate;
  String? errorText;

  final List<String> frequencyOptions = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  final List<String> paymentMethods = ['Card', 'Pickup'];
  final List<String> organizations = [
    'Bait El Zakat w El Sadakat',
    '57357 Children Cancer Hospital',
    'Magdi Yacoub Heart Foundation',
    'Misr El Kheir Foundation',
    'Baheya Zayed Hospital',
    'Egyptian Food Bank',
    'Resala Charity Organization',
    'Ahl Masr Foundation',
    'Orman Charity Association',
    'Al Nas Hospital',
    'Tanta Cancer Center',
    'Children\'s Cancer Hospital Foundation',
    'Cairo University Hospitals',
    'Dar Al-Orman Hospital',
    'Egyptian Cure Bank',
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => pickupDate = picked);
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final initialDate = startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: initialDate.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(amountController.text) ?? 0;
    
    if (amount <= 0) {
      setState(() => errorText = 'Please enter a valid amount.');
      return;
    }

    // Both start and end dates are now optional

    if (selectedPaymentMethod == 'Card') {
      if (cardNumberController.text.trim().isEmpty || 
          cardNameController.text.trim().isEmpty || 
          expiryController.text.trim().isEmpty || 
          cvvController.text.trim().isEmpty) {
        setState(() => errorText = 'Please fill in all card details.');
        return;
      }
    } else {
      if (pickupAddressController.text.trim().isEmpty || pickupDate == null) {
        setState(() => errorText = 'Please fill in pickup details.');
        return;
      }
    }

    // Save donation plan to database
    await DatabaseHelper().insertUserDonation({
      'user_id': currentUserId!,
      'donation_type': 'Recurring Plan',
      'organization_name': selectedOrganization,
      'amount': amount,
      'frequency': selectedFrequency,
      'payment_method': selectedPaymentMethod,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'donation_date': DateTime.now().toIso8601String(),
    });

    Navigator.of(context).pop();
    String startDateText = startDate != null ? ' starting from ${startDate!.toLocal().toString().split(" ")[0]}' : '';
    String endDateText = endDate != null ? ' until ${endDate!.toLocal().toString().split(" ")[0]}' : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Donation plan created successfully! You will donate \$${amount.toStringAsFixed(2)} $selectedFrequency to $selectedOrganization$startDateText$endDateText.'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Plan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
              Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                    Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.schedule,
                          color: AppColors.primaryGreen,
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Create Donation Plan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Set up recurring donations to make a lasting impact',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Amount and Frequency Section
              Container(
                  padding: EdgeInsets.all(24),
                  decoration: AppCardStyle.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Details',
                        style: AppTextStyles.subheading,
                      ),
                      SizedBox(height: 20),
                      
                      // Amount Field
                      TextField(
                        controller: amountController,
                        decoration: modernInputDecoration(
                          'Amount (\$) *',
                          Icons.attach_money,
                          errorText: errorText,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20),

                      // Frequency Selection
                      Text(
                        'Frequency',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: frequencyOptions.map((frequency) {
                          final isSelected = selectedFrequency == frequency;
                          return GestureDetector(
                            onTap: () => setState(() => selectedFrequency = frequency),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryGreen : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryGreen : AppColors.lightGreen,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                frequency,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.white : AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),

                      // Organization Selection
                      Text(
                        'Organization',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 12),
                    Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGreen,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGreen),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedOrganization,
                          items: organizations.map((org) => DropdownMenuItem(
                            value: org, 
                            child: Text(
                              org,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 14),
                            )
                          )).toList(),
                          onChanged: (val) => setState(() => selectedOrganization = val ?? organizations[0]),
                          decoration: InputDecoration(
                            labelText: 'Select Organization',
                            labelStyle: TextStyle(color: AppColors.textDark),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            isDense: true,
                          ),
                          dropdownColor: AppColors.white,
                          icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen, size: 20),
                          isExpanded: true,
                          menuMaxHeight: 200,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Date Selection
                      Text(
                        'Plan Duration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 12),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _pickStartDate,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGreen,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.lightGreen),
                              ),
                            child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: AppColors.primaryGreen, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      startDate == null ? 'Start Date (Optional)' : 'Start: ${startDate!.toLocal().toString().split(" ")[0]}',
                                      style: TextStyle(
                                        color: startDate == null ? AppColors.textLight : AppColors.textDark,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          GestureDetector(
                            onTap: _pickEndDate,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGreen,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.lightGreen),
                              ),
                            child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: AppColors.primaryGreen, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      endDate == null ? 'End Date (Optional)' : 'End: ${endDate!.toLocal().toString().split(" ")[0]}',
                                      style: TextStyle(
                                        color: endDate == null ? AppColors.textLight : AppColors.textDark,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Payment Method Section
              Container(
                  padding: EdgeInsets.all(24),
                  decoration: AppCardStyle.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Method',
                        style: AppTextStyles.subheading,
                      ),
                      SizedBox(height: 20),

                      // Payment Method Selection
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => selectedPaymentMethod = 'Card'),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selectedPaymentMethod == 'Card' ? AppColors.primaryGreen : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color: selectedPaymentMethod == 'Card' ? AppColors.white : AppColors.primaryGreen,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pay by Card',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: selectedPaymentMethod == 'Card' ? AppColors.white : AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => setState(() => selectedPaymentMethod = 'Pickup'),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selectedPaymentMethod == 'Pickup' ? AppColors.primaryGreen : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: selectedPaymentMethod == 'Pickup' ? AppColors.white : AppColors.primaryGreen,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pay by Pickup',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: selectedPaymentMethod == 'Pickup' ? AppColors.white : AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Card Details (if Card selected)
                      if (selectedPaymentMethod == 'Card') ...[
                        Text(
                          'Card Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: cardNumberController,
                          decoration: modernInputDecoration('Card Number *', Icons.credit_card),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: cardNameController,
                          decoration: modernInputDecoration('Cardholder Name *', Icons.person),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: expiryController,
                                decoration: modernInputDecoration('Expiry (MM/YY)', Icons.calendar_today),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: cvvController,
                                decoration: modernInputDecoration('CVV *', Icons.security),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Pickup Details (if Pickup selected)
                      if (selectedPaymentMethod == 'Pickup') ...[
                        Text(
                          'Pickup Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: pickupAddressController,
                          decoration: modernInputDecoration('Pickup Address *', Icons.location_on),
                          maxLines: 2,
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundGreen,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.lightGreen),
                            ),
                          child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: AppColors.primaryGreen),
                                SizedBox(width: 12),
                                Text(
                                  pickupDate == null ? 'Select Pickup Date *' : 'Pickup Date: ${pickupDate!.toLocal().toString().split(" ")[0]}',
                                  style: TextStyle(
                                    color: pickupDate == null ? AppColors.textLight : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: AppButtonStyles.primary,
                    child: Text(
                      'Create Donation Plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyDonationPlansScreen extends StatefulWidget {
  @override
  State<MyDonationPlansScreen> createState() => _MyDonationPlansScreenState();
}

class _MyDonationPlansScreenState extends State<MyDonationPlansScreen> {
  List<Map<String, dynamic>> donationPlans = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDonationPlans();
    // Add a timeout to prevent infinite loading
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && loading) {
        print('Loading timeout - setting loading to false');
        setState(() {
          loading = false;
        });
      }
    });
  }

  Future<void> _loadDonationPlans() async {
    print('Loading donation plans for user: $currentUserId');
    if (currentUserId != null) {
      try {
        // First, let's get all donations to see what we have
        final allDonations = await DatabaseHelper().getUserDonations(currentUserId!);
        print('All donations for user: ${allDonations.length}');
        
        // Filter for recurring plans
        final plans = allDonations.where((donation) => 
          donation['donation_type'] == 'Recurring Plan' && 
          (donation['is_active'] == null || donation['is_active'] == 1)
        ).toList();
        
        print('Found ${plans.length} donation plans after filtering');
        setState(() {
          donationPlans = plans;
          loading = false;
        });
      } catch (e) {
        print('Error loading donation plans: $e');
        setState(() {
          donationPlans = [];
          loading = false;
        });
      }
    } else {
      print('currentUserId is null');
      setState(() {
        donationPlans = [];
        loading = false;
      });
    }
  }

  Future<void> _cancelPlan(int planId) async {
    await DatabaseHelper().updateDonationPlan(planId, {'is_active': 0});
    await _loadDonationPlans();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Donation plan cancelled successfully.'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Donation Plans', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: loading
              ? Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
              : donationPlans.isEmpty
                  ? _buildEmptyState()
                  : _buildPlansList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '😢',
              style: TextStyle(fontSize: 80),
            ),
            SizedBox(height: 24),
            Text(
              'Still no donations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DonationPlanScreen()),
                  );
                },
                style: AppButtonStyles.primary,
                child: Text(
                  'Start a donation plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList() {
    return ListView.builder(
      padding: EdgeInsets.all(24),
      itemCount: donationPlans.length,
      itemBuilder: (context, index) {
        final plan = donationPlans[index];
        return _buildPlanCard(plan);
      },
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final startDate = DateTime.tryParse(plan['start_date'] ?? '');
    final endDate = DateTime.tryParse(plan['end_date'] ?? '');
    final amount = plan['amount'] ?? 0;
    final frequency = plan['frequency'] ?? 'Monthly';
    final organization = plan['organization_name'] ?? 'Unknown Organization';
    final paymentMethod = plan['payment_method'] ?? 'Card';

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: AppCardStyle.cardDecoration,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organization,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${amount.toStringAsFixed(2)} $frequency',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Details
            _buildDetailRow(Icons.calendar_today, 'Start Date', startDate != null ? startDate.toLocal().toString().split(" ")[0] : 'Not set'),
            SizedBox(height: 12),
            _buildDetailRow(Icons.calendar_today, 'End Date', endDate != null ? endDate.toLocal().toString().split(" ")[0] : 'Not set'),
            SizedBox(height: 12),
            _buildDetailRow(Icons.payment, 'Payment Method', paymentMethod),
            SizedBox(height: 20),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _showCancelDialog(plan['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Text(
                  'Cancel Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primaryGreen,
        ),
        SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(int planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Donation Plan'),
        content: Text('Are you sure you want to cancel this donation plan? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelPlan(planId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Yes, Cancel Plan'),
          ),
        ],
      ),
    );
  }
}

class FakeMapPickerScreen extends StatefulWidget {
  @override
  State<FakeMapPickerScreen> createState() => _FakeMapPickerScreenState();
}

class _FakeMapPickerScreenState extends State<FakeMapPickerScreen> {
  Offset? picked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Header Section
              Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                    Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Select Pickup Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap on the map to choose your pickup location',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                
                // Map Section
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTapDown: (details) {
                                setState(() => picked = details.localPosition);
                              },
                              child: Container(
                                width: 320,
                                height: 320,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.lightGreen, width: 2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/static_map.png',
                                    fit: BoxFit.cover,
                                    width: 320,
                                    height: 320,
                                  ),
                                ),
                              ),
                            ),
                            if (picked != null)
                              Positioned(
                                left: picked!.dx - 16,
                                top: picked!.dy - 32,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.location_on, color: AppColors.primaryGreen, size: 24),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: picked != null
          ? Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.darkGreen],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(picked),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: AppColors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class DonateToOrganizationScreen extends StatefulWidget {
  final String orgName;
  const DonateToOrganizationScreen({required this.orgName});
  @override
  State<DonateToOrganizationScreen> createState() => _DonateToOrganizationScreenState();
}

class _DonateToOrganizationScreenState extends State<DonateToOrganizationScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController pickupAddressController = TextEditingController();
  
  String selectedType = 'General';
  String selectedPaymentMethod = 'Card'; // 'Card' or 'Pickup'
  
  final List<String> charityTypes = [
    'General',
    'Medical',
    'Education',
    'Food',
    'Orphans',
    'Emergency',
    'Other',
  ];
  
  DateTime? pickupDate;
  String? errorText;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => pickupDate = picked);
    }
  }

  Future<void> _submit() async {
    final entered = int.tryParse(amountController.text) ?? 0;
    if (entered <= 0) {
      setState(() => errorText = 'Please enter a valid amount.');
      return;
    }

    // Validate payment method specific fields
    if (selectedPaymentMethod == 'Card') {
      if (cardNumberController.text.trim().isEmpty || 
          cardNameController.text.trim().isEmpty || 
          expiryController.text.trim().isEmpty || 
          cvvController.text.trim().isEmpty) {
        setState(() => errorText = 'Please fill in all card details.');
        return;
      }
    } else if (selectedPaymentMethod == 'Pickup') {
      if (pickupAddressController.text.trim().isEmpty || pickupDate == null) {
        setState(() => errorText = 'Please fill in pickup address and date.');
        return;
      }
    }
    
    // Save user donation activity
    await DatabaseHelper().insertUserDonation({
      'user_id': currentUserId!,
      'donation_type': 'Money',
      'organization_name': widget.orgName,
      'amount': entered,
      'items_count': 0,
      'pickup_address': selectedPaymentMethod == 'Pickup' ? pickupAddressController.text : null,
      'pickup_date': selectedPaymentMethod == 'Pickup' ? pickupDate!.toIso8601String() : null,
      'donation_date': DateTime.now().toIso8601String(),
    });
    
    Navigator.of(context).pop();
    String paymentMethodText = selectedPaymentMethod == 'Card' ? 'via card payment' : 'via pickup';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thank you for donating \$$entered to ${widget.orgName} ($selectedType) $paymentMethodText!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate to ${widget.orgName}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundGreen, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
              Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                    Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: 32,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.orgName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your donation will make a real difference',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Form Container
              Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Charity Type Selection
                      Text(
                        'Charity Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildDropdownField(
                        value: selectedType,
                        items: charityTypes,
                        onChanged: (val) => setState(() => selectedType = val ?? 'General'),
                        label: 'Select charity type',
                      ),
                      SizedBox(height: 24),

                      // Amount Field
                      _buildFormField(
                        controller: amountController,
                        label: 'Donation Amount *',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        hint: 'Enter amount in dollars',
                        errorText: errorText,
                        onChanged: (_) { if (errorText != null) setState(() => errorText = null); },
                      ),
                      SizedBox(height: 24),
                      
                      // Payment Method Selection
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 12),
                      Column(
                        children: [
                          _buildPaymentMethodButton(
                            title: 'Card',
                            icon: Icons.credit_card,
                            isSelected: selectedPaymentMethod == 'Card',
                            onTap: () => setState(() => selectedPaymentMethod = 'Card'),
                          ),
                          SizedBox(height: 12),
                          _buildPaymentMethodButton(
                            title: 'Pickup',
                            icon: Icons.location_on,
                            isSelected: selectedPaymentMethod == 'Pickup',
                            onTap: () => setState(() => selectedPaymentMethod = 'Pickup'),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      // Payment Details
                      if (selectedPaymentMethod == 'Card') ...[
                        _buildCardPaymentSection(),
                      ] else if (selectedPaymentMethod == 'Pickup') ...[
                        _buildPickupPaymentSection(),
                      ],
                      
                      SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textDark),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        dropdownColor: AppColors.white,
        icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? errorText,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorText != null ? Colors.red.withOpacity(0.3) : AppColors.lightGreen,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textDark),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorText: errorText,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGreen,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.primaryGreen,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 16),
        _buildFormField(
          controller: cardNumberController,
          label: 'Card Number *',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          hint: '1234 5678 9012 3456',
        ),
        SizedBox(height: 16),
        _buildFormField(
          controller: cardNameController,
          label: 'Cardholder Name *',
          icon: Icons.person,
          hint: 'John Doe',
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                controller: expiryController,
                label: 'Expiry (MM/YY) *',
                icon: Icons.calendar_today,
                hint: '12/25',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildFormField(
                controller: cvvController,
                label: 'CVV *',
                icon: Icons.security,
                keyboardType: TextInputType.number,
                hint: '123',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPickupPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 16),
        _buildFormField(
          controller: pickupAddressController,
          label: 'Pickup Address *',
          icon: Icons.location_on,
          hint: 'Enter your address for pickup',
        ),
        SizedBox(height: 16),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: pickupDate != null ? AppColors.primaryGreen : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: pickupDate != null ? AppColors.primaryGreen : AppColors.lightGreen,
              width: 2,
            ),
            boxShadow: pickupDate != null ? [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ] : null,
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _pickDate,
            icon: Icon(
              Icons.calendar_today,
              color: pickupDate != null ? AppColors.white : AppColors.primaryGreen,
              size: 20,
            ),
            label: Text(
              pickupDate == null 
                  ? 'Choose pickup date *' 
                  : 'Pickup: ${pickupDate!.toLocal().toString().split(" ")[0]}',
              style: TextStyle(
                color: pickupDate != null ? AppColors.white : AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _submit,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: AppColors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Complete Donation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyDoctorScreen extends StatefulWidget {
  @override
  _MyDoctorScreenState createState() => _MyDoctorScreenState();
}

class _MyDoctorScreenState extends State<MyDoctorScreen> {
  int _selectedTab = 0;
  List<String> _uploads = [
    'Blood Test Report.pdf',
    'X-ray Image.jpg',
    'Prescription_2024-06-01.pdf',
  ];
  List<String> _responses = [
    'Dr. Smith: Your blood test is normal.',
    'Dr. Lee: Please schedule a follow-up.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Doctor', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTab == 0 ? AppColors.primaryGreen : AppColors.lightGray,
                        foregroundColor: _selectedTab == 0 ? AppColors.white : AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () => setState(() => _selectedTab = 0),
                    child: Text('Uploads', style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTab == 1 ? AppColors.primaryGreen : AppColors.lightGray,
                        foregroundColor: _selectedTab == 1 ? AppColors.white : AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () => setState(() => _selectedTab = 1),
                    child: Text('Responds', style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0 ? _buildUploads() : _buildResponses(),
          ),
        ],
      ),
    );
  }

  Widget _buildUploads() {
    if (_uploads.isEmpty) {
              return Center(child: Text('No uploads yet.', style: TextStyle(fontSize: 18, color: AppColors.textDark)));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _uploads.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            leading: Icon(Icons.insert_drive_file, color: AppColors.primaryGreen),
            title: Text(_uploads[index]),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildResponses() {
    if (_responses.isEmpty) {
              return Center(child: Text('No responses from doctors yet.', style: TextStyle(fontSize: 18, color: AppColors.textDark)));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _responses.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            leading: Icon(Icons.medical_services, color: AppColors.primaryGreen),
            title: Text(_responses[index]),
          ),
        );
      },
    );
  }
}


class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  CustomDatePickerDialog({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  _CustomDatePickerDialogState createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;
  
  late int _selectedMonth;
  late int _selectedDay;
  late int _selectedYear;

  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialDate.month - 1;
    _selectedDay = widget.initialDate.day - 1;
    _selectedYear = widget.initialDate.year - 1900;
    
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth);
    _dayController = FixedExtentScrollController(initialItem: _selectedDay);
    _yearController = FixedExtentScrollController(initialItem: _selectedYear);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int _getDaysInMonth(int month, int year) {
    if (month == 1) { // February
      if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
        return 29; // Leap year
      }
      return 28;
    }
    if ([3, 5, 8, 10].contains(month)) { // April, June, September, November
      return 30;
    }
    return 31;
  }

  void _updateDayController() {
    final daysInMonth = _getDaysInMonth(_selectedMonth, _selectedYear + 1900);
    if (_selectedDay >= daysInMonth) {
      _selectedDay = daysInMonth - 1;
      _dayController.jumpToItem(_selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Date of Birth",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 24),
            
            // Date Picker Container
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.backgroundGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGreen),
              ),
              child: Row(
                children: [
                  // Month Picker
                  Expanded(
                    child: _buildPickerColumn(
                      controller: _monthController,
                      items: months,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMonth = index;
                          _updateDayController();
                        });
                      },
                    ),
                  ),
                  
                  // Day Picker
                  Expanded(
                    child: _buildPickerColumn(
                      controller: _dayController,
                      items: List.generate(_getDaysInMonth(_selectedMonth, _selectedYear + 1900), (index) => (index + 1).toString()),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedDay = index;
                        });
                      },
                    ),
                  ),
                  
                  // Year Picker
                  Expanded(
                    child: _buildPickerColumn(
                      controller: _yearController,
                      items: List.generate(DateTime.now().year - 1899, (index) => (1900 + index).toString()),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedYear = index;
                          _updateDayController();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      final selectedDate = DateTime(
                        _selectedYear + 1900,
                        _selectedMonth + 1,
                        _selectedDay + 1,
                      );
                      widget.onDateSelected(selectedDate);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerColumn({
    required FixedExtentScrollController controller,
    required List<String> items,
    required Function(int) onSelectedItemChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      diameterRatio: 1.5,
      perspective: 0.01,
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index < 0 || index >= items.length) return null;
          
          return Center(
            child: Text(
              items[index],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}
