import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapService {
  // 1. Geocoding API (Địa chỉ -> LatLng)
  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json',
      );
      final response = await http.get(url, headers: {'User-Agent': 'FlutterMapApp/1.0'});

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat']);
          double lng = double.parse(data[0]['lon']);
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      print('Lỗi Geocoding: $e');
    }
    return null;
  }

  // 2. Directions API (Tìm tuyến đường tối ưu vẽ Polyline)
  static Future<List<LatLng>> getRoutePoints({
    required LatLng start,
    required LatLng end,
    required String mode, // driving, walking, bike
  }) async {
    List<LatLng> polylinePoints = [];
    try {
      String profile = mode == 'walking' ? 'foot' : (mode == 'bike' ? 'bike' : 'car');
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];

        for (var point in coordinates) {
          polylinePoints.add(LatLng(point[1].toDouble(), point[0].toDouble()));
        }
      }
    } catch (e) {
      print('Lỗi Directions API: $e');
    }
    return polylinePoints;
  }
}