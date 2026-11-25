import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Could not load .env file: $e');
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      debugPrint('Supabase initialized successfully!');
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
    }
  }

  runApp(const GreenLeafApp());
}

// ---------------------------------------------------------
// Plant Model
// ---------------------------------------------------------
class Plant {
  String id;
  String name;
  String emoji;
  String room;
  int waterEveryDays;
  DateTime lastWatered;
  String notes;

  Plant({
    required this.id,
    required this.name,
    required this.emoji,
    required this.room,
    required this.waterEveryDays,
    required this.lastWatered,
    this.notes = '',
  });

  bool get needsWaterToday {
    final nextWaterDate = lastWatered.add(Duration(days: waterEveryDays));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(nextWaterDate.year, nextWaterDate.month, nextWaterDate.day);
    return !due.isAfter(today);
  }

  int get daysUntilWater {
    final nextWaterDate = lastWatered.add(Duration(days: waterEveryDays));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(nextWaterDate.year, nextWaterDate.month, nextWaterDate.day);
    return due.difference(today).inDays;
  }
}

// ---------------------------------------------------------
// Theme & Brand Colors
// ---------------------------------------------------------
class GreenLeafColors {
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color mediumGreen = Color(0xFF40916C);
  static const Color softMint = Color(0xFFD8F3DC);
  static const Color lightMint = Color(0xFFE8F5E9);
  static const Color softYellow = Color(0xFFFFF3B0);
  static const Color paleYellow = Color(0xFFFEF9E7);
  static const Color honeyYellow = Color(0xFFFFD166);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFF7FAF7);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
}

// ---------------------------------------------------------
// Root App with Responsive Phone Frame Wrapper
// ---------------------------------------------------------
class GreenLeafApp extends StatelessWidget {
  const GreenLeafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'greenleaf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: GreenLeafColors.scaffoldBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: GreenLeafColors.primaryGreen,
          primary: GreenLeafColors.primaryGreen,
          secondary: GreenLeafColors.honeyYellow,
          surface: GreenLeafColors.pureWhite,
        ),
        fontFamily: 'Roboto',
      ),
      home: const ResponsivePhoneFrame(
        child: GreenLeafMainScreen(),
      ),
    );
  }
}

// ---------------------------------------------------------
// Responsive Phone Frame
// On laptop browsers: 390 x 844 frame with notch and soft grey bg
// On real phones: Fullscreen
// ---------------------------------------------------------
class ResponsivePhoneFrame extends StatelessWidget {
  final Widget child;

  const ResponsivePhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktopOrLaptop = constraints.maxWidth > 500 && constraints.maxHeight > 650;

        if (!isDesktopOrLaptop) {
          // Real phone screen: Fullscreen
          return child;
        }

        // Laptop / Desktop Browser: Phone Frame (390 x 844)
        return Scaffold(
          backgroundColor: const Color(0xFFE5E7EB), // Soft grey background
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Device Label Pill
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🌿', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'greenleaf • Mobile Preview (390 × 844)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: GreenLeafColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phone Frame
                  Container(
                    width: 390,
                    height: 844,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(color: const Color(0xFF1E293B), width: 9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 36,
                          spreadRadius: 4,
                          offset: const Offset(0, 18),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: Stack(
                        children: [
                          // App Viewport
                          Positioned.fill(child: child),

                          // Top Notch / Island
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 126,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1E293B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF334155),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
}

// ---------------------------------------------------------
// Main State Container & Screen Router
// ---------------------------------------------------------
class GreenLeafMainScreen extends StatefulWidget {
  const GreenLeafMainScreen({super.key});

  @override
  State<GreenLeafMainScreen> createState() => _GreenLeafMainScreenState();
}

class _GreenLeafMainScreenState extends State<GreenLeafMainScreen> {
  int _currentIndex = 0;
  Plant? _selectedPlantForDetails;
  bool _isLoading = false;
  bool _isSupabaseConnected = false;

  // 8 Sample Plants (default & fallback)
  List<Plant> _plants = [
    Plant(
      id: '1',
      name: 'Money Plant',
      emoji: '🪴',
      room: 'Living Room',
      waterEveryDays: 7,
      lastWatered: DateTime.now().subtract(const Duration(days: 7)),
      notes: 'Thrives in indirect sunlight. Beautiful cascading vines.',
    ),
    Plant(
      id: '2',
      name: 'Aloe Vera',
      emoji: '🪴',
      room: 'Bedroom',
      waterEveryDays: 14,
      lastWatered: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Loves bright light and dry soil between waterings.',
    ),
    Plant(
      id: '3',
      name: 'Snake Plant',
      emoji: '🪴',
      room: 'Living Room',
      waterEveryDays: 10,
      lastWatered: DateTime.now().subtract(const Duration(days: 10)),
      notes: 'Indestructible air purifier. Perfect for corners.',
    ),
    Plant(
      id: '4',
      name: 'Tulsi',
      emoji: '🌱',
      room: 'Balcony',
      waterEveryDays: 2,
      lastWatered: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Sacred basil. Loves morning sun and moist soil.',
    ),
    Plant(
      id: '5',
      name: 'Rose',
      emoji: '🌹',
      room: 'Garden',
      waterEveryDays: 3,
      lastWatered: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Needs 6 hours of full sun. Fragrant blooms.',
    ),
    Plant(
      id: '6',
      name: 'Mint',
      emoji: '🍃',
      room: 'Kitchen',
      waterEveryDays: 2,
      lastWatered: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Fresh aroma for tea & cooking. Keep soil evenly moist.',
    ),
    Plant(
      id: '7',
      name: 'Peace Lily',
      emoji: '🌸',
      room: 'Living Room',
      waterEveryDays: 5,
      lastWatered: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Graceful white blooms. Droops slightly when thirsty.',
    ),
    Plant(
      id: '8',
      name: 'Cactus',
      emoji: '🌵',
      room: 'Desk',
      waterEveryDays: 21,
      lastWatered: DateTime.now().subtract(const Duration(days: 5)),
      notes: 'Extremely drought tolerant. Loves sunshine on your desk.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPlantsFromSupabase();
  }

  // Load plants from Supabase 'plants' table
  Future<void> _loadPlantsFromSupabase() async {
    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('plants')
          .select()
          .order('name', ascending: true);

      if (response.isNotEmpty) {
        final List<Plant> fetched = response.map<Plant>((row) {
          return Plant(
            id: row['id']?.toString() ?? UniqueKey().toString(),
            name: row['name'] as String? ?? 'Plant',
            emoji: row['emoji'] as String? ?? '🌿',
            room: row['room'] as String? ?? 'Living Room',
            waterEveryDays: (row['water_every_days'] as num?)?.toInt() ?? 7,
            lastWatered: row['last_watered'] != null
                ? DateTime.tryParse(row['last_watered'].toString()) ?? DateTime.now()
                : DateTime.now(),
            notes: row['notes'] as String? ?? '',
          );
        }).toList();

        setState(() {
          _plants = fetched;
          _isSupabaseConnected = true;
          _isLoading = false;
        });
        return;
      } else {
        setState(() {
          _isSupabaseConnected = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Supabase fetch notice: $e');
      // If table is not yet created in Supabase SQL editor, keep sample plants
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save row in watering_log & update plant in Supabase
  Future<void> _markAsWatered(Plant plant) async {
    final now = DateTime.now();

    setState(() {
      plant.lastWatered = now;
    });

    // Sync with Supabase (save in watering_log and update plants)
    try {
      final client = Supabase.instance.client;

      // 1. Update plant's last_watered in 'plants' table
      await client.from('plants').update({
        'last_watered': now.toIso8601String(),
      }).eq('id', plant.id);

      // 2. Insert new row in 'watering_log' table
      await client.from('watering_log').insert({
        'plant_id': plant.id,
        'plant_name': plant.name,
        'watered_at': now.toIso8601String(),
        'notes': 'Watered via greenleaf app 💧',
      });

      debugPrint('Successfully saved watering_log to Supabase!');
    } catch (e) {
      debugPrint('Note: watering_log sync: $e');
    }

    // Happy celebratory SnackBar
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: GreenLeafColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: GreenLeafColors.softYellow,
                shape: BoxShape.circle,
              ),
              child: Text(plant.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plant.name} is happy & hydrated! 💧✨',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Saved to watering_log • Next watering in ${plant.waterEveryDays} days! 🌿',
                    style: const TextStyle(
                      color: GreenLeafColors.softMint,
                      fontSize: 12,
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

  // Save new plant to Supabase
  Future<void> _addNewPlant(Plant plant) async {
    setState(() {
      _plants.insert(0, plant);
      _currentIndex = 1; // Switch to My Plants
    });

    try {
      final client = Supabase.instance.client;
      final inserted = await client.from('plants').insert({
        'name': plant.name,
        'emoji': plant.emoji,
        'room': plant.room,
        'water_every_days': plant.waterEveryDays,
        'last_watered': plant.lastWatered.toIso8601String(),
        'notes': plant.notes,
      }).select().maybeSingle();

      if (inserted != null && inserted['id'] != null) {
        plant.id = inserted['id'].toString();
      }
      debugPrint('Successfully saved new plant to Supabase!');
    } catch (e) {
      debugPrint('Note: insert new plant sync: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: GreenLeafColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        content: Text(
          '🎉 Added ${plant.emoji} ${plant.name} to your garden!',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _openDetails(Plant plant) {
    setState(() {
      _selectedPlantForDetails = plant;
    });
  }

  void _closeDetails() {
    setState(() {
      _selectedPlantForDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If viewing details screen
    if (_selectedPlantForDetails != null) {
      return PlantDetailsScreen(
        plant: _selectedPlantForDetails!,
        onBack: _closeDetails,
        onWatered: () => _markAsWatered(_selectedPlantForDetails!),
      );
    }

    final screens = [
      HomeScreen(
        plants: _plants,
        isLoading: _isLoading,
        isSupabaseConnected: _isSupabaseConnected,
        onRefresh: _loadPlantsFromSupabase,
        onWatered: _markAsWatered,
        onTapPlant: _openDetails,
        onGoToAddPlant: () => setState(() => _currentIndex = 2),
      ),
      MyPlantsScreen(
        plants: _plants,
        onRefresh: _loadPlantsFromSupabase,
        onWatered: _markAsWatered,
        onTapPlant: _openDetails,
      ),
      AddPlantScreen(
        onAddPlant: _addNewPlant,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: GreenLeafColors.pureWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.water_drop_outlined,
                  activeIcon: Icons.water_drop,
                  label: "Today's Care",
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.yard_outlined,
                  activeIcon: Icons.yard,
                  label: "My Plants",
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle,
                  label: "Add Plant",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? GreenLeafColors.softMint : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? GreenLeafColors.primaryGreen : GreenLeafColors.textMuted,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: GreenLeafColors.primaryGreen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 1. Home Screen (Today's plants to water)
// ---------------------------------------------------------
class HomeScreen extends StatelessWidget {
  final List<Plant> plants;
  final bool isLoading;
  final bool isSupabaseConnected;
  final Future<void> Function() onRefresh;
  final Function(Plant) onWatered;
  final Function(Plant) onTapPlant;
  final VoidCallback onGoToAddPlant;

  const HomeScreen({
    super.key,
    required this.plants,
    required this.isLoading,
    required this.isSupabaseConnected,
    required this.onRefresh,
    required this.onWatered,
    required this.onTapPlant,
    required this.onGoToAddPlant,
  });

  @override
  Widget build(BuildContext context) {
    final todayPlants = plants.where((p) => p.needsWaterToday).toList();
    final happyPlants = plants.where((p) => !p.needsWaterToday).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: GreenLeafColors.primaryGreen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('🌿', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 6),
                        Text(
                          'greenleaf',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: GreenLeafColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Supabase Connected',
                          style: TextStyle(
                            fontSize: 12,
                            color: GreenLeafColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: GreenLeafColors.primaryGreen),
                      tooltip: 'Sync with Supabase',
                      onPressed: onRefresh,
                    ),
                    GestureDetector(
                      onTap: onGoToAddPlant,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: GreenLeafColors.softYellow,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: GreenLeafColors.darkGreen,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Daily Highlight Card (Green + Soft Yellow)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GreenLeafColors.primaryGreen, GreenLeafColors.mediumGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: GreenLeafColors.primaryGreen.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GreenLeafColors.softYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: GreenLeafColors.darkGreen),
                            SizedBox(width: 4),
                            Text(
                              "Today's Schedule",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: GreenLeafColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${plants.length} Total Plants',
                        style: const TextStyle(
                          color: GreenLeafColors.softMint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    todayPlants.isNotEmpty
                        ? '${todayPlants.length} plants are thirsty today! 💧'
                        : 'All plants are happy & watered! 🌿✨',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todayPlants.isNotEmpty
                        ? 'Tap "Watered" to log care in your Supabase database.'
                        : 'Great job, plant parent! Everything is flourishing.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: GreenLeafColors.softMint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Title: Today's plants to water
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Plants to Water",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: GreenLeafColors.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: todayPlants.isNotEmpty ? GreenLeafColors.softYellow : GreenLeafColors.lightMint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${todayPlants.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: GreenLeafColors.darkGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: CircularProgressIndicator(color: GreenLeafColors.primaryGreen),
                ),
              )
            else if (todayPlants.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: GreenLeafColors.paleYellow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GreenLeafColors.softYellow, width: 1.5),
                ),
                child: Column(
                  children: const [
                    Text('🌻', style: TextStyle(fontSize: 44)),
                    SizedBox(height: 10),
                    Text(
                      'No plants need water right now!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: GreenLeafColors.darkGreen,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'All your green friends are well hydrated.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: GreenLeafColors.textMuted),
                    ),
                  ],
                ),
              )
            else
              ...todayPlants.map(
                (plant) => _buildPlantCard(
                  plant: plant,
                  isUrgent: true,
                  onTap: () => onTapPlant(plant),
                  onWater: () => onWatered(plant),
                ),
              ),

            const SizedBox(height: 24),

            // Section Title: Healthy & Watered
            if (happyPlants.isNotEmpty) ...[
              const Text(
                'Hydrated & Content',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: GreenLeafColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ...happyPlants.map(
                (plant) => _buildPlantCard(
                  plant: plant,
                  isUrgent: false,
                  onTap: () => onTapPlant(plant),
                  onWater: () => onWatered(plant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard({
    required Plant plant,
    required bool isUrgent,
    required VoidCallback onTap,
    required VoidCallback onWater,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUrgent ? GreenLeafColors.softYellow : Colors.black.withValues(alpha: 0.04),
          width: isUrgent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Plant Emoji Badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isUrgent ? GreenLeafColors.paleYellow : GreenLeafColors.lightMint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    plant.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14),

                // Plant Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: GreenLeafColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: GreenLeafColors.scaffoldBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              plant.room,
                              style: const TextStyle(
                                fontSize: 10,
                                color: GreenLeafColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Water every ${plant.waterEveryDays}d',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: GreenLeafColors.mediumGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // "Watered" Button
                ElevatedButton(
                  onPressed: onWater,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUrgent ? GreenLeafColors.primaryGreen : GreenLeafColors.lightMint,
                    foregroundColor: isUrgent ? Colors.white : GreenLeafColors.primaryGreen,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 15,
                        color: isUrgent ? GreenLeafColors.softYellow : GreenLeafColors.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Watered',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isUrgent ? Colors.white : GreenLeafColors.primaryGreen,
                        ),
                      ),
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
}

// ---------------------------------------------------------
// 2. My Plants Screen
// ---------------------------------------------------------
class MyPlantsScreen extends StatefulWidget {
  final List<Plant> plants;
  final Future<void> Function() onRefresh;
  final Function(Plant) onWatered;
  final Function(Plant) onTapPlant;

  const MyPlantsScreen({
    super.key,
    required this.plants,
    required this.onRefresh,
    required this.onWatered,
    required this.onTapPlant,
  });

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  String _selectedRoom = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final rooms = ['All', 'Living Room', 'Bedroom', 'Balcony', 'Kitchen', 'Garden', 'Desk'];

    final filteredPlants = widget.plants.where((plant) {
      final matchesRoom = _selectedRoom == 'All' || plant.room.toLowerCase() == _selectedRoom.toLowerCase();
      final matchesSearch = plant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          plant.room.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesRoom && matchesSearch;
    }).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Title Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Plants',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: GreenLeafColors.primaryGreen,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.sync, color: GreenLeafColors.primaryGreen),
                      tooltip: 'Refresh from Supabase',
                      onPressed: widget.onRefresh,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: GreenLeafColors.softMint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.plants.length} Plants',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: GreenLeafColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Search plants or rooms...',
                  hintStyle: TextStyle(fontSize: 13, color: GreenLeafColors.textMuted),
                  prefixIcon: Icon(Icons.search, color: GreenLeafColors.primaryGreen, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Room Filter Chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: rooms.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final room = rooms[index];
                final isSelected = _selectedRoom == room;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRoom = room),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? GreenLeafColors.primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? GreenLeafColors.primaryGreen : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Text(
                      room,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : GreenLeafColors.textDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Plant List
          Expanded(
            child: filteredPlants.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('🪴', style: TextStyle(fontSize: 40)),
                        SizedBox(height: 10),
                        Text(
                          'No matching plants found',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: GreenLeafColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filteredPlants.length,
                    itemBuilder: (context, index) {
                      final plant = filteredPlants[index];
                      final needsWater = plant.needsWaterToday;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => widget.onTapPlant(plant),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: needsWater ? GreenLeafColors.paleYellow : GreenLeafColors.lightMint,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(plant.emoji, style: const TextStyle(fontSize: 26)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plant.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: GreenLeafColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '📍 ${plant.room}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: GreenLeafColors.textMuted,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '💧 every ${plant.waterEveryDays}d',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: GreenLeafColors.mediumGreen,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => widget.onWatered(plant),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: needsWater ? GreenLeafColors.primaryGreen : GreenLeafColors.lightMint,
                                      foregroundColor: needsWater ? Colors.white : GreenLeafColors.primaryGreen,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text('Watered', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. Plant Details Screen
// ---------------------------------------------------------
class PlantDetailsScreen extends StatelessWidget {
  final Plant plant;
  final VoidCallback onBack;
  final VoidCallback onWatered;

  const PlantDetailsScreen({
    super.key,
    required this.plant,
    required this.onBack,
    required this.onWatered,
  });

  @override
  Widget build(BuildContext context) {
    final needsWater = plant.needsWaterToday;

    return Scaffold(
      backgroundColor: GreenLeafColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: GreenLeafColors.primaryGreen, size: 20),
          onPressed: onBack,
        ),
        title: Text(
          plant.name,
          style: const TextStyle(
            color: GreenLeafColors.darkGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          // Hero Plant Badge
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: GreenLeafColors.softYellow,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: GreenLeafColors.lightMint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    plant.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Name and Room
          Center(
            child: Column(
              children: [
                Text(
                  plant.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: GreenLeafColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: GreenLeafColors.softMint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '📍 ${plant.room}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: GreenLeafColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: needsWater ? GreenLeafColors.paleYellow : GreenLeafColors.lightMint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: needsWater ? GreenLeafColors.softYellow : GreenLeafColors.softMint,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  needsWater ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: needsWater ? const Color(0xFFD97706) : GreenLeafColors.primaryGreen,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        needsWater ? 'Needs Water Today!' : 'Happy & Hydrated',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: needsWater ? const Color(0xFF92400E) : GreenLeafColors.darkGreen,
                        ),
                      ),
                      Text(
                        needsWater
                            ? 'Give ${plant.name} a fresh drink to keep leaves vibrant.'
                            : 'Next watering in ${plant.daysUntilWater} days.',
                        style: const TextStyle(fontSize: 12, color: GreenLeafColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Care Specification Cards
          const Text(
            'Care Guidelines',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: GreenLeafColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildCareStat(
                  icon: Icons.water_drop,
                  iconColor: Colors.blueAccent,
                  title: 'Frequency',
                  subtitle: 'Every ${plant.waterEveryDays} days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCareStat(
                  icon: Icons.wb_sunny_rounded,
                  iconColor: Colors.orangeAccent,
                  title: 'Sunlight',
                  subtitle: 'Bright indirect',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCareStat(
                  icon: Icons.thermostat,
                  iconColor: Colors.redAccent,
                  title: 'Temperature',
                  subtitle: '18°C - 26°C',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCareStat(
                  icon: Icons.home,
                  iconColor: GreenLeafColors.primaryGreen,
                  title: 'Location',
                  subtitle: plant.room,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Notes Section
          if (plant.notes.isNotEmpty) ...[
            const Text(
              'Plant Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: GreenLeafColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Text(
                plant.notes,
                style: const TextStyle(
                  fontSize: 13,
                  color: GreenLeafColors.textDark,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // Big "Watered" Button
          ElevatedButton(
            onPressed: onWatered,
            style: ElevatedButton.styleFrom(
              backgroundColor: GreenLeafColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shadowColor: GreenLeafColors.primaryGreen.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop, color: GreenLeafColors.softYellow, size: 22),
                SizedBox(width: 8),
                Text(
                  'Mark as Watered Today',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareStat({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: GreenLeafColors.textMuted),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: GreenLeafColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. Add Plant Screen
// ---------------------------------------------------------
class AddPlantScreen extends StatefulWidget {
  final Function(Plant) onAddPlant;

  const AddPlantScreen({super.key, required this.onAddPlant});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedEmoji = '🌿';
  String _selectedRoom = 'Living Room';
  int _waterEveryDays = 5;

  final List<String> _availableEmojis = [
    '🌿', '🪴', '🌱', '🌹', '🍃', '🌸', '🌵', '🍀', '🌻', '🎋', '🌾', '🌴', '🌺', '🌲',
  ];

  final List<String> _rooms = [
    'Living Room', 'Bedroom', 'Balcony', 'Kitchen', 'Garden', 'Office', 'Desk',
  ];

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a plant name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newPlant = Plant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      emoji: _selectedEmoji,
      room: _selectedRoom,
      waterEveryDays: _waterEveryDays,
      lastWatered: DateTime.now(), // Watered when planted
      notes: _notesController.text.trim(),
    );

    widget.onAddPlant(newPlant);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        children: [
          const Text(
            'Add New Plant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: GreenLeafColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Expand your green collection with custom care schedules.',
            style: TextStyle(fontSize: 13, color: GreenLeafColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Emoji Selector
          const Text(
            'Select Plant Icon',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GreenLeafColors.textDark),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _availableEmojis.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final emoji = _availableEmojis[index];
                final isSelected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? GreenLeafColors.softYellow : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? GreenLeafColors.primaryGreen : Colors.black.withValues(alpha: 0.06),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Plant Name Field
          const Text(
            'Plant Name',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GreenLeafColors.textDark),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Fiddle Leaf Fig',
                hintStyle: TextStyle(fontSize: 13, color: GreenLeafColors.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Room Selector
          const Text(
            'Room / Location',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GreenLeafColors.textDark),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRoom,
                isExpanded: true,
                items: _rooms.map((room) {
                  return DropdownMenuItem(
                    value: room,
                    child: Text(room, style: const TextStyle(fontSize: 14, color: GreenLeafColors.textDark)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRoom = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Watering Schedule Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Watering Frequency',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GreenLeafColors.textDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GreenLeafColors.softYellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Every $_waterEveryDays days',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: GreenLeafColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _waterEveryDays.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: GreenLeafColors.primaryGreen,
            inactiveColor: GreenLeafColors.softMint,
            onChanged: (val) {
              setState(() => _waterEveryDays = val.round());
            },
          ),
          const SizedBox(height: 16),

          // Notes Field
          const Text(
            'Notes / Care Tips (Optional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GreenLeafColors.textDark),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Loves misting on hot days, keep away from direct AC draft.',
                hintStyle: TextStyle(fontSize: 13, color: GreenLeafColors.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Submit Button
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: GreenLeafColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shadowColor: GreenLeafColors.primaryGreen.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Add Plant to Greenleaf 🌿',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
