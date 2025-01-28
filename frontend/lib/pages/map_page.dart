// Import necessary Dart and Flutter packages
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/components/theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../components/info_panel.dart';
import 'package:http/http.dart' as http;

import '../components/point.dart';
import '../components/incidents_options.dart';
import '../components/navBar.dart';
import '../pages/constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> _markers = {};
  Position? _location;
  Timer? _timer;
  final Completer<GoogleMapController> _mapController = Completer();
  late Set<Circle> _circles = {};
  StreamSubscription<Position>? _positionSubscription;
  String? _darkMapStyle;
  String? _lightMapStyle;
  late List<Point> nearbyPoints = [];
  List<Map<String, dynamic>> _trustedUsersLocations = [];

  bool _isInfoPanelVisible = false;
  Point? _selectedPoint;

  void _onMarkerTapped(Point point) {
    setStateIfMounted(() {
      _selectedPoint = point;
      _isInfoPanelVisible = true;
    });
  }

  void _hidePanel() {
    setStateIfMounted(() {
      _isInfoPanelVisible = false;
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }


  Future<Set<Marker>> _createTrustedUserMarkers() async {
    Set<Marker> trustedUserMarkers = {};

    for (var userLocation in _trustedUsersLocations) {
      double latitude = double.parse(userLocation['latitude']);
      double longitude = double.parse(userLocation['longitude']);
      String username = userLocation['username'];

      BitmapDescriptor icon;
      try {
        icon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(100, 100)),
          "assets/images/icons8-friend-64.png",
        );
      } catch (e) {
        print("Error loading image: $e");
        // You can set a default icon or handle the error as needed
        icon = BitmapDescriptor.defaultMarker;
      }


      Marker marker = Marker(
        markerId: MarkerId('$username'),
        position: LatLng(latitude, longitude),
        icon: icon,
        infoWindow: InfoWindow(
            title: '$username'), // Adăugați un titlu dacă este necesar
      );

      trustedUserMarkers.add(marker);
    }
    return trustedUserMarkers;
  }

  Future<void> _fetchMarkers() async {
    try {
      List<Point> points = await _getMarkersFromBackend();
      //print(points.length);
      List<Future<BitmapDescriptor>> futures = points.map((point) {
        String assetPath = point.category == 'Medium'
            ? "assets/images/_yellow.png"
            : "assets/images/_red.png";
        return BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(100, 100)), assetPath);
      }).toList();
      List<BitmapDescriptor> icons = await Future.wait(futures);
      Set<Marker> newMarkers =
          Set<Marker>.from(points.asMap().entries.map((entry) {
        int index = entry.key;
        Point point = entry.value;
        final timeDifference = DateTime.now().difference(point.timestamp);
        final timeAgo = _formatTimeAgo(timeDifference);
        return Marker(
          markerId: MarkerId(point.id.toString()),
          position: LatLng(
              double.parse(point.latitude), double.parse(point.longitude)),
          icon: icons[index],
          onTap: () => _onMarkerTapped(point),
        );
      }));

      Set<Marker> trustedUserMarkers = await _createTrustedUserMarkers();
      newMarkers.addAll(trustedUserMarkers);

      setStateIfMounted(() {
        _markers = newMarkers;
        //print(_markers);
      });
    } catch (e) {
      print('Error fetching markers: $e');
    }
  }

  Future<void> fetchContactsMarkers() async {
    Set<Marker> trustedUserMarkers = await _createTrustedUserMarkers();
    _markers.addAll(trustedUserMarkers);
  }

  String _formatTimeAgo(Duration duration) {
    if (duration.inDays > 0) {
      return 'Placed ${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return 'Placed ${duration.inHours} hours ago';
    } else if (duration.inMinutes > 0) {
      return 'Placed ${duration.inMinutes} minutes ago';
    } else {
      return 'Placed just now';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadMapStyles(); // Load your map styles here
    });
    _fetchMarkers();
    _getCurrentLocation();
    _initLocationStream();
    _startFetchingMarkers();
    _getNearbyPoints();
    _fetchTrustedUsersLocations();
  }

  void _updateCircle([Position? position]) {
    if (!mounted) return;

    LatLng center = position != null
        ? LatLng(position.latitude, position.longitude)
        : LatLng(44.439663, 26.096306); // Default coordinates
    _circles.clear();
    _circles.add(Circle(
      circleId: CircleId("currentLocationRadius"),
      center: center,
      radius: 300,
      fillColor: Color.fromARGB(255, 165, 165, 165).withOpacity(0.4),
      strokeWidth: 1,
      strokeColor: const Color.fromARGB(255, 0, 0, 0),
    ));
    if (!_mapController.isCompleted) {
      _mapController.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLng(center));
      });
    }
  }

  void _handleMapTap(LatLng tappedPoint) {
    double distance = _calculateDistance(_location!.latitude,
        _location!.longitude, tappedPoint.latitude, tappedPoint.longitude);

    if (distance <= 300) {
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => OptionsPage()))
          .then((selectedData) async {
        if (selectedData != null) {
          String category = selectedData['category'];
          String description = selectedData['description'];
          String event = selectedData['event'];
          try {
            addPointToUser(tappedPoint.latitude, tappedPoint.longitude,
                description, category, event);
            _fetchMarkers();
          } catch (e) {
            print("Error: $e");
          }
        }
      });
    } else {
      // Optionally handle taps outside the radius
      print("Tapped location is outside the 300m radius");
    }
  }

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R; R = 6371 km; *1000 for meters
  }

  void _goToCurrentLocation() async {
    _getCurrentLocation();
    final GoogleMapController controller = await _mapController.future;
    if (_location != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_location!.latitude, _location!.longitude),
          zoom: 14,
        ),
      ));
    } else {
      print("Current location is not available.");
    }
  }

  @override
  Widget build(BuildContext context) {
    void toggleTheme(bool isDark) {
      Provider.of<ThemeProvider>(context, listen: false).setTheme(
        isDark ? ThemeData.dark() : ThemeData.light(),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      drawer: NavBar(toggleTheme: toggleTheme, nearbyPoints: nearbyPoints),
      body: Stack(
        children: [
          GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    _location?.latitude ?? 44.439663,
                    _location?.longitude ??
                        26.096306), // Default to a placeholder if _location is null
                zoom: 14,
              ),
              circles: _circles,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              style:
                  Provider.of<ThemeProvider>(context).getTheme().brightness ==
                          Brightness.dark
                      ? _darkMapStyle
                      : _lightMapStyle,
              onTap: (LatLng position) {
                if (_isInfoPanelVisible) {
                  _hidePanel();
                } else {
                  _handleMapTap(position);
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 16.0, right: 16.0),
              child: FloatingActionButton(
                onPressed: _goToCurrentLocation,
                child: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                backgroundColor: Color.fromARGB(255, 125, 136, 136),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: FloatingActionButton(
                onPressed: () {
                  _onMapTapped();
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                elevation: 3,
              ),
            ),
          ),
          if (_isInfoPanelVisible && _selectedPoint != null)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: InfoPanel(
                  point: _selectedPoint!,
                  onClose: _hidePanel,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _startFetchingMarkers() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getCurrentLocation();
      _getNearbyPoints();
      _fetchTrustedUsersLocations();
      _fetchMarkers();
      fetchContactsMarkers();
    });
  }

  void _onMapTapped() async {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => OptionsPage()))
        .then((selectedData) async {
      if (selectedData != null) {
        String category = selectedData['category'];
        String description = selectedData['description'];
        String event = selectedData['event'];
        try {
          _getCurrentLocation();
          addPointToUser(_location!.latitude, _location!.longitude, description,
              category, event);
          _fetchMarkers();
        } catch (e) {
          print("Error: $e");
        }
      }
    });
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _location = position;
      _sendLocationToBackend(position);
      _updateCircle(position);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _sendLocationToBackend(Position position) async {
    final String url =
        '$baseURL/users/update-location/${FirebaseAuth.instance.currentUser?.uid}';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded', // Use form data
        },
        body: {
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString()
        },
      );

      if (response.statusCode != 200) {
        print("Failed to update location on the backend");
      }
    } catch (error) {
      print("Error sending location to backend: $error");
    }
  }

  Future<void> _fetchTrustedUsersLocations() async {

  final String url = '$baseURL/users/get-locations/${FirebaseAuth.instance.currentUser?.uid}';
  try {
    final response = await http.get(Uri.parse(url),
      headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
       _trustedUsersLocations  = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("Failed to fetch trusted users' locations");
    }
  }

  Future<void> addPointToUser(double latitude, double longitude,
      String description, String category, String event) async {
    final response = await http.post(
      Uri.parse('${baseURL}/points/add'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "description": description,
        "category": category,
        "event": event,
        "userId": FirebaseAuth.instance.currentUser!.uid,
      }),
    );
    if (response.statusCode == 200) {
      print('Point added successfully');
    } else {
      print('Failed to add point');
    }
  }

  Future<List<Point>> _getMarkersFromBackend() async {
    final response = await http.get(Uri.parse('${baseURL}/points/all'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((pointJson) => Point.fromJson(pointJson))
          .toList();
    } else {
      throw Exception('Failed to load points');
    }
  }

  Future<List<Point>> _getNearbyPoints() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      List<Point> points = await _getMarkersFromBackend();
      nearbyPoints.clear();
      for (Point p in points) {
        double latitude = double.parse(p.latitude);
        double longitude = double.parse(p.longitude);
        if (_calculateDistance(latitude, longitude, _location?.latitude,
                    _location?.longitude) <=
                1000 &&
            p.userId != userId) {
          nearbyPoints.add(p);
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return nearbyPoints;
  }

  void _initLocationStream() {
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters moved
    ).listen((Position position) {
      setStateIfMounted(() {
        _location = position;
        _updateCircle(position);
      });
    }, onError: (e) {
      print("Error obtaining location: $e");
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel(); // Cancel the position stream
    _timer?.cancel();
    super.dispose();
  }

  void loadMapStyles() async {
    _darkMapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/dark_map_style.json');
    _lightMapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
  }
}
