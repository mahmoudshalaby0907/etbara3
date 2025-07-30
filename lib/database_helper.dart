import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');
    return await openDatabase(
      path,
      version: 8,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            address TEXT,
            date_of_birth TEXT,
            phone TEXT,
            country_code TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE organizations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            icon TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            activity TEXT,
            volunteers INTEGER,
            signedUp INTEGER,
            equipment TEXT,
            location TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            illness TEXT,
            description TEXT,
            amount INTEGER,
            collected INTEGER,
            documents TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE user_donations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            donation_type TEXT,
            organization_name TEXT,
            amount INTEGER,
            items_count INTEGER,
            pickup_address TEXT,
            pickup_date TEXT,
            donation_date TEXT,
            frequency TEXT,
            payment_method TEXT,
            start_date TEXT,
            end_date TEXT,
            is_active INTEGER DEFAULT 1,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
        await db.execute('''
          CREATE TABLE user_volunteering (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            event_name TEXT,
            event_activity TEXT,
            volunteers_count INTEGER,
            volunteer_date TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
        await db.execute('''
          CREATE TABLE user_project_donations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            project_name TEXT,
            project_illness TEXT,
            amount INTEGER,
            donation_date TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 5) {
          // Add documents column to projects table
          await db.execute('ALTER TABLE projects ADD COLUMN documents TEXT');
        }
        if (oldVersion < 6) {
          // Change age column to date_of_birth column
          await db.execute('ALTER TABLE users ADD COLUMN date_of_birth TEXT');
          // Copy existing age data to date_of_birth (optional, for existing users)
          await db.execute('UPDATE users SET date_of_birth = "01/01/2000" WHERE date_of_birth IS NULL');
        }
        if (oldVersion < 7) {
          // Add frequency and payment_method columns to user_donations table
          await db.execute('ALTER TABLE user_donations ADD COLUMN frequency TEXT');
          await db.execute('ALTER TABLE user_donations ADD COLUMN payment_method TEXT');
        }
        if (oldVersion < 8) {
          // Add start_date, end_date, and is_active columns to user_donations table
          await db.execute('ALTER TABLE user_donations ADD COLUMN start_date TEXT');
          await db.execute('ALTER TABLE user_donations ADD COLUMN end_date TEXT');
          await db.execute('ALTER TABLE user_donations ADD COLUMN is_active INTEGER DEFAULT 1');
        }
      },
    );
  }

  // --- User methods (unchanged) ---
  Future<int> insertUser(Map<String, dynamic> user) async {
    final dbClient = await db;
    return await dbClient.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<Map<String, dynamic>?> getUserByEmailAndPassword(String email, String password) async {
    final dbClient = await db;
    final res = await dbClient.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final dbClient = await db;
    final res = await dbClient.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }

  // --- Organization methods ---
  Future<int> insertOrganization(Map<String, dynamic> org) async {
    final dbClient = await db;
    return await dbClient.insert('organizations', org, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<Map<String, dynamic>>> getOrganizations() async {
    final dbClient = await db;
    return await dbClient.query('organizations');
  }

  // --- Event methods ---
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final dbClient = await db;
    return await dbClient.insert('events', event, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<Map<String, dynamic>>> getEvents() async {
    final dbClient = await db;
    return await dbClient.query('events');
  }

  // --- Project methods ---
  Future<int> insertProject(Map<String, dynamic> project) async {
    final dbClient = await db;
    return await dbClient.insert('projects', project, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<Map<String, dynamic>>> getProjects() async {
    final dbClient = await db;
    return await dbClient.query('projects');
  }

  // --- User Activity Tracking Methods ---
  Future<int> insertUserDonation(Map<String, dynamic> donation) async {
    final dbClient = await db;
    return await dbClient.insert('user_donations', donation, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUserDonations(int userId) async {
    final dbClient = await db;
    return await dbClient.query(
      'user_donations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'donation_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUserDonationPlans(int userId) async {
    final dbClient = await db;
    print('Querying user_donations for user: $userId');
    
    // First, let's see all donations for this user
    final allDonations = await dbClient.query(
      'user_donations',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    print('All donations for user: ${allDonations.length}');
    for (final donation in allDonations) {
      print('Donation: ${donation['donation_type']} - ${donation['is_active']}');
    }
    
    // Now get the specific plans
    final plans = await dbClient.query(
      'user_donations',
      where: 'user_id = ? AND donation_type = ? AND is_active = ?',
      whereArgs: [userId, 'Recurring Plan', 1],
      orderBy: 'donation_date DESC',
    );
    print('Found ${plans.length} donation plans');
    return plans;
  }

  Future<int> updateDonationPlan(int planId, Map<String, dynamic> updates) async {
    final dbClient = await db;
    return await dbClient.update(
      'user_donations',
      updates,
      where: 'id = ?',
      whereArgs: [planId],
    );
  }

  Future<int> insertUserVolunteering(Map<String, dynamic> volunteering) async {
    final dbClient = await db;
    return await dbClient.insert('user_volunteering', volunteering, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUserVolunteering(int userId) async {
    final dbClient = await db;
    return await dbClient.query(
      'user_volunteering',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'volunteer_date DESC',
    );
  }

  Future<int> insertUserProjectDonation(Map<String, dynamic> projectDonation) async {
    final dbClient = await db;
    return await dbClient.insert('user_project_donations', projectDonation, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUserProjectDonations(int userId) async {
    final dbClient = await db;
    return await dbClient.query(
      'user_project_donations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'donation_date DESC',
    );
  }

  // --- Insert default data if tables are empty ---
  Future<void> insertDefaultData() async {
    final dbClient = await db;
    // Organizations
    final orgs = await dbClient.query('organizations');
    if (orgs.isEmpty) {
      final defaultOrgs = [
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
        {'name': 'Children’s Cancer Hospital Foundation', 'icon': '👶'},
        {'name': 'Cairo University Hospitals', 'icon': '🏫'},
        {'name': 'Dar Al-Orman Hospital', 'icon': '🏩'},
        {'name': 'Egyptian Cure Bank', 'icon': '💊'},
      ];
      for (final org in defaultOrgs) {
        await insertOrganization(org);
      }
    }
    // Events
    final events = await dbClient.query('events');
    if (events.isEmpty) {
      final defaultEvents = [
        {'name': 'Food Distribution Drive', 'activity': 'Distribute food packages to families in need', 'volunteers': 10, 'signedUp': 7, 'equipment': 'Car, Food Packages', 'location': 'Dokki'},
        {'name': 'Neighborhood Cleanup', 'activity': 'Clean up local parks and streets', 'volunteers': 20, 'signedUp': 12, 'equipment': 'Trash Bags, Gloves, Truck', 'location': 'Tagamo3'},
        {'name': 'Medical Camp', 'activity': 'Assist doctors and organize medical supplies', 'volunteers': 5, 'signedUp': 2, 'equipment': 'Medical Kits, Tables, Chairs', 'location': 'Maadi'},
        {'name': 'Blood Donation Day', 'activity': 'Organize and assist in blood donation event', 'volunteers': 15, 'signedUp': 10, 'equipment': 'Medical Kits, Beds, Refreshments', 'location': 'Zayed'},
        {'name': 'School Supplies Drive', 'activity': 'Distribute school supplies to children in need', 'volunteers': 8, 'signedUp': 4, 'equipment': 'School Bags, Stationery, Van', 'location': 'Giza'},
        {'name': 'Elderly Home Visit', 'activity': 'Visit and assist elderly at care homes', 'volunteers': 6, 'signedUp': 3, 'equipment': 'Gifts, First Aid Kit', 'location': 'Mokattam'},
        {'name': 'Tree Planting Campaign', 'activity': 'Plant trees in public parks', 'volunteers': 25, 'signedUp': 15, 'equipment': 'Saplings, Shovels, Gloves', 'location': 'October'},
        {'name': 'Charity Marathon', 'activity': 'Help organize and manage a charity run', 'volunteers': 30, 'signedUp': 20, 'equipment': 'Water Bottles, First Aid, Banners', 'location': 'Agouza'},
        {'name': 'Community Health Fair', 'activity': 'Organize health awareness and screening event', 'volunteers': 12, 'signedUp': 8, 'equipment': 'Medical Equipment, Banners, Tables', 'location': 'Rehab'},
        {'name': 'Youth Mentoring Program', 'activity': 'Mentor and guide young students', 'volunteers': 8, 'signedUp': 5, 'equipment': 'Educational Materials, Laptops', 'location': 'Dokki'},
        {'name': 'Environmental Awareness', 'activity': 'Educate community about environmental issues', 'volunteers': 15, 'signedUp': 9, 'equipment': 'Educational Materials, Banners', 'location': 'Tagamo3'},
        {'name': 'Sports Day for Kids', 'activity': 'Organize sports activities for children', 'volunteers': 10, 'signedUp': 6, 'equipment': 'Sports Equipment, Water, First Aid', 'location': 'Maadi'},
      ];
      for (final event in defaultEvents) {
        await insertEvent(event);
      }
    }
    // Projects
    final projects = await dbClient.query('projects');
    if (projects.isEmpty) {
      final defaultProjects = [
        {'name': 'Ahmed Ali', 'illness': 'Heart Surgery', 'description': 'Ahmed needs urgent heart surgery and cannot afford the operation costs.', 'amount': 5000, 'collected': 2000},
        {'name': 'Fatima Hassan', 'illness': 'Cancer Treatment', 'description': 'Fatima is undergoing chemotherapy and needs help with her medical bills.', 'amount': 3000, 'collected': 1200},
        {'name': 'Mohamed Salah', 'illness': 'Kidney Transplant', 'description': 'Mohamed requires a kidney transplant and is seeking support for the procedure.', 'amount': 7000, 'collected': 3500},
        {'name': 'Layla Mostafa', 'illness': 'Liver Transplant', 'description': 'Layla is a young girl in need of a liver transplant.', 'amount': 8000, 'collected': 2500},
        {'name': 'Omar Nabil', 'illness': 'Leukemia', 'description': 'Omar is fighting leukemia and needs funds for chemotherapy.', 'amount': 6000, 'collected': 1800},
        {'name': 'Sara Adel', 'illness': 'Spinal Surgery', 'description': 'Sara needs spinal surgery to walk again.', 'amount': 9000, 'collected': 4000},
        {'name': 'Hassan Ibrahim', 'illness': 'Burn Treatment', 'description': 'Hassan needs specialized burn treatment and rehabilitation.', 'amount': 4500, 'collected': 1500},
        {'name': 'Mona Fathy', 'illness': 'Heart Valve Replacement', 'description': 'Mona requires a heart valve replacement surgery.', 'amount': 7000, 'collected': 2100},
      ];
      for (final project in defaultProjects) {
        await insertProject(project);
      }
    }
  }
} 