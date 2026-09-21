import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WaterTrackerApp());
}

class WaterTrackerApp extends StatelessWidget {
  const WaterTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Water Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F8FC),
        fontFamily: 'Roboto',
      ),
      home: const WaterTrackerHome(),
    );
  }
}

class WaterTrackerHome extends StatefulWidget {
  const WaterTrackerHome({super.key});

  @override
  State<WaterTrackerHome> createState() => _WaterTrackerHomeState();
}

class _WaterTrackerHomeState extends State<WaterTrackerHome> {
  final TextEditingController _intakeController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  final GlobalKey<FormState> _intakeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _goalFormKey = GlobalKey<FormState>();

  int _totalIntake = 0;
  int _entryCount = 0;
  int _dailyGoal = 2000;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _intakeController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _totalIntake = prefs.getInt('totalIntake') ?? 0;
      _entryCount = prefs.getInt('entryCount') ?? 0;
      _dailyGoal = prefs.getInt('dailyGoal') ?? 2000;
      _goalController.text = _dailyGoal.toString();
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('totalIntake', _totalIntake);
    await prefs.setInt('entryCount', _entryCount);
    await prefs.setInt('dailyGoal', _dailyGoal);
  }

  void _updateGoal() {
    if (!_goalFormKey.currentState!.validate()) return;

    setState(() {
      _dailyGoal = int.parse(_goalController.text);
    });

    _saveData();

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Daily hydration goal updated!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1976D2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _addWaterIntake() {
    if (!_intakeFormKey.currentState!.validate()) return;

    final int addedAmount = int.parse(_intakeController.text);

    setState(() {
      _totalIntake += addedAmount;
      _entryCount++;
    });

    _saveData();

    _intakeController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$addedAmount ml added to today\'s intake 💧'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF00897B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 10),
              Text('Reset Intake?'),
            ],
          ),
          content: const Text(
            'This will reset today\'s water intake and entry count. Your daily goal will remain unchanged.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.pop(context);
                _resetData();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('totalIntake');
    await prefs.remove('entryCount');

    setState(() {
      _totalIntake = 0;
      _entryCount = 0;
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final double progress =
        _dailyGoal > 0 ? (_totalIntake / _dailyGoal).clamp(0.0, 1.0) : 0.0;

    final double percentage = progress * 100;

    final int remaining = (_dailyGoal - _totalIntake).clamp(0, _dailyGoal);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
            Color(0xFF64B5F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Hydration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Keep yourself hydrated',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showResetConfirmation,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 175,
            height: 175,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 175,
                  height: 175,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 14,
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                SizedBox(
                  width: 175,
                  height: 175,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 14,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'completed',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '$_totalIntake ml',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'of $_dailyGoal ml daily goal',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              remaining == 0
                  ? '🎉 Daily goal completed!'
                  : '$remaining ml remaining today',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _goalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: Color(0xFF1976D2),
                ),
                SizedBox(width: 10),
                Text(
                  'Daily Goal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Set your daily hydration target',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target amount',
                      suffixText: 'ml',
                      prefixIcon: const Icon(Icons.water_drop_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF5F8FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFF2196F3),
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a goal';
                      }

                      final int? val = int.tryParse(value);

                      if (val == null) {
                        return 'Invalid number';
                      }

                      if (val <= 0) {
                        return 'Must be positive';
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 58,
                  child: FilledButton(
                    onPressed: _updateGoal,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntakeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _intakeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.add_circle_rounded,
                  color: Color(0xFF00897B),
                ),
                SizedBox(width: 10),
                Text(
                  'Log Water',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Record how much water you just drank',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _intakeController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Water amount',
                hintText: 'e.g. 250',
                suffixText: 'ml',
                prefixIcon: const Icon(
                  Icons.local_drink_rounded,
                  color: Color(0xFF00897B),
                ),
                filled: true,
                fillColor: const Color(0xFFF5FAF9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF00897B),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a water amount';
                }

                final int? parsedValue = int.tryParse(value);

                if (parsedValue == null) {
                  return 'Please enter a valid number';
                }

                if (parsedValue <= 0) {
                  return 'Amount must be greater than zero';
                }

                return null;
              },
              onFieldSubmitted: (_) => _addWaterIntake(),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _addWaterIntake,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add Water Intake',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int remainingWater = (_dailyGoal - _totalIntake).clamp(0, _dailyGoal);

    final double completionPercentage = _dailyGoal > 0
        ? ((_totalIntake / _dailyGoal) * 100).clamp(0.0, 100.0)
        : 0.0;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Water',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Stay hydrated, stay healthy',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _showResetConfirmation,
                        icon: const Icon(Icons.refresh_rounded),
                        color: Colors.grey.shade700,
                        tooltip: 'Reset intake',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: _buildProgressCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.water_drop_outlined,
                      title: 'Consumed',
                      value: '$_totalIntake ml',
                      color: const Color(0xFF1976D2),
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.hourglass_bottom_rounded,
                      title: 'Remaining',
                      value: '$remainingWater ml',
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.format_list_numbered_rounded,
                      title: 'Entries',
                      value: '$_entryCount',
                      color: const Color(0xFF8E44AD),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                child: _buildGoalCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: _buildIntakeCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
