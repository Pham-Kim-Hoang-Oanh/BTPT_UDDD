import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/favorite_route.dart';

class ApiService {
  // 10.0.2.2 là localhost khi chạy trên Android Emulator. 
  // Nếu chạy máy thật/Web, hãy đổi thành IP máy tính (Ví dụ: http://192.168.1.10:5000/api)
  static const String baseUrl = 'http://10.0.2.2:5000/api/routes';

  // 1. Lấy danh sách tuyến đường yêu thích từ SQL Server
  static Future<List<FavoriteRoute>> getFavoriteRoutes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => FavoriteRoute.fromJson(json)).toList();
      }
    } catch (e) {
      print('Lỗi đọc từ SQL Server: $e');
    }
    return [];
  }

  // 2. Thêm tuyến đường yêu thích vào SQL Server
  static Future<bool> addFavoriteRoute(FavoriteRoute route) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(route.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Lỗi lưu vào SQL Server: $e');
      return false;
    }
  }
}