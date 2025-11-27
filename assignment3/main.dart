import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() => runApp(const WeatherApp());

// Opacity helper to avoid deprecated withOpacity uses
extension ColorOpacityHelper on Color {
  Color withOpacityF(double opacity) =>
      withAlpha((opacity * 255).clamp(0, 255).toInt());
}

/// Branding logo: gradient sun + cloud overlay — uses Theme's primary color
class LogoWidget extends StatelessWidget {
  final double size;
  const LogoWidget({super.key, this.size = 160});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sun orb
          Container(
            width: size * 0.66,
            height: size * 0.66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [primary.withOpacityF(0.98), primary.withOpacityF(0.5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacityF(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          // Cloud overlay
          Positioned(
            right: size * -0.02,
            bottom: size * 0.1,
            child: Container(
              width: size * 0.9,
              height: size * 0.5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          // Letters
          Positioned(
            bottom: size * 0.08,
            child: Text(
              'WA',
              style: TextStyle(
                color: primary,
                fontSize: size * 0.22,
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Color scheme: light blackish theme (primary) with cool cyan accent
    const seed = Color(0xFF2B2B2B);
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          primary: seed,
          secondary: const Color(0xFF29B6F6),
        ),
        scaffoldBackgroundColor: const Color(0xFF101010),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF2B2B2B),
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

/// Splash Screen: scale + rotation + fade of the LogoWidget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _rotation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scale = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8),
    );
    _rotation = Tween<double>(
      begin: -0.04,
      end: 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(const Duration(milliseconds: 250));
        if (mounted)
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WeatherHomePage()),
            );
          }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: RotationTransition(
            turns: _rotation,
            child: ScaleTransition(
              scale: _scale,
              child: Hero(tag: 'appLogo', child: const LogoWidget(size: 200)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Weather Home Page: full UI with forecasts, network + location, animations
class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});
  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with TickerProviderStateMixin {
  String _city = 'Loading...';
  double _temperature = 0;
  String _condition = '—';
  bool _isLoading = true;
  String _errorMessage = '';
  final String _apiKey = '163aeb998f7970d3e6dca0bfe7eac971';
  final TextEditingController _cityController = TextEditingController();
  final List<Map<String, dynamic>> _forecastData = [
    {'day': 'Mon', 'high': 75, 'low': 65, 'condition': '☀️'},
    {'day': 'Tue', 'high': 73, 'low': 63, 'condition': '⛅'},
    {'day': 'Wed', 'high': 68, 'low': 58, 'condition': '🌧️'},
    {'day': 'Thu', 'high': 70, 'low': 60, 'condition': '⛅'},
    {'day': 'Fri', 'high': 76, 'low': 66, 'condition': '☀️'},
  ];

  late final AnimationController _homeController;
  late final Animation<double> _homeScale;
  late final AnimationController _fabController;
  late final Animation<double> _fabPulse;
  @override
  void initState() {
    super.initState();
    _homeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _homeScale = CurvedAnimation(
      parent: _homeController,
      curve: Curves.easeOutBack,
    );
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fabPulse = Tween<double>(
      begin: 1.0,
      end: 1.075,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeInOut));
    _fabController.repeat(reverse: true);
    _fetchWeatherByLocation();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _homeController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    setState(() => _isLoading = true);
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _city = data['name'] ?? _city;
          _temperature = (data['main']['temp'] as num?)?.toDouble() ?? 0;
          _condition = data['weather'][0]['main'] ?? _condition;
          _isLoading = false;
          _errorMessage = '';
        });
        _homeController.forward(from: 0);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _fetchWeatherByCity(String cityName) async {
    if (cityName.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _city = data['name'] ?? cityName;
          _temperature = (data['main']['temp'] as num?)?.toDouble() ?? 0;
          _condition = data['weather'][0]['main'] ?? _condition;
          _isLoading = false;
          _errorMessage = '';
        });
        _homeController.forward(from: 0);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'City not found.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _fetchWeatherByLocation() async {
    setState(() => _isLoading = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location services disabled';
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      await _fetchWeatherData(pos.latitude, pos.longitude);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search City'),
        content: TextField(
          controller: _cityController,
          decoration: const InputDecoration(hintText: 'Enter city'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final city = _cityController.text.trim();
              _fetchWeatherByCity(city);
              _cityController.clear();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Weather App')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Weather App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _fetchWeatherByLocation,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaleTransition(
                scale: _homeScale,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacityF(0.95),
                        theme.colorScheme.primary.withOpacityF(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacityF(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Hero(tag: 'appLogo', child: LogoWidget(size: 48)),
                              const SizedBox(width: 12),
                              Text(
                                _city,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onPrimary.withOpacityF(
                                0.12,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _condition,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_temperature.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          fontSize: 44,
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.opacity,
                            color: theme.colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Humidity: —',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('5-Day Forecast', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _forecastData.length,
                  itemBuilder: (context, index) {
                    final f = _forecastData[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.85, end: 1.0),
                      duration: Duration(milliseconds: 400 + index * 80),
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacityF(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.secondary.withOpacityF(
                              0.25,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              f['day'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              f['condition'],
                              style: const TextStyle(fontSize: 28),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${f['high']}°',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${f['low']}°',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailCard('Wind', '—', Icons.air),
                  _buildDetailCard('Feels like', '—', Icons.thermostat),
                  _buildDetailCard('AQI', '—', Icons.blur_on),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabPulse,
        child: FloatingActionButton(
          backgroundColor: theme.colorScheme.secondary,
          onPressed: _fetchWeatherByLocation,
          child: Icon(Icons.refresh, color: theme.colorScheme.onSecondary),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacityF(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacityF(0.24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
