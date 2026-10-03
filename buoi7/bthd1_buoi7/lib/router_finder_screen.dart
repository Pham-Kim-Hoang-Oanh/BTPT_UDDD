import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RouteFinderScreen extends StatefulWidget {
  @override
  _RouteFinderScreenState createState() => _RouteFinderScreenState();
}

class _RouteFinderScreenState extends State<RouteFinderScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();
  LatLng? _startLatLng;
  LatLng? _endLatLng;

  // Thông tin khoảng cách & thời gian di chuyển
  String _distance = '';
  String _duration = '';

  

  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.7769, 106.7009), // TP.HCM mặc định
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(setAsStart: true);
  }

  // Lấy vị trí hiện tại (Có thể set làm điểm xuất phát hoặc điểm đích)
  Future<void> _getCurrentLocation({required bool setAsStart}) async {
    WidgetsFlutterBinding.ensureInitialized();
  
  // Nạp biến môi trường từ file .env
  await dotenv.load(fileName: ".env");
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      if (setAsStart) {
        _startLatLng = currentLatLng;
        _startController.text = "${position.latitude}, ${position.longitude}";
        _addMarker(_startLatLng!, "Xuất phát", BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
      } else {
        _endLatLng = currentLatLng;
        _endController.text = "${position.latitude}, ${position.longitude}";
        _addMarker(_endLatLng!, "Đích đến", BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));
      }
      _moveCamera(currentLatLng);
    });
  }

  // Thêm marker có tùy chỉnh màu sắc
  void _addMarker(LatLng position, String markerId, [BitmapDescriptor? icon]) {
    _markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: markerId),
        icon: icon ?? BitmapDescriptor.defaultMarker,
      ),
    );
  }

  // Di chuyển camera
  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  // Chọn điểm bằng cách click trên bản đồ
  void _onMapTapped(LatLng latLng) {
    setState(() {
      if (_startLatLng == null || (_startLatLng != null && _endLatLng != null)) {
        // Đặt làm điểm xuất phát
        _startLatLng = latLng;
        _endLatLng = null;
        _startController.text = "${latLng.latitude}, ${latLng.longitude}";
        _endController.clear();
        _markers.clear();
        _polylines.clear();
        _distance = '';
        _duration = '';
        _addMarker(_startLatLng!, "Xuất phát", BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
      } else {
        // Đặt làm điểm đích
        _endLatLng = latLng;
        _endController.text = "${latLng.latitude}, ${latLng.longitude}";
        _addMarker(_endLatLng!, "Đích đến", BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));
      }
    });
  }

  // Tìm đường đi
  Future<void> _findRoute() async {
    if (_startController.text.trim().isEmpty || _endController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Vui lòng nhập cả hai điểm!')));
      return;
    }

    try {
      List<String> start = _startController.text.split(',');
      List<String> end = _endController.text.split(',');

      _startLatLng = LatLng(double.parse(start[0].trim()), double.parse(start[1].trim()));
      _endLatLng = LatLng(double.parse(end[0].trim()), double.parse(end[1].trim()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Định dạng tọa độ không hợp lệ! Vui lòng nhập: lat,lng')),
      );
      return;
    }

    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_startLatLng!.latitude},${_startLatLng!.longitude}&destination=${_endLatLng!.latitude},${_endLatLng!.longitude}&key=$_apiKey&language=vi";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
        var route = data['routes'][0];
        String polylinePoints = route['overview_polyline']['points'];
        List<LatLng> points = _decodePolyline(polylinePoints);

        // Lấy khoảng cách và thời gian di chuyển
        var leg = route['legs'][0];
        String dist = leg['distance']['text'];
        String dur = leg['duration']['text'];

        setState(() {
          _distance = dist;
          _duration = dur;

          _markers.clear();
          _addMarker(_startLatLng!, "Xuất phát", BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
          _addMarker(_endLatLng!, "Đích đến", BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));

          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: points,
              color: Colors.blue,
              width: 5,
            ),
          );
          _moveCamera(_startLatLng!);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy tuyến đường nào!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gọi API: ${response.statusCode}')),
      );
    }
  }

  // Tìm kiếm địa điểm xung quanh (Places Nearby Search)
  Future<void> _searchNearbyPlaces(String type) async {
    LatLng center = _startLatLng ?? LatLng(10.7769, 106.7009);

    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${center.latitude},${center.longitude}&radius=2000&type=$type&key=$_apiKey&language=vi";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['status'] == 'OK' && data['results'] != null) {
        List results = data['results'];

        setState(() {
          _markers.clear();
          // Giữ lại marker điểm xuất phát nếu có
          if (_startLatLng != null) {
            _addMarker(_startLatLng!, "Xuất phát", BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
          }

          for (var place in results) {
            var lat = place['geometry']['location']['lat'];
            var lng = place['geometry']['location']['lng'];
            String name = place['name'] ?? 'Địa điểm';

            _markers.add(
              Marker(
                markerId: MarkerId(place['place_id']),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(title: name, snippet: place['vicinity']),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                onTap: () {
                  // Khi bấm vào Marker địa điểm, tự động chọn làm điểm đích
                  setState(() {
                    _endLatLng = LatLng(lat, lng);
                    _endController.text = "$lat, $lng";
                  });
                },
              ),
            );
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tìm thấy ${results.length} kết quả')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy địa điểm phù hợp xung quanh!')),
        );
      }
    }
  }

  // Giải mã polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Route Finder')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Điểm xuất phát
                TextField(
                  controller: _startController,
                  decoration: InputDecoration(
                    labelText: 'Điểm xuất phát (lat, lng)',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: () => _getCurrentLocation(setAsStart: true),
                      tooltip: 'Lấy vị trí hiện tại làm điểm xuất phát',
                    ),
                  ),
                ),
                // Điểm đích + Nút lấy vị trí hiện tại
                TextField(
                  controller: _endController,
                  decoration: InputDecoration(
                    labelText: 'Điểm đích (lat, lng)',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.location_searching),
                      onPressed: () => _getCurrentLocation(setAsStart: false),
                      tooltip: 'Lấy vị trí hiện tại làm điểm đích',
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _findRoute,
                  child: Text('Tìm đường đi'),
                ),

                // Hiển thị khoảng cách và thời gian
                if (_distance.isNotEmpty && _duration.isNotEmpty)
                  Card(
                    color: Colors.blue.shade50,
                    margin: EdgeInsets.only(top: 8.0),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Khoảng cách: $_distance', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Thời gian: $_duration', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 8),
                // Các nút tìm kiếm địa điểm nhanh
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        avatar: Icon(Icons.hotel, size: 18),
                        label: Text('Khách sạn'),
                        onPressed: () => _searchNearbyPlaces('lodging'),
                      ),
                      SizedBox(width: 5),
                      ActionChip(
                        avatar: Icon(Icons.restaurant, size: 18),
                        label: Text('Quán ăn'),
                        onPressed: () => _searchNearbyPlaces('restaurant'),
                      ),
                      SizedBox(width: 5),
                      ActionChip(
                        avatar: Icon(Icons.local_hospital, size: 18),
                        label: Text('Bệnh viện'),
                        onPressed: () => _searchNearbyPlaces('hospital'),
                      ),
                      SizedBox(width: 5),
                      ActionChip(
                        avatar: Icon(Icons.school, size: 18),
                        label: Text('Trường học'),
                        onPressed: () => _searchNearbyPlaces('school'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: _onMapTapped, // Bấm trực tiếp trên bản đồ để chọn điểm
              myLocationEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}