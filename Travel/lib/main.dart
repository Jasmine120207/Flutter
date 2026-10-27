// ============================================================
// GreenCity Transit v3.0
// Public Transport Information App  |  SDG 11: Sustainable Cities and Communities
//
// Single-file version: replace lib/main.dart with this file.
// No extra packages needed. All routes, fares and timings are
// FICTIONAL sample data for a college project.
//
// File map (search for the numbered headings):
//  1. Entry point + MaterialApp (routes + onGenerateRoute)
//  2. Route names + RouteGenerator
//  3. Models (PassengerType, BusTypeInfo, BusRoute)
//  4. Sample data: 41 Andhra Pradesh towns + 80+ bus routes
//  5. Journey planner engine (Dijkstra, finds ANY town-to-town trip)
//  6. Saved-routes store
//  7. Theme + shared widgets
//  8. Screens: Home, Search, Details, Fare Calculator, Planner,
//     Budget Explorer, Eco Impact, Inclusive Travel, Saved Routes, Town Hub,
//     SDG 11, About, Unknown
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// 1. ENTRY POINT + MaterialApp
// ============================================================

void main() {
  runApp(const GreenCityTransitApp());
}

class GreenCityTransitApp extends StatelessWidget {
  const GreenCityTransitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenCity Transit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,

      // Predefined screens: no arguments needed.
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.search: (context) => const RouteSearchScreen(),
        AppRoutes.fare: (context) => const FareCalculatorScreen(),
        AppRoutes.plan: (context) => const JourneyPlannerScreen(),
        AppRoutes.explore: (context) => const BudgetExplorerScreen(),
        AppRoutes.saved: (context) => const SavedRoutesScreen(),
        AppRoutes.sdg: (context) => const SdgScreen(),
        AppRoutes.eco: (context) => const EcoImpactScreen(),
        AppRoutes.inclusive: (context) => const InclusiveTravelScreen(),
        AppRoutes.about: (context) => const AboutScreen(),
      },

      // Dynamic screens, route arguments and unknown routes.
      onGenerateRoute: RouteGenerator.generateRoute,

      // Keeps the layout phone-sized on wide screens (Chrome / desktop).
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFEFF5F0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ClipRect(child: child),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 2. ROUTE NAMES + ROUTE GENERATOR
// ============================================================

class AppRoutes {
  AppRoutes._();

  // Handled by MaterialApp.routes
  static const String home = '/';
  static const String search = '/search';
  static const String fare = '/fare';
  static const String plan = '/plan';
  static const String explore = '/explore';
  static const String saved = '/saved';
  static const String sdg = '/sdg';
  static const String about = '/about';
  static const String eco = '/eco';
  static const String inclusive = '/inclusive';

  // Handled by onGenerateRoute (they carry arguments)
  static const String details = '/details'; // BusRoute
  static const String fareForRoute = '/fare-for-route'; // BusRoute
  static const String planFor = '/plan-for'; // JourneyArgs
  static const String town = '/town'; // String (town name)
  static const String ecoForRoute = '/eco-for-route'; // BusRoute
}

/// Arguments for the pre-filled journey planner.
class JourneyArgs {
  final String? from;
  final String? to;
  const JourneyArgs({this.from, this.to});
}

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.details:
        if (args is BusRoute) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => RouteDetailsScreen(route: args),
          );
        }
        return _errorRoute('Route Details needs a bus route to show.');

      case AppRoutes.fareForRoute:
        if (args is BusRoute) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => FareCalculatorScreen(initialRoute: args),
          );
        }
        return _errorRoute('Fare Calculator needs a bus route to start with.');

      case AppRoutes.ecoForRoute:
        if (args is BusRoute) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => EcoImpactScreen(initialRoute: args),
          );
        }
        return _errorRoute('Eco Impact needs a bus route to start with.');

      case AppRoutes.planFor:
        if (args is JourneyArgs) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => JourneyPlannerScreen(args: args),
          );
        }
        return _errorRoute('Journey Planner needs a start and end town.');

      case AppRoutes.town:
        if (args is String && kTownDistrict.containsKey(args)) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => TownScreen(town: args),
          );
        }
        return _errorRoute('Town Hub needs a valid town name.');

      default:
        // Unknown-route handling
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => UnknownRouteScreen(routeName: settings.name),
        );
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => UnknownRouteScreen(message: message),
    );
  }
}

// ============================================================
// 3. MODELS
// ============================================================

enum PassengerType {
  general('General', 0.0),
  student('Student', 0.25),
  senior('Senior citizen', 0.40),
  disabled('Differently-abled', 0.50);

  final String label;
  final double discount; // 0.25 = 25% off

  const PassengerType(this.label, this.discount);
}

/// Describes one kind of bus: price per km, speed, how often it runs.
class BusTypeInfo {
  final String name;
  final double ratePerKm; // sample rupees per km
  final int speedKmh; // average speed including stops
  final int intervalMin; // minutes between departures
  final Color bg;
  final Color fg;
  final String perks;
  final double co2PerKm; // sample grams of CO2 per passenger-km
  final String access; // accessibility / inclusion note (sample)

  const BusTypeInfo(
    this.name,
    this.ratePerKm,
    this.speedKmh,
    this.intervalMin,
    this.bg,
    this.fg,
    this.perks,
    this.co2PerKm,
    this.access,
  );
}

const Map<String, BusTypeInfo> kBusTypes = {
  'Ordinary': BusTypeInfo(
      'Ordinary',
      1.1,
      35,
      60,
      Color(0xFFE8F5E9),
      Color(0xFF2E7D32),
      'Cheapest. Stops at every village.',
      40,
      'Reserved seats for women, senior citizens and persons with disabilities.'),
  'Express': BusTypeInfo(
      'Express',
      1.5,
      45,
      90,
      Color(0xFFDCEDC8),
      Color(0xFF33691E),
      'Fewer stops, saves time.',
      35,
      'Reserved seats for women, senior citizens and persons with disabilities.'),
  'Deluxe': BusTypeInfo(
      'Deluxe',
      2.0,
      50,
      180,
      Color(0xFFB2DFDB),
      Color(0xFF004D40),
      'Push-back seats for long trips.',
      38,
      'Reserved seats and extra legroom. Low-floor boarding on selected buses (sample).'),
  'AC': BusTypeInfo(
      'AC',
      2.6,
      52,
      240,
      Color(0xFFC8E6C9),
      Color(0xFF1B5E20),
      'Air-conditioned, most comfortable.',
      50,
      'Reserved seats, low-floor ramp and CCTV (sample).'),
};

/// A private way of travelling, used to compare against the bus.
class EcoMode {
  final String name;
  final IconData icon;
  final double gramsPerKm; // sample CO2 grams per km (one person)
  final double costPerKm; // sample running cost in rupees per km

  const EcoMode(this.name, this.icon, this.gramsPerKm, this.costPerKm);
}

// Illustrative sample values for learning, not official statistics.
const List<EcoMode> kPrivateModes = [
  EcoMode('Car', Icons.directions_car, 170, 9),
  EcoMode('Two-wheeler', Icons.two_wheeler, 75, 3),
  EcoMode('Auto-rickshaw', Icons.local_taxi, 90, 12),
];

const double kKgCo2PerTreePerYear = 21; // approximate

String fmtTime(int minutes) {
  final h = (minutes ~/ 60) % 24;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

String fmtDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

class BusRoute {
  final String id;
  final String busType;
  final int distanceKm;
  final List<String> stops; // includes source (first) and destination (last)
  final int firstDeparture; // minutes after midnight

  const BusRoute({
    required this.id,
    required this.busType,
    required this.distanceKm,
    required this.stops,
    required this.firstDeparture,
  });

  String get source => stops.first;
  String get destination => stops.last;
  String get title => '$source → $destination';
  BusTypeInfo get info => kBusTypes[busType]!;

  /// Sample fare in rupees for any bus type and passenger type.
  int fareOn(String type, [PassengerType p = PassengerType.general]) {
    final rate = kBusTypes[type]!.ratePerKm;
    var base = (distanceKm * rate).round();
    if (base < 10) base = 10;
    var fare = (base * (1 - p.discount)).round();
    if (fare < 5) fare = 5;
    return fare;
  }

  int minutesOn(String type) {
    final m = (distanceKm / kBusTypes[type]!.speedKmh * 60).round();
    final rounded = ((m / 5).round()) * 5;
    return rounded < 5 ? 5 : rounded;
  }

  int get baseFare => fareOn(busType);

  /// Sample CO2 (kg) emitted per passenger on this route.
  double get co2Kg => distanceKm * info.co2PerKm / 1000;
  double get carCo2Kg => distanceKm * kPrivateModes.first.gramsPerKm / 1000;
  double get co2SavedKg => carCo2Kg - co2Kg;
  int fareFor(PassengerType p) => fareOn(busType, p);
  int get durationMinutes => minutesOn(busType);
  String get durationText => fmtDuration(durationMinutes);

  /// Every departure of the day in minutes after midnight.
  List<int> get departureMinutes {
    final list = <int>[];
    for (var t = firstDeparture; t <= 21 * 60 + 30; t += info.intervalMin) {
      list.add(t);
    }
    return list;
  }

  String nextBusText(DateTime now) {
    final nowMin = now.hour * 60 + now.minute;
    for (final d in departureMinutes) {
      if (d >= nowMin) {
        final wait = d - nowMin;
        return wait == 0
            ? 'A bus is departing right now (${fmtTime(d)})'
            : 'Next bus in ${fmtDuration(wait)} (at ${fmtTime(d)})';
      }
    }
    return 'Next bus tomorrow at ${fmtTime(departureMinutes.first)}';
  }

  String other(String town) => town == source ? destination : source;

  bool connects(String a, String b) =>
      (source == a && destination == b) || (source == b && destination == a);

  @override
  bool operator ==(Object other) => other is BusRoute && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// 4. SAMPLE DATA (fictional) – towns of Andhra Pradesh
// ============================================================

const Map<String, String> kTownDistrict = {
  'Adoni': 'Kurnool',
  'Amalapuram': 'Konaseema',
  'Anakapalle': 'Anakapalle',
  'Anantapur': 'Anantapur',
  'Bapatla': 'Bapatla',
  'Bhimavaram': 'West Godavari',
  'Chirala': 'Bapatla',
  'Chittoor': 'Chittoor',
  'Dhone': 'Nandyal',
  'Dharmavaram': 'Sri Sathya Sai',
  'Eluru': 'Eluru',
  'Gooty': 'Anantapur',
  'Gudivada': 'Krishna',
  'Guntur': 'Guntur',
  'Hindupur': 'Sri Sathya Sai',
  'Kadapa': 'YSR Kadapa',
  'Kakinada': 'Kakinada',
  'Kurnool': 'Kurnool',
  'Machilipatnam': 'Krishna',
  'Madanapalle': 'Annamayya',
  'Markapur': 'Prakasam',
  'Nandyal': 'Nandyal',
  'Narasaraopet': 'Palnadu',
  'Narsapur': 'West Godavari',
  'Nellore': 'Nellore',
  'Ongole': 'Prakasam',
  'Proddatur': 'YSR Kadapa',
  'Puttaparthi': 'Sri Sathya Sai',
  'Rajahmundry': 'East Godavari',
  'Rayachoti': 'Annamayya',
  'Srikakulam': 'Srikakulam',
  'Srikalahasti': 'Tirupati',
  'Srisailam': 'Nandyal',
  'Tadepalligudem': 'West Godavari',
  'Tadipatri': 'Anantapur',
  'Tenali': 'Guntur',
  'Tirupati': 'Tirupati',
  'Tuni': 'Kakinada',
  'Vijayawada': 'NTR',
  'Visakhapatnam': 'Visakhapatnam',
  'Vizianagaram': 'Vizianagaram',
};

final List<String> townNames = (kTownDistrict.keys.toList()..sort());

class _Raw {
  final String a;
  final String b;
  final int km;
  final String type;
  final List<String> via;
  const _Raw(this.a, this.b, this.km, this.type, [this.via = const []]);
}

// Each line is a corridor. Buses run in BOTH directions.
const List<_Raw> _raw = [
  // --- Kurnool / Nandyal region ---
  _Raw('Nandyal', 'Kurnool', 55, 'Ordinary', ['Panyam', 'Orvakal']),
  _Raw('Nandyal', 'Kurnool', 55, 'Express'),
  _Raw('Nandyal', 'Kadapa', 115, 'Ordinary', ['Allagadda', 'Jammalamadugu']),
  _Raw('Nandyal', 'Kadapa', 115, 'Express'),
  _Raw('Nandyal', 'Srisailam', 160, 'Express', ['Atmakur', 'Dornala']),
  _Raw('Nandyal', 'Dhone', 55, 'Ordinary', ['Banaganapalle']),
  _Raw('Dhone', 'Gooty', 65, 'Ordinary', ['Pathikonda']),
  _Raw('Kurnool', 'Adoni', 95, 'Express', ['Kallur']),
  _Raw('Kurnool', 'Adoni', 95, 'Ordinary', ['Kodumur', 'Yemmiganur']),
  _Raw('Kurnool', 'Anantapur', 135, 'Express', ['Pathikonda', 'Gooty']),
  _Raw('Kurnool', 'Anantapur', 135, 'Ordinary', ['Dhone', 'Gooty']),
  _Raw('Kurnool', 'Kadapa', 170, 'Deluxe', ['Nandyal']),
  _Raw('Adoni', 'Gooty', 100, 'Ordinary', ['Guntakal']),
  // --- Anantapur / Sri Sathya Sai region ---
  _Raw('Anantapur', 'Gooty', 50, 'Ordinary'),
  _Raw('Anantapur', 'Dharmavaram', 50, 'Ordinary', ['Bukkaraya Samudram']),
  _Raw('Anantapur', 'Tadipatri', 55, 'Ordinary'),
  _Raw('Anantapur', 'Hindupur', 100, 'Express', ['Penukonda']),
  _Raw('Anantapur', 'Puttaparthi', 80, 'Ordinary', ['Bukkapatnam']),
  _Raw('Dharmavaram', 'Puttaparthi', 40, 'Ordinary'),
  _Raw('Dharmavaram', 'Hindupur', 60, 'Ordinary', ['Mudigubba']),
  _Raw('Puttaparthi', 'Hindupur', 70, 'Ordinary', ['Penukonda']),
  _Raw('Anantapur', 'Kadapa', 140, 'Express', ['Tadipatri', 'Yerraguntla']),
  // --- Kadapa / Rayalaseema south ---
  _Raw('Tadipatri', 'Proddatur', 75, 'Ordinary', ['Yerraguntla']),
  _Raw('Proddatur', 'Kadapa', 45, 'Ordinary'),
  _Raw('Proddatur', 'Kadapa', 45, 'Express'),
  _Raw('Kadapa', 'Tirupati', 130, 'Express', ['Rajampet', 'Renigunta']),
  _Raw('Kadapa', 'Tirupati', 130, 'Ordinary', ['Rajampet', 'Renigunta']),
  _Raw('Kadapa', 'Rayachoti', 70, 'Ordinary', ['Lakkireddipalle']),
  _Raw('Rayachoti', 'Madanapalle', 75, 'Ordinary', ['Kalikiri']),
  _Raw('Madanapalle', 'Tirupati', 85, 'Express', ['Chandragiri']),
  _Raw('Madanapalle', 'Hindupur', 90, 'Ordinary', ['Kadiri']),
  _Raw('Madanapalle', 'Chittoor', 70, 'Ordinary', ['Punganur']),
  _Raw('Tirupati', 'Chittoor', 70, 'Express', ['Chandragiri']),
  _Raw('Tirupati', 'Srikalahasti', 40, 'Ordinary', ['Renigunta']),
  _Raw('Tirupati', 'Nellore', 140, 'Deluxe', ['Srikalahasti', 'Naidupeta']),
  _Raw('Tirupati', 'Nellore', 140, 'Ordinary', ['Srikalahasti', 'Gudur']),
  _Raw('Srikalahasti', 'Nellore', 100, 'Ordinary', ['Sullurpeta', 'Naidupeta']),
  _Raw('Kadapa', 'Nellore', 175, 'Express', ['Badvel', 'Atmakur']),
  // --- Nellore / Prakasam / Bapatla / Guntur ---
  _Raw('Nellore', 'Ongole', 120, 'Ordinary', ['Kavali', 'Singarayakonda']),
  _Raw('Nellore', 'Ongole', 120, 'Express', ['Kavali']),
  _Raw('Ongole', 'Chirala', 45, 'Ordinary', ['Vetapalem']),
  _Raw('Chirala', 'Bapatla', 20, 'Ordinary'),
  _Raw('Bapatla', 'Guntur', 55, 'Ordinary', ['Ponnur']),
  _Raw('Bapatla', 'Tenali', 35, 'Ordinary'),
  _Raw('Ongole', 'Guntur', 120, 'Express', ['Chirala', 'Bapatla']),
  _Raw('Ongole', 'Markapur', 85, 'Ordinary', ['Podili']),
  _Raw('Markapur', 'Srisailam', 100, 'Ordinary', ['Dornala']),
  _Raw('Markapur', 'Narasaraopet', 95, 'Ordinary', ['Vinukonda']),
  _Raw('Narasaraopet', 'Guntur', 50, 'Ordinary', ['Chilakaluripet']),
  _Raw('Guntur', 'Vijayawada', 35, 'Ordinary', ['Mangalagiri']),
  _Raw('Guntur', 'Vijayawada', 35, 'Express'),
  _Raw('Guntur', 'Tenali', 25, 'Ordinary'),
  _Raw('Tenali', 'Vijayawada', 40, 'Ordinary'),
  _Raw('Guntur', 'Kurnool', 340, 'Deluxe',
      ['Narasaraopet', 'Markapur', 'Nandyal']),
  // --- Krishna / Godavari belt ---
  _Raw('Vijayawada', 'Machilipatnam', 70, 'Ordinary', ['Gudlavalleru']),
  _Raw('Vijayawada', 'Gudivada', 45, 'Ordinary'),
  _Raw('Gudivada', 'Machilipatnam', 35, 'Ordinary'),
  _Raw('Vijayawada', 'Eluru', 65, 'Express', ['Hanuman Junction']),
  _Raw('Vijayawada', 'Eluru', 65, 'Ordinary',
      ['Gannavaram', 'Hanuman Junction']),
  _Raw('Eluru', 'Bhimavaram', 55, 'Ordinary', ['Akividu']),
  _Raw('Eluru', 'Tadepalligudem', 50, 'Ordinary', ['Bhimadole']),
  _Raw('Tadepalligudem', 'Rajahmundry', 70, 'Express', ['Nidadavolu']),
  _Raw('Tadepalligudem', 'Bhimavaram', 35, 'Ordinary', ['Tanuku']),
  _Raw('Bhimavaram', 'Narsapur', 40, 'Ordinary'),
  _Raw('Narsapur', 'Amalapuram', 60, 'Ordinary', ['Razole']),
  _Raw('Amalapuram', 'Kakinada', 55, 'Ordinary', ['Mummidivaram']),
  _Raw('Amalapuram', 'Rajahmundry', 60, 'Ordinary', ['Ravulapalem']),
  _Raw('Rajahmundry', 'Kakinada', 65, 'Express', ['Samalkot']),
  _Raw('Rajahmundry', 'Kakinada', 65, 'Ordinary', ['Rajanagaram', 'Samalkot']),
  _Raw(
      'Vijayawada', 'Rajahmundry', 150, 'Express', ['Eluru', 'Tadepalligudem']),
  _Raw('Vijayawada', 'Rajahmundry', 150, 'AC', ['Eluru']),
  // --- North coastal Andhra ---
  _Raw('Kakinada', 'Tuni', 55, 'Ordinary', ['Pithapuram']),
  _Raw('Tuni', 'Anakapalle', 70, 'Ordinary', ['Narsipatnam']),
  _Raw('Anakapalle', 'Visakhapatnam', 40, 'Ordinary', ['Sabbavaram']),
  _Raw('Kakinada', 'Visakhapatnam', 160, 'Express', ['Tuni', 'Anakapalle']),
  _Raw('Rajahmundry', 'Visakhapatnam', 190, 'Deluxe',
      ['Kakinada', 'Anakapalle']),
  _Raw('Visakhapatnam', 'Vizianagaram', 50, 'Ordinary', ['Pendurthi']),
  _Raw('Visakhapatnam', 'Vizianagaram', 50, 'Express'),
  _Raw('Vizianagaram', 'Srikakulam', 60, 'Ordinary', ['Chilakapalem']),
  _Raw('Visakhapatnam', 'Srikakulam', 110, 'Express', ['Vizianagaram']),
  // --- Long-distance intercity ---
  _Raw('Vijayawada', 'Visakhapatnam', 350, 'AC',
      ['Eluru', 'Rajahmundry', 'Kakinada', 'Anakapalle']),
  _Raw('Vijayawada', 'Visakhapatnam', 350, 'Deluxe',
      ['Rajahmundry', 'Anakapalle']),
  _Raw('Vijayawada', 'Nellore', 260, 'Deluxe', ['Guntur', 'Ongole', 'Kavali']),
  _Raw('Vijayawada', 'Tirupati', 390, 'AC', ['Guntur', 'Ongole', 'Nellore']),
];

/// Every direct bus route in the sample network.
final List<BusRoute> allRoutes = [
  for (var i = 0; i < _raw.length; i++)
    BusRoute(
      id: 'R${i + 1}',
      busType: _raw[i].type,
      distanceKm: _raw[i].km,
      stops: [_raw[i].a, ..._raw[i].via, _raw[i].b],
      firstDeparture: 5 * 60 + (i % 4) * 30 + (i % 3) * 10,
    ),
];

// ============================================================
// 5. JOURNEY PLANNER ENGINE (finds trips with bus changes)
// ============================================================

const int kTransferWaitMin = 30;

enum PlanMode {
  cheapest('Cheapest'),
  fastest('Fastest'),
  fewestChanges('Fewest changes');

  final String label;
  const PlanMode(this.label);
}

class Leg {
  final BusRoute route;
  final String from;
  final String to;
  const Leg(this.route, this.from, this.to);
}

class Journey {
  final List<Leg> legs;
  const Journey(this.legs);

  String get origin => legs.first.from;
  String get destination => legs.last.to;
  int get transfers => legs.length - 1;
  int get distanceKm => legs.fold<int>(0, (s, l) => s + l.route.distanceKm);
  int get minutes =>
      legs.fold<int>(0, (s, l) => s + l.route.durationMinutes) +
      transfers * kTransferWaitMin;
  int fareFor(PassengerType t) =>
      legs.fold<int>(0, (s, l) => s + l.route.fareFor(t));
  String get signature => legs.map((l) => l.route.id).join('>');
  double get co2Kg => legs.fold<double>(0, (s, l) => s + l.route.co2Kg);
  double get carCo2Kg => distanceKm * kPrivateModes.first.gramsPerKm / 1000;
}

class PlanRun {
  final String origin;
  final Map<String, Leg> _prev;
  const PlanRun(this.origin, this._prev);

  Journey? journeyTo(String dest) {
    if (dest == origin) return null;
    final legs = <Leg>[];
    var current = dest;
    while (current != origin) {
      final leg = _prev[current];
      if (leg == null) return null;
      legs.add(leg);
      current = leg.from;
    }
    return Journey(legs.reversed.toList());
  }
}

class TransitPlanner {
  TransitPlanner._();

  static final Map<String, List<BusRoute>> _adjacency = _buildAdjacency();

  static Map<String, List<BusRoute>> _buildAdjacency() {
    final map = <String, List<BusRoute>>{
      for (final t in townNames) t: <BusRoute>[],
    };
    for (final r in allRoutes) {
      map[r.source]!.add(r);
      map[r.destination]!.add(r);
    }
    return map;
  }

  static double _weight(PlanMode mode, BusRoute r) {
    switch (mode) {
      case PlanMode.cheapest:
        return r.baseFare.toDouble();
      case PlanMode.fastest:
        return (r.durationMinutes + kTransferWaitMin).toDouble();
      case PlanMode.fewestChanges:
        return 1000.0 + r.baseFare;
    }
  }

  /// Dijkstra's shortest-path algorithm from one town to all others.
  static PlanRun run(String from, PlanMode mode) {
    final dist = <String, double>{
      for (final t in townNames) t: double.infinity,
    };
    final prev = <String, Leg>{};
    final done = <String>{};
    dist[from] = 0;

    while (true) {
      String? u;
      var best = double.infinity;
      for (final t in townNames) {
        if (!done.contains(t) && dist[t]! < best) {
          best = dist[t]!;
          u = t;
        }
      }
      if (u == null) break;
      done.add(u);
      for (final r in _adjacency[u]!) {
        final v = r.other(u);
        final candidate = best + _weight(mode, r);
        if (candidate < dist[v]!) {
          dist[v] = candidate;
          prev[v] = Leg(r, u, v);
        }
      }
    }
    return PlanRun(from, prev);
  }

  static Journey? plan(String from, String to, PlanMode mode) =>
      run(from, mode).journeyTo(to);
}

// ============================================================
// 6. SAVED ROUTES STORE (kept in memory while the app runs)
// ============================================================

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._();
  static final FavoritesStore instance = FavoritesStore._();

  final Set<String> _ids = {};

  bool isSaved(String id) => _ids.contains(id);

  void toggle(String id) {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
  }

  List<BusRoute> get routes =>
      allRoutes.where((r) => _ids.contains(r.id)).toList();
}

// ============================================================
// 7. THEME + SHARED WIDGETS
// ============================================================

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color dark = Color(0xFF1B5E20);
  static const Color accent = Color(0xFF66BB6A);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final String? subtitle;
  const SectionTitle(this.text, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.dark,
            ),
          ),
          if (subtitle != null)
            Text(subtitle!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class BusTypeBadge extends StatelessWidget {
  final String type;
  const BusTypeBadge(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    final info = kBusTypes[type]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: info.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: info.fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Bookmark button that adds/removes a route from Saved Routes.
class SaveButton extends StatelessWidget {
  final BusRoute route;
  final Color? color;
  const SaveButton({super.key, required this.route, this.color});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoritesStore.instance,
      builder: (context, _) {
        final saved = FavoritesStore.instance.isSaved(route.id);
        return IconButton(
          tooltip: saved ? 'Remove from saved' : 'Save route',
          visualDensity: VisualDensity.compact,
          icon: Icon(
            saved ? Icons.bookmark : Icons.bookmark_border,
            color: color ?? AppTheme.primary,
          ),
          onPressed: () => FavoritesStore.instance.toggle(route.id),
        );
      },
    );
  }
}

class TownDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const TownDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      isEmpty: value == null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: const Text('Select town'),
          items: [
            for (final t in townNames)
              DropdownMenuItem(value: t, child: Text(t)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class PassengerChips extends StatelessWidget {
  final PassengerType selected;
  final ValueChanged<PassengerType> onChanged;
  const PassengerChips(
      {super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final t in PassengerType.values)
          ChoiceChip(
            label: Text(t.label),
            selected: selected == t,
            onSelected: (_) => onChanged(t),
          ),
      ],
    );
  }
}

class RouteCard extends StatelessWidget {
  final BusRoute route;
  final VoidCallback onTap;
  final String? fromTown; // shows the arrow from this town's point of view

  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
    this.fromTown,
  });

  @override
  Widget build(BuildContext context) {
    final title = fromTown == null
        ? route.title
        : '$fromTown → ${route.other(fromTown!)}';

    return Card(
      elevation: 1.5,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.primaryLight, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.directions_bus, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        BusTypeBadge(route.busType),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${route.distanceKm} km • ${route.durationText}',
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${route.baseFare}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    'Student ₹${route.fareFor(PassengerType.student)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
              SaveButton(route: route),
            ],
          ),
        ),
      ),
    );
  }
}

void openDetails(BuildContext context, BusRoute r) {
  Navigator.pushNamed(context, AppRoutes.details, arguments: r);
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, String? route) {
      return ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(label),
        onTap: () {
          Navigator.pop(context);
          if (route != null) Navigator.pushNamed(context, route);
        },
      );
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 160,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
            decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.directions_bus_filled,
                    color: Colors.white, size: 36),
                SizedBox(height: 8),
                Text('GreenCity Transit',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('SDG 11: Sustainable Cities',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          item(Icons.home_outlined, 'Home', null),
          item(Icons.alt_route, 'Plan a Journey', AppRoutes.plan),
          item(Icons.search, 'Search Routes', AppRoutes.search),
          item(Icons.calculate_outlined, 'Fare Calculator', AppRoutes.fare),
          item(Icons.explore_outlined, 'Budget Explorer', AppRoutes.explore),
          item(Icons.bookmark_outline, 'Saved Routes', AppRoutes.saved),
          item(Icons.eco_outlined, 'Eco Impact', AppRoutes.eco),
          item(Icons.accessible, 'Inclusive Travel', AppRoutes.inclusive),
          const Divider(),
          item(Icons.location_city_outlined, 'SDG 11: Sustainable Cities',
              AppRoutes.sdg),
          item(Icons.info_outline, 'About', AppRoutes.about),
        ],
      ),
    );
  }
}

// ============================================================
// 8a. HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _from = 'Nandyal';
  String? _to = 'Tirupati';

  static const List<String> _tips = [
    'One bus can take many cars off the road. Check the Eco Impact screen to see your CO\u2082 savings.',
    'Students get 25% off in this sample fare system. Always carry your ID card.',
    'Reserved seats are kept for women, senior citizens and persons with disabilities.',
    'Use Budget Explorer to find every town you can reach within your travel budget.',
    'The cheapest trip is not always the fastest. Compare both in the Journey Planner.',
    'Choosing Ordinary or Express over a private vehicle saves both money and emissions.',
  ];

  @override
  Widget build(BuildContext context) {
    final cheapest = [...allRoutes]
      ..sort((a, b) => a.baseFare.compareTo(b.baseFare));
    final lowestFare = cheapest.first.baseFare;
    final tip = _tips[DateTime.now().day % _tips.length];

    return Scaffold(
      appBar: AppBar(title: const Text('GreenCity Transit')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.directions_bus_filled,
                    color: Colors.white, size: 36),
                SizedBox(height: 10),
                Text(
                  'Safe, affordable and green travel for all',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Plan public transport journeys across Andhra Pradesh. Save money, cut pollution and connect towns with villages.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stats
          Row(
            children: [
              _StatBox(value: '${townNames.length}', label: 'Towns'),
              const SizedBox(width: 10),
              _StatBox(value: '${allRoutes.length}', label: 'Bus routes'),
              const SizedBox(width: 10),
              _StatBox(value: '₹$lowestFare', label: 'Lowest fare'),
            ],
          ),
          const SizedBox(height: 16),

          // Quick journey planner
          Card(
            elevation: 3,
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppTheme.primaryLight, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Where do you want to go?',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TownDropdown(
                    label: 'From',
                    value: _from,
                    icon: Icons.trip_origin,
                    onChanged: (v) => setState(() => _from = v),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Swap',
                      onPressed: () => setState(() {
                        final t = _from;
                        _from = _to;
                        _to = t;
                      }),
                      icon:
                          const Icon(Icons.swap_vert, color: AppTheme.primary),
                    ),
                  ),
                  TownDropdown(
                    label: 'To',
                    value: _to,
                    icon: Icons.location_on,
                    onChanged: (v) => setState(() => _to = v),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.planFor,
                        arguments: JourneyArgs(from: _from, to: _to),
                      ),
                      icon: const Icon(Icons.alt_route),
                      label: const Text('Find cheapest journey'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const SectionTitle('Explore'),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final cols = constraints.maxWidth >= 560 ? 3 : 2;
              final tileWidth =
                  (constraints.maxWidth - spacing * (cols - 1)) / cols;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final t in _homeTiles)
                    SizedBox(
                      width: tileWidth,
                      height: 140,
                      child: _FeatureTile(data: t),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Tip of the day
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Money-saving tip',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.dark)),
                      const SizedBox(height: 2),
                      Text(tip),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          const SectionTitle('Cheapest bus routes'),
          for (final r in cheapest.take(4))
            RouteCard(route: r, onTap: () => openDetails(context, r)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary)),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}

class _TileData {
  final IconData icon; // small icon in the white circle
  final IconData art; // large illustration
  final IconData accent; // small decoration
  final String label;
  final String hint;
  final String route;
  final Color c1;
  final Color c2;

  const _TileData({
    required this.icon,
    required this.art,
    required this.accent,
    required this.label,
    required this.hint,
    required this.route,
    required this.c1,
    required this.c2,
  });
}

const List<_TileData> _homeTiles = [
  _TileData(
    icon: Icons.search,
    art: Icons.map,
    accent: Icons.place,
    label: 'Search Routes',
    hint: 'Filter by town, type, fare',
    route: AppRoutes.search,
    c1: Color(0xFF1B5E20),
    c2: Color(0xFF43A047),
  ),
  _TileData(
    icon: Icons.calculate,
    art: Icons.savings,
    accent: Icons.payments,
    label: 'Fare Calculator',
    hint: 'Monthly cost & pass savings',
    route: AppRoutes.fare,
    c1: Color(0xFF2E7D32),
    c2: Color(0xFF66BB6A),
  ),
  _TileData(
    icon: Icons.explore,
    art: Icons.explore,
    accent: Icons.directions_bus,
    label: 'Budget Explorer',
    hint: 'Where can my money take me?',
    route: AppRoutes.explore,
    c1: Color(0xFF00695C),
    c2: Color(0xFF26A69A),
  ),
  _TileData(
    icon: Icons.bookmark,
    art: Icons.bookmarks,
    accent: Icons.star,
    label: 'Saved Routes',
    hint: 'Your favourite buses',
    route: AppRoutes.saved,
    c1: Color(0xFF388E3C),
    c2: Color(0xFF81C784),
  ),
  _TileData(
    icon: Icons.eco,
    art: Icons.park,
    accent: Icons.air,
    label: 'Eco Impact',
    hint: 'CO\u2082 and money you save',
    route: AppRoutes.eco,
    c1: Color(0xFF33691E),
    c2: Color(0xFF689F38),
  ),
  _TileData(
    icon: Icons.accessible,
    art: Icons.groups,
    accent: Icons.favorite,
    label: 'Inclusive Travel',
    hint: 'Safety, seats & concessions',
    route: AppRoutes.inclusive,
    c1: Color(0xFF00796B),
    c2: Color(0xFF4DB6AC),
  ),
  _TileData(
    icon: Icons.location_city,
    art: Icons.apartment,
    accent: Icons.eco,
    label: 'SDG 11: Sustainable Cities',
    hint: 'Why this app exists',
    route: AppRoutes.sdg,
    c1: Color(0xFF1B5E20),
    c2: Color(0xFF2E7D32),
  ),
  _TileData(
    icon: Icons.info_outline,
    art: Icons.directions_bus_filled,
    accent: Icons.info,
    label: 'About',
    hint: 'App info & disclaimer',
    route: AppRoutes.about,
    c1: Color(0xFF33691E),
    c2: Color(0xFF7CB342),
  ),
];

class _FeatureTile extends StatelessWidget {
  final _TileData data;
  const _FeatureTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [data.c1, data.c2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, data.route),
            child: Stack(
              children: [
                // Large faded illustration
                Positioned(
                  right: -16,
                  bottom: -20,
                  child:
                      Icon(data.art, size: 120, color: const Color(0x33FFFFFF)),
                ),
                // Small decoration
                Positioned(
                  right: 14,
                  top: 12,
                  child: Icon(data.accent,
                      size: 26, color: const Color(0xAAFFFFFF)),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(data.icon, color: AppTheme.primary, size: 24),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data.hint,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
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

// ============================================================
// 8b. ROUTE SEARCH SCREEN
// ============================================================

enum _SortMode {
  cheapest('Cheapest'),
  fastest('Fastest'),
  shortest('Shortest distance');

  final String label;
  const _SortMode(this.label);
}

class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({super.key});

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  String _query = '';
  String _busType = 'All';
  _SortMode _sort = _SortMode.cheapest;

  late final double _sliderMax = _computeSliderMax();
  late double _maxFare = _sliderMax;

  static double _computeSliderMax() {
    var m = 0;
    for (final r in allRoutes) {
      if (r.baseFare > m) m = r.baseFare;
    }
    return (((m + 9) ~/ 10) * 10).toDouble();
  }

  List<BusRoute> get _results {
    final q = _query.trim().toLowerCase();

    final list = allRoutes.where((r) {
      final matchesText = q.isEmpty ||
          r.stops.any((s) => s.toLowerCase().contains(q)) ||
          (kTownDistrict[r.source] ?? '').toLowerCase().contains(q) ||
          (kTownDistrict[r.destination] ?? '').toLowerCase().contains(q);
      final matchesType = _busType == 'All' || r.busType == _busType;
      return matchesText && matchesType && r.baseFare <= _maxFare;
    }).toList();

    switch (_sort) {
      case _SortMode.cheapest:
        list.sort((a, b) => a.baseFare.compareTo(b.baseFare));
        break;
      case _SortMode.fastest:
        list.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        break;
      case _SortMode.shortest:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final types = ['All', ...kBusTypes.keys];

    return Scaffold(
      appBar: AppBar(title: const Text('Search Routes')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Town, stop or district (e.g. Nandyal)',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final t in types)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(t),
                        selected: _busType == t,
                        onSelected: (_) => setState(() => _busType = t),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Text('Max fare: ₹${_maxFare.round()}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  child: Slider(
                    value: _maxFare,
                    min: 20,
                    max: _sliderMax,
                    divisions: (_sliderMax - 20) ~/ 10,
                    label: '₹${_maxFare.round()}',
                    onChanged: (v) => setState(() => _maxFare = v),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(Icons.sort, size: 18),
                  const SizedBox(width: 6),
                  for (final s in _SortMode.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(s.label),
                        selected: _sort == s,
                        onSelected: (_) => setState(() => _sort = s),
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('${results.length} route(s) found',
                    style: TextStyle(color: Colors.grey.shade700)),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No routes match your search.'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final r = results[index];
                        return RouteCard(
                            route: r, onTap: () => openDetails(context, r));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 8c. ROUTE DETAILS SCREEN
// ============================================================

class RouteDetailsScreen extends StatelessWidget {
  final BusRoute route;

  const RouteDetailsScreen({super.key, required this.route});

  int _approxFare(int i) {
    final f = (route.baseFare * i / (route.stops.length - 1)).round();
    return f < 5 ? 5 : f;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final deps = route.departureMinutes;
    final nextIndex = deps.indexWhere((d) => d >= nowMin);
    final siblings = allRoutes
        .where((r) =>
            r.id != route.id && r.connects(route.source, route.destination))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Details'),
        actions: [SaveButton(route: route, color: Colors.white)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${kTownDistrict[route.source]} → ${kTownDistrict[route.destination]} district  •  Route ${route.id}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    BusTypeBadge(route.busType),
                    _WhitePill('${route.distanceKm} km'),
                    _WhitePill(route.durationText),
                    _WhitePill('₹${route.baseFare}'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(route.info.perks,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Next bus
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    route.nextBusText(now),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppTheme.dark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _EcoStrip(route: route),
          const SizedBox(height: 12),

          const SectionTitle('Sample fares (one way)'),
          Card(
            color: AppTheme.primaryLight,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: Column(
              children: [
                for (final t in PassengerType.values)
                  ListTile(
                    dense: true,
                    title: Text(t.label),
                    subtitle: t.discount > 0
                        ? Text('${(t.discount * 100).round()}% discount')
                        : null,
                    trailing: Text(
                      '₹${route.fareFor(t)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SectionTitle('Departures today',
              subtitle:
                  'Every ${route.info.intervalMin} minutes. Highlighted = next bus'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < deps.length; i++)
                Chip(
                  label: Text(
                    fmtTime(deps[i]),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: i == nextIndex ? Colors.white : AppTheme.dark,
                    ),
                  ),
                  backgroundColor:
                      i == nextIndex ? AppTheme.primary : AppTheme.primaryLight,
                  side: BorderSide.none,
                ),
            ],
          ),

          const SectionTitle('Stops',
              subtitle:
                  'Tap a town to see all buses from there. Fares are approximate.'),
          for (var i = 0; i < route.stops.length; i++)
            _StopRow(
              name: route.stops[i],
              index: i,
              isLast: i == route.stops.length - 1,
              approxFare: i == 0 ? null : _approxFare(i),
            ),

          if (siblings.isNotEmpty) ...[
            const SectionTitle('Other buses on this corridor',
                subtitle: 'Compare bus types for the same trip'),
            for (final r in siblings)
              RouteCard(route: r, onTap: () => openDetails(context, r)),
          ],
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.fareForRoute,
              arguments: route,
            ),
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate my fare & monthly cost'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.ecoForRoute,
              arguments: route,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.eco),
            label: const Text('See my eco impact'),
          ),
          const SizedBox(height: 8),
          Text(
            'Sample data for learning only. Not real timetables or fares.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _WhitePill extends StatelessWidget {
  final String text;
  const _WhitePill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(
              color: AppTheme.dark, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class _StopRow extends StatelessWidget {
  final String name;
  final int index;
  final bool isLast;
  final int? approxFare;

  const _StopRow({
    required this.name,
    required this.index,
    required this.isLast,
    required this.approxFare,
  });

  @override
  Widget build(BuildContext context) {
    final isTown = kTownDistrict.containsKey(name);
    final icon = index == 0
        ? Icons.trip_origin
        : (isLast ? Icons.location_on : Icons.circle_outlined);

    return InkWell(
      onTap: isTown
          ? () => Navigator.pushNamed(context, AppRoutes.town, arguments: name)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isTown ? FontWeight.bold : FontWeight.normal,
                  color: isTown ? AppTheme.dark : Colors.black87,
                ),
              ),
            ),
            if (approxFare != null)
              Text('≈ ₹$approxFare',
                  style: TextStyle(color: Colors.grey.shade700)),
            if (isTown)
              const Icon(Icons.chevron_right,
                  size: 18, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 8d. FARE CALCULATOR SCREEN (+ affordability check)
// ============================================================

class FareCalculatorScreen extends StatefulWidget {
  final BusRoute? initialRoute;

  const FareCalculatorScreen({super.key, this.initialRoute});

  @override
  State<FareCalculatorScreen> createState() => _FareCalculatorScreenState();
}

class _FareCalculatorScreenState extends State<FareCalculatorScreen> {
  late BusRoute _route;
  PassengerType _type = PassengerType.general;
  int _passengers = 1;
  bool _roundTrip = false;
  double _income = 15000; // monthly income in rupees
  double _days = 26; // travel days per month

  @override
  void initState() {
    super.initState();
    _route = widget.initialRoute ?? allRoutes.first;
  }

  @override
  Widget build(BuildContext context) {
    final perPerson = _route.fareFor(_type);
    final total = perPerson * _passengers * (_roundTrip ? 2 : 1);

    // Monthly commute maths
    final monthly = perPerson * 2 * _days.round();
    final share = monthly / _income * 100;
    final pass = (monthly * 0.8).round(); // sample 20% off monthly pass
    final saving = monthly - pass;

    final String level;
    final Color levelColor;
    if (share <= 10) {
      level = 'Comfortable';
      levelColor = AppTheme.primary;
    } else if (share <= 20) {
      level = 'Stretching your budget';
      levelColor = Colors.orange.shade800;
    } else {
      level = 'Heavy burden on your income';
      levelColor = Colors.red.shade700;
    }

    final fares = {
      for (final t in kBusTypes.keys) t: _route.fareOn(t, _type),
    };
    final minFare = fares.values.reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Fare Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Choose route',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BusRoute>(
                value: _route,
                isExpanded: true,
                items: [
                  for (final r in allRoutes)
                    DropdownMenuItem(
                      value: r,
                      child: Text(
                        '${r.title} (${r.busType})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _route = value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Passenger type',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          PassengerChips(
            selected: _type,
            onChanged: (t) => setState(() => _type = t),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Expanded(
                child: Text('Passengers',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: _passengers > 1
                    ? () => setState(() => _passengers--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_passengers', style: const TextStyle(fontSize: 18)),
              IconButton(
                onPressed: _passengers < 10
                    ? () => setState(() => _passengers++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Round trip'),
            value: _roundTrip,
            onChanged: (v) => setState(() => _roundTrip = v),
          ),
          const SizedBox(height: 8),

          // Result card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Text('Total fare',
                    style: TextStyle(color: Colors.white70)),
                Text(
                  '₹$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹$perPerson per person, one way  •  ${_route.durationText}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Affordability checker
          const SectionTitle('Can I afford this commute?',
              subtitle: 'Round trips on this route, every travel day'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly income: ₹${_income.round()}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: _income,
                  min: 5000,
                  max: 50000,
                  divisions: 45,
                  label: '₹${_income.round()}',
                  onChanged: (v) => setState(() => _income = v),
                ),
                Text('Travel days per month: ${_days.round()}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: _days,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '${_days.round()} days',
                  onChanged: (v) => setState(() => _days = v),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly travel cost'),
                    Text('₹$monthly',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${share.toStringAsFixed(1)}% of your income  •  $level',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: levelColor),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (share / 40).clamp(0.0, 1.0).toDouble(),
                  minHeight: 10,
                  color: levelColor,
                  backgroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.savings, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sample monthly pass (20% off): ₹$pass\nYou save ₹$saving a month, ₹${saving * 12} a year.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bus type comparison
          const SectionTitle('Same distance, different buses',
              subtitle: 'One person, one way, with your passenger discount'),
          Card(
            color: AppTheme.primaryLight,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: Column(
              children: [
                for (final entry in fares.entries)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.directions_bus,
                        color: AppTheme.primary),
                    title: Row(
                      children: [
                        Text(entry.key),
                        if (entry.value == minFare) ...[
                          const SizedBox(width: 8),
                          const Text('cheapest',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                    subtitle: Text(fmtDuration(_route.minutesOn(entry.key))),
                    trailing: Text(
                      '₹${entry.value}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sample fares only. Discounts and passes are fictional.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 8e. JOURNEY PLANNER SCREEN (any town to any town)
// ============================================================

class _PlanOption {
  final Journey journey;
  final List<String> labels;
  _PlanOption(this.journey, this.labels);
}

class JourneyPlannerScreen extends StatefulWidget {
  final JourneyArgs? args;
  const JourneyPlannerScreen({super.key, this.args});

  @override
  State<JourneyPlannerScreen> createState() => _JourneyPlannerScreenState();
}

class _JourneyPlannerScreenState extends State<JourneyPlannerScreen> {
  String? _from;
  String? _to;
  PassengerType _type = PassengerType.general;

  @override
  void initState() {
    super.initState();
    _from = widget.args?.from;
    _to = widget.args?.to;
  }

  List<_PlanOption> _options(String from, String to) {
    final out = <_PlanOption>[];
    for (final mode in PlanMode.values) {
      final j = TransitPlanner.plan(from, to, mode);
      if (j == null) continue;
      final idx = out.indexWhere((o) => o.journey.signature == j.signature);
      if (idx >= 0) {
        out[idx].labels.add(mode.label);
      } else {
        out.add(_PlanOption(j, [mode.label]));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final from = _from;
    final to = _to;

    Widget body;
    if (from == null || to == null) {
      body = const _HintCard(
        icon: Icons.touch_app,
        text: 'Choose a start town and a destination to see journeys.',
      );
    } else if (from == to) {
      body = const _HintCard(
        icon: Icons.sync_problem,
        text:
            'Start and destination are the same town. Pick two different towns.',
      );
    } else {
      final options = _options(from, to);
      final directs = allRoutes.where((r) => r.connects(from, to)).toList()
        ..sort((a, b) => a.baseFare.compareTo(b.baseFare));

      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (options.isEmpty)
            const _HintCard(
              icon: Icons.block,
              text:
                  'No connection found between these towns in the sample network.',
            )
          else ...[
            SectionTitle('Best ways to travel',
                subtitle:
                    '${options.length} option(s) found, including bus changes'),
            for (final o in options) _JourneyCard(option: o, type: _type),
          ],
          if (directs.isNotEmpty) ...[
            const SectionTitle('All direct buses'),
            for (final r in directs)
              RouteCard(
                route: r,
                fromTown: from,
                onTap: () => openDetails(context, r),
              ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Journey Planner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TownDropdown(
            label: 'From',
            value: _from,
            icon: Icons.trip_origin,
            onChanged: (v) => setState(() => _from = v),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Swap',
              onPressed: () => setState(() {
                final t = _from;
                _from = _to;
                _to = t;
              }),
              icon: const Icon(Icons.swap_vert, color: AppTheme.primary),
            ),
          ),
          TownDropdown(
            label: 'To',
            value: _to,
            icon: Icons.location_on,
            onChanged: (v) => setState(() => _to = v),
          ),
          const SizedBox(height: 12),
          PassengerChips(
            selected: _type,
            onChanged: (t) => setState(() => _type = t),
          ),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HintCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 30),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final _PlanOption option;
  final PassengerType type;
  const _JourneyCard({required this.option, required this.type});

  @override
  Widget build(BuildContext context) {
    final j = option.journey;

    return Card(
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.primaryLight, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              children: [
                for (final label in option.labels)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('₹${j.fareFor(type)}',
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '${fmtDuration(j.minutes)} total  •  ${j.distanceKm} km\n'
                    '${j.transfers == 0 ? 'Direct, no bus change' : '${j.transfers} bus change(s)'}',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.eco, size: 16, color: AppTheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '\u2248 ${j.co2Kg.toStringAsFixed(1)} kg CO\u2082 per person vs ${j.carCo2Kg.toStringAsFixed(1)} kg by car',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
            for (var i = 0; i < j.legs.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz,
                          size: 18, color: Colors.orange.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Change buses at ${j.legs[i].from} (about $kTransferWaitMin min wait)',
                          style: TextStyle(
                              fontSize: 12, color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              InkWell(
                onTap: () => openDetails(context, j.legs[i].route),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus,
                          color: AppTheme.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${j.legs[i].from} → ${j.legs[i].to}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                BusTypeBadge(j.legs[i].route.busType),
                                const SizedBox(width: 6),
                                Text(
                                  '${j.legs[i].route.distanceKm} km • ${j.legs[i].route.durationText}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text('₹${j.legs[i].route.fareFor(type)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 8f. BUDGET EXPLORER SCREEN ("Where can my money take me?")
// ============================================================

class BudgetExplorerScreen extends StatefulWidget {
  const BudgetExplorerScreen({super.key});

  @override
  State<BudgetExplorerScreen> createState() => _BudgetExplorerScreenState();
}

class _BudgetExplorerScreenState extends State<BudgetExplorerScreen> {
  String _origin = 'Nandyal';
  double _budget = 150;
  PassengerType _type = PassengerType.general;
  bool _directOnly = false;

  List<Journey> _reachable() {
    final result = <Journey>[];
    final run = TransitPlanner.run(_origin, PlanMode.cheapest);

    for (final town in townNames) {
      if (town == _origin) continue;
      Journey? j;
      if (_directOnly) {
        final directs = allRoutes
            .where((r) => r.connects(_origin, town))
            .toList()
          ..sort((a, b) => a.fareFor(_type).compareTo(b.fareFor(_type)));
        if (directs.isEmpty) continue;
        j = Journey([Leg(directs.first, _origin, town)]);
      } else {
        j = run.journeyTo(town);
      }
      if (j == null) continue;
      if (j.fareFor(_type) <= _budget) result.add(j);
    }
    result.sort((a, b) => a.fareFor(_type).compareTo(b.fareFor(_type)));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final list = _reachable();

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Explorer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TownDropdown(
            label: 'Starting from',
            value: _origin,
            icon: Icons.trip_origin,
            onChanged: (v) {
              if (v != null) setState(() => _origin = v);
            },
          ),
          const SizedBox(height: 12),
          Text('My travel budget: ₹${_budget.round()}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _budget,
            min: 20,
            max: 600,
            divisions: 58,
            label: '₹${_budget.round()}',
            onChanged: (v) => setState(() => _budget = v),
          ),
          PassengerChips(
            selected: _type,
            onChanged: (t) => setState(() => _type = t),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Direct buses only (no changes)'),
            value: _directOnly,
            onChanged: (v) => setState(() => _directOnly = v),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              list.isEmpty
                  ? 'No towns reachable from $_origin within ₹${_budget.round()}. Try a bigger budget.'
                  : 'From $_origin, ₹${_budget.round()} can take you to ${list.length} town(s). '
                      'Farthest: ${list.last.destination} (${list.last.distanceKm} km).',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          for (final j in list)
            Card(
              elevation: 1,
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side:
                    const BorderSide(color: AppTheme.primaryLight, width: 1.5),
              ),
              child: ListTile(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.planFor,
                  arguments: JourneyArgs(from: _origin, to: j.destination),
                ),
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  child: Icon(Icons.location_city, color: AppTheme.primary),
                ),
                title: Text(j.destination,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${kTownDistrict[j.destination]} • ${j.distanceKm} km • ${fmtDuration(j.minutes)}'
                  '${j.transfers == 0 ? '' : ' • ${j.transfers} change(s)'}',
                ),
                trailing: Text(
                  '₹${j.fareFor(_type)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// 8g. SAVED ROUTES SCREEN
// ============================================================

class SavedRoutesScreen extends StatelessWidget {
  const SavedRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Routes')),
      body: ListenableBuilder(
        listenable: FavoritesStore.instance,
        builder: (context, _) {
          final routes = FavoritesStore.instance.routes;

          if (routes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmark_border,
                        size: 72, color: AppTheme.primary),
                    const SizedBox(height: 12),
                    const Text('No saved routes yet',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap the bookmark icon on any route to keep it here for quick access.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.search),
                      icon: const Icon(Icons.search),
                      label: const Text('Browse routes'),
                    ),
                  ],
                ),
              ),
            );
          }

          final totalStudent = routes.fold<int>(
              0, (s, r) => s + r.fareFor(PassengerType.student));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${routes.length} saved route(s). Riding each once as a student would cost ₹$totalStudent.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              for (final r in routes)
                RouteCard(route: r, onTap: () => openDetails(context, r)),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// 8h. TOWN HUB SCREEN (dynamic route with a String argument)
// ============================================================

class TownScreen extends StatelessWidget {
  final String town;
  const TownScreen({super.key, required this.town});

  @override
  Widget build(BuildContext context) {
    final routes = allRoutes
        .where((r) => r.source == town || r.destination == town)
        .toList()
      ..sort((a, b) => a.baseFare.compareTo(b.baseFare));
    final neighbours = routes.map((r) => r.other(town)).toSet();

    return Scaffold(
      appBar: AppBar(title: Text(town)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_city, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(town,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                Text('${kTownDistrict[town]} district',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Text(
                  '${routes.length} direct routes to ${neighbours.length} town(s)',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.planFor,
              arguments: JourneyArgs(from: town),
            ),
            icon: const Icon(Icons.alt_route),
            label: Text('Plan a journey from $town'),
          ),
          const SectionTitle('Buses from here', subtitle: 'Cheapest first'),
          for (final r in routes)
            RouteCard(
              route: r,
              fromTown: town,
              onTap: () => openDetails(context, r),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// 8i. SDG 1 SCREEN
// ============================================================

class SdgScreen extends StatelessWidget {
  const SdgScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final under50 = allRoutes.where((r) => r.baseFare <= 50).length;
    final avgSaving = allRoutes
            .map((r) => r.co2SavedKg / r.carCo2Kg * 100)
            .reduce((a, b) => a + b) /
        allRoutes.length;

    return Scaffold(
      appBar: AppBar(title: const Text('SDG 11: Sustainable Cities')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Text('11',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.bold)),
                Text(
                  'Sustainable Cities and Communities',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Make cities and human settlements inclusive, safe, resilient and sustainable',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatBox(value: '${townNames.length}', label: 'Towns linked'),
              const SizedBox(width: 10),
              _StatBox(value: '$under50', label: 'Routes \u2264 \u20B950'),
              const SizedBox(width: 10),
              _StatBox(
                  value: '${avgSaving.round()}%',
                  label: 'Less CO\u2082 than car'),
            ],
          ),
          const SizedBox(height: 16),
          const _InfoBlock(
            icon: Icons.location_city,
            title: 'Why public transport matters',
            text:
                'Growing towns need ways to move many people with less traffic, '
                'less air pollution and less cost. A full bus replaces many '
                'private vehicles, which makes a community cleaner, safer and '
                'easier to live in.',
          ),
          const _InfoBlock(
            icon: Icons.groups_outlined,
            title: 'Who this app helps',
            text: 'Students, daily workers, older people, women, persons with '
                'disabilities and rural residents who depend on buses to reach '
                'education, jobs, markets and health care.',
          ),
          const SectionTitle('How this app helps'),
          const _InfoBlock(
            icon: Icons.alt_route,
            title: 'Connects towns and villages',
            text: 'The Journey Planner joins routes with bus changes, so even '
                'small towns are linked to bigger cities. Town Hubs show every '
                'bus leaving a place.',
          ),
          const _InfoBlock(
            icon: Icons.eco_outlined,
            title: 'Shows the green choice',
            text: 'Every route and journey shows sample CO\u2082 per passenger '
                'compared with a car. The Eco Impact screen turns this into '
                'yearly savings.',
          ),
          const _InfoBlock(
            icon: Icons.accessible,
            title: 'Inclusive and affordable',
            text: 'Concessions for students, seniors and persons with '
                'disabilities, reserved-seat information, and a budget '
                'explorer keep public transport within everyone\u2019s reach.',
          ),
          const SectionTitle('Linked SDG 11 targets',
              subtitle: 'From the UN 2030 Agenda (paraphrased)'),
          const _InfoBlock(
            icon: Icons.flag_outlined,
            title: 'Target 11.2',
            text:
                'By 2030, give everyone access to safe, affordable, accessible '
                'and sustainable transport systems, mainly by expanding public '
                'transport, with special attention to women, children, persons '
                'with disabilities and older people.',
          ),
          const _InfoBlock(
            icon: Icons.flag_outlined,
            title: 'Target 11.6',
            text:
                'Reduce the harmful environmental impact of cities per person, '
                'including by improving air quality.',
          ),
          const _InfoBlock(
            icon: Icons.flag_outlined,
            title: 'Target 11.a',
            text: 'Support positive links between urban, peri-urban and rural '
                'areas through better regional planning.',
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.eco),
            icon: const Icon(Icons.eco),
            label: const Text('See your eco impact'),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.primaryLight,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.dark)),
                  const SizedBox(height: 4),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 8j. ABOUT SCREEN
// ============================================================

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.directions_bus_filled,
              size: 72, color: AppTheme.primary),
          const SizedBox(height: 12),
          const Text(
            'GreenCity Transit',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Version 3.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          const Text(
            'A public transport information app that helps students, '
            'low-income workers and rural residents find affordable bus '
            'routes, compare sample fares and see their carbon savings. It supports UN Sustainable '
            'Development Goal 11: Sustainable Cities and Communities.',
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          const SectionTitle('Features'),
          const _FeatureLine(
              'Journey Planner with bus changes (Dijkstra algorithm)'),
          const _FeatureLine('Cheapest, fastest and fewest-changes options'),
          const _FeatureLine(
              'Eco Impact: CO\u2082, money and tree-equivalent savings'),
          const _FeatureLine(
              'Inclusive Travel: seats, safety tips and concessions'),
          const _FeatureLine(
              'Budget Explorer: towns reachable within your budget'),
          const _FeatureLine('Commute budget check and monthly pass savings'),
          const _FeatureLine('Next-bus countdown and stop-by-stop fares'),
          const _FeatureLine(
              'Town hubs linking villages to cities, saved routes'),
          const SectionTitle('Sample data'),
          Text(
            '${townNames.length} Andhra Pradesh towns and ${allRoutes.length} direct bus routes. '
            'Every route runs both ways, and the planner combines them to connect any two towns.',
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.amber.shade50,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Disclaimer: All routes, timings, fares, discounts and passes in this '
                'app are fictional sample data created for a college project. '
                'Do not use them for real travel planning.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.code, color: AppTheme.primary),
            title: Text('Built with'),
            subtitle: Text('Flutter and Dart'),
          ),
          const ListTile(
            leading: Icon(Icons.person_outline, color: AppTheme.primary),
            title: Text('Developer'),
            subtitle: Text('Your Name, Your College'), // <- change this
          ),
        ],
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  final String text;
  const _FeatureLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

// ============================================================
// 8j-2. ECO STRIP (used on Route Details)
// ============================================================

class _EcoStrip extends StatelessWidget {
  final BusRoute route;
  const _EcoStrip({required this.route});

  @override
  Widget build(BuildContext context) {
    final pct = (route.co2SavedKg / route.carCo2Kg * 100).round();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.eco, color: AppTheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Eco impact: about ${route.co2Kg.toStringAsFixed(1)} kg CO\u2082 per passenger. '
                  'The same trip by car emits about ${route.carCo2Kg.toStringAsFixed(1)} kg, '
                  'so the bus saves ${route.co2SavedKg.toStringAsFixed(1)} kg ($pct% less).',
                  style: const TextStyle(color: AppTheme.dark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.accessible, color: AppTheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(route.info.access)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 8j-3. ECO IMPACT SCREEN (SDG 11: cleaner cities)
// ============================================================

class EcoImpactScreen extends StatefulWidget {
  final BusRoute? initialRoute;
  const EcoImpactScreen({super.key, this.initialRoute});

  @override
  State<EcoImpactScreen> createState() => _EcoImpactScreenState();
}

class _EcoImpactScreenState extends State<EcoImpactScreen> {
  late BusRoute _route;
  EcoMode _mode = kPrivateModes.first;
  PassengerType _type = PassengerType.general;
  double _days = 22;

  @override
  void initState() {
    super.initState();
    _route = widget.initialRoute ?? allRoutes.first;
  }

  @override
  Widget build(BuildContext context) {
    final trips = 2 * _days.round(); // going and returning every travel day
    final busCo2 = _route.co2Kg * trips;
    final modeCo2 = _route.distanceKm * _mode.gramsPerKm / 1000 * trips;
    final savedMonth = modeCo2 - busCo2;
    final savedYear = savedMonth * 12;
    final trees = savedYear / kKgCo2PerTreePerYear;
    final busCost = _route.fareFor(_type) * trips;
    final modeCost = (_route.distanceKm * _mode.costPerKm * trips).round();
    final moneySaved = modeCost - busCost;
    final maxCo2 = modeCo2 > busCo2 ? modeCo2 : busCo2;
    final maxCost = modeCost > busCost ? modeCost : busCost;

    return Scaffold(
      appBar: AppBar(title: const Text('Eco Impact')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Choose your regular route',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BusRoute>(
                value: _route,
                isExpanded: true,
                items: [
                  for (final r in allRoutes)
                    DropdownMenuItem(
                      value: r,
                      child: Text('${r.title} (${r.busType})',
                          overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _route = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('How do you travel now?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final m in kPrivateModes)
                ChoiceChip(
                  avatar: Icon(m.icon, size: 18),
                  label: Text(m.name),
                  selected: _mode == m,
                  onSelected: (_) => setState(() => _mode = m),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Your passenger type (for bus fare)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          PassengerChips(
            selected: _type,
            onChanged: (t) => setState(() => _type = t),
          ),
          const SizedBox(height: 10),
          Text('Travel days per month: ${_days.round()}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _days,
            min: 1,
            max: 30,
            divisions: 29,
            label: '${_days.round()} days',
            onChanged: (v) => setState(() => _days = v),
          ),
          const SizedBox(height: 6),

          // Result
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Icon(Icons.park, color: Colors.white, size: 36),
                const SizedBox(height: 6),
                Text(
                  'Taking this bus instead of a ${_mode.name.toLowerCase()} saves',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  '${savedYear.toStringAsFixed(0)} kg CO\u2082 a year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'about ${trees.toStringAsFixed(1)} trees\u2019 yearly absorption (approx.)',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SectionTitle('Monthly CO\u2082 emissions',
              subtitle: 'Lower is better'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _CompareBar(
                  label: 'Bus',
                  value: busCo2,
                  max: maxCo2,
                  text: '${busCo2.toStringAsFixed(1)} kg',
                  color: AppTheme.primary,
                ),
                _CompareBar(
                  label: _mode.name,
                  value: modeCo2,
                  max: maxCo2,
                  text: '${modeCo2.toStringAsFixed(1)} kg',
                  color: Colors.orange.shade700,
                ),
              ],
            ),
          ),
          const SectionTitle('Monthly travel cost',
              subtitle: 'Sample bus fares vs sample running cost'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _CompareBar(
                  label: 'Bus',
                  value: busCost.toDouble(),
                  max: maxCost.toDouble(),
                  text: '\u20B9$busCost',
                  color: AppTheme.primary,
                ),
                _CompareBar(
                  label: _mode.name,
                  value: modeCost.toDouble(),
                  max: maxCost.toDouble(),
                  text: '\u20B9$modeCost',
                  color: Colors.orange.shade700,
                ),
                const SizedBox(height: 6),
                Text(
                  moneySaved >= 0
                      ? 'You also save \u20B9$moneySaved every month.'
                      : 'The bus costs \u20B9${-moneySaved} more a month, but cuts emissions.',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppTheme.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'CO\u2082 and running-cost values are illustrative samples for learning, not official statistics. '
            'A tree absorbs roughly ${kKgCo2PerTreePerYear.round()} kg of CO\u2082 per year (approximate).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _CompareBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final String text;
  final Color color;

  const _CompareBar({
    required this.label,
    required this.value,
    required this.max,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(label, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 14,
              color: color,
              backgroundColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(text,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 8j-4. INCLUSIVE TRAVEL SCREEN (SDG 11.2: safe, accessible for all)
// ============================================================

class InclusiveTravelScreen extends StatelessWidget {
  const InclusiveTravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tips = [
      'Board at well-lit, busy stops and check the route number before you get on.',
      'Reserved seats are for women, senior citizens, persons with disabilities and people with young children.',
      'Share your bus route and expected arrival time with someone you trust.',
      'Keep your phone charged and your valuables close, especially at crowded stops.',
      'Ask the conductor or driver for help if you need a ramp, a seat or directions.',
      'In an emergency, dial 112, the national emergency number in India.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Inclusive Travel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.groups, color: Colors.white, size: 34),
                SizedBox(height: 8),
                Text('Transport for everyone',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  'SDG 11.2 asks for safe, affordable and accessible transport, with special attention to women, children, older people and persons with disabilities.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SectionTitle('Sample concessions',
              subtitle: 'Discount on the normal fare'),
          Card(
            color: AppTheme.primaryLight,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: Column(
              children: [
                for (final t in PassengerType.values)
                  if (t.discount > 0)
                    ListTile(
                      dense: true,
                      leading:
                          const Icon(Icons.discount, color: AppTheme.primary),
                      title: Text(t.label),
                      trailing: Text(
                        '${(t.discount * 100).round()}% off',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary),
                      ),
                    ),
              ],
            ),
          ),
          const SectionTitle('What each bus type offers',
              subtitle: 'Sample accessibility information'),
          for (final entry in kBusTypes.entries)
            Card(
              elevation: 0,
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side:
                    const BorderSide(color: AppTheme.primaryLight, width: 1.5),
              ),
              child: ListTile(
                leading: BusTypeBadge(entry.key),
                title: Text(entry.value.access,
                    style: const TextStyle(fontSize: 14)),
              ),
            ),
          const SectionTitle('Travelling safely'),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle,
                      size: 18, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tip)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
            icon: const Icon(Icons.alt_route),
            label: const Text('Plan an accessible journey'),
          ),
          const SizedBox(height: 8),
          Text(
            'Sample information for learning only. Real services may differ.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 8k. UNKNOWN ROUTE SCREEN
// ============================================================

class UnknownRouteScreen extends StatelessWidget {
  final String? routeName;
  final String? message;

  const UnknownRouteScreen({super.key, this.routeName, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wrong_location,
                  size: 80, color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text('Oops! This page does not exist.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                message ??
                    'No screen is registered for "${routeName ?? 'unknown'}".',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                ),
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
