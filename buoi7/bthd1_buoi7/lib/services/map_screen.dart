import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/favorite_route.dart';
import '../screens/api_service.dart';
import '../screens/map_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _startController = TextEditingController(text: "227 Nguyễn Văn Cừ, TP.HCM");
  final TextEditingController _endController = TextEditingController(text: "Chợ Bến Thành, TP.HCM");
  final MapController _mapController = MapController();

  String _selectedMode = 'driving'; // driving, walking, bike
  
  LatLng? _startCoord;
  LatLng? _endCoord;
  List<LatLng> _routePoints = [];
  
  List<FavoriteRoute> _favorites = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavoritesFromSqlServer();
  }

  // 1. Tải danh sách yêu thích từ SQL Server
  Future<void> _loadFavoritesFromSqlServer() async {
    final list = await ApiService.getFavoriteRoutes();
    setState(() {
      _favorites = list;
    });
  }

  // 2. Chức năng Tìm đường (Geocoding + Directions API + Vẽ đường)
  Future<void> _findRoute() async {
    setState(() => _isLoading = true);

    // Chuyển Địa chỉ -> Tọa độ
    final start = await MapService.geocodeAddress(_startController.text);
    final end = await MapService.geocodeAddress(_endController.text);

    if (start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy tọa độ cho địa chỉ đã nhập!')),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Lấy danh sách điểm tuyến đường tối ưu
    final points = await MapService.getRoutePoints(
      start: start,
      end: end,
      mode: _selectedMode,
    );

    setState(() {
      _startCoord = start;
      _endCoord = end;
      _routePoints = points;
      _isLoading = false;
    });

    // Zoom bản đồ đến điểm bắt đầu
    if (_routePoints.isNotEmpty) {
      _mapController.move(_startCoord!, 13.0);
    }
  }

  // 3. Chức năng Lưu vào SQL Server
  Future<void> _saveToFavorites() async {
    if (_startCoord == null || _endCoord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng bấm "Tìm đường" trước khi lưu!')),
      );
      return;
    }

    final newRoute = FavoriteRoute(
      title: "${_startController.text} ➔ ${_endController.text}",
      startLocation: _startController.text,
      endLocation: _endController.text,
      startLat: _startCoord!.latitude,
      startLng: _startCoord!.longitude,
      endLat: _endCoord!.latitude,
      endLng: _endCoord!.longitude,
      travelMode: _selectedMode,
    );

    bool success = await ApiService.addFavoriteRoute(newRoute);
    if (success) {
      _loadFavoritesFromSqlServer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thành công vào SQL Server!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu vào SQL Server thất bại!')),
      );
    }
  }

  // 4. Chọn tuyến đường từ danh sách yêu thích để hiển thị lại
  void _selectFavorite(FavoriteRoute route) async {
    _startController.text = route.startLocation;
    _endController.text = route.endLocation;
    
    setState(() {
      _selectedMode = route.travelMode;
      _startCoord = LatLng(route.startLat, route.startLng);
      _endCoord = LatLng(route.endLat, route.endLng);
      _isLoading = true;
    });

    final points = await MapService.getRoutePoints(
      start: _startCoord!,
      end: _endCoord!,
      mode: _selectedMode,
    );

    setState(() {
      _routePoints = points;
      _isLoading = false;
    });

    _mapController.move(_startCoord!, 13.0);
    Navigator.pop(context); // Đóng BottomSheet
  }

  // Hiển thị danh sách Yêu thích dạng BottomSheet
  void _showFavoritesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('⭐ Tuyến đường Yêu thích (SQL Server)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadFavoritesFromSqlServer,
                  )
                ],
              ),
              const Divider(),
              Expanded(
                child: _favorites.isEmpty
                    ? const Center(child: Text('Chưa có dữ liệu trong SQL Server'))
                    : ListView.builder(
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          final item = _favorites[index];
                          return ListTile(
                            leading: Icon(
                              item.travelMode == 'walking'
                                  ? Icons.directions_walk
                                  : (item.travelMode == 'bike' ? Icons.two_wheeler : Icons.directions_car),
                              color: Colors.blue,
                            ),
                            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text("${item.startLocation} ➔ ${item.endLocation}"),
                            onTap: () => _selectFavorite(item),
                          );
                        },
                      ),
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
        title: const Text('Ứng dụng Tìm Đường - SQL Server'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_rate),
            onPressed: _showFavoritesBottomSheet,
          )
        ],
      ),
      body: Column(
        children: [
          // BẢNG ĐIỀU KHIỂN BÊN TRÊN
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Ô nhập Địa chỉ đi
                TextField(
                  controller: _startController,
                  decoration: const InputDecoration(
                    labelText: 'Điểm bắt đầu (Nhập địa chỉ)',
                    prefixIcon: Icon(Icons.my_location, color: Colors.green),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),

                // Ô nhập Địa chỉ đến
                TextField(
                  controller: _endController,
                  decoration: const InputDecoration(
                    labelText: 'Điểm đến (Nhập địa chỉ)',
                    prefixIcon: Icon(Icons.location_on, color: Colors.red),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    // CHỌN PHƯƠNG TIỆN (Ô tô, Xe máy, Đi bộ)
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMode,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'driving', child: Text('🚗 Xe hơi')),
                          DropdownMenuItem(value: 'bike', child: Text('🛵 Xe máy')),
                          DropdownMenuItem(value: 'walking', child: Text('🚶 Đi bộ')),
                        ],
                        onChanged: (val) => setState(() => _selectedMode = val!),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // NÚT TÌM ĐƯỜNG
                    ElevatedButton(
                      onPressed: _isLoading ? null : _findRoute,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16)),
                      child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Tìm đường'),
                    ),
                    const SizedBox(width: 8),

                    // NÚT LƯU YÊU THÍCH
                    IconButton(
                      icon: const Icon(Icons.bookmark_add, color: Colors.amber, size: 32),
                      onPressed: _saveToFavorites,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // KHU VỰC HIỂN THỊ BẢN ĐỒ VÀ VẼ ĐƯỜNG ĐI
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(10.762622, 106.682029), // Tọa độ TP.HCM
                initialZoom: 13.0,
              ),
              children: [
                // Lớp bản đồ Tile OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mapapp',
                ),

                // Lớp vẽ đường Polyline
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.0,
                      color: Colors.blue,
                    ),
                  ],
                ),

                // Lớp hiển thị Marker điểm đi & điểm đến
                MarkerLayer(
                  markers: [
                    if (_startCoord != null)
                      Marker(
                        point: _startCoord!,
                        child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                      ),
                    if (_endCoord != null)
                      Marker(
                        point: _endCoord!,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}