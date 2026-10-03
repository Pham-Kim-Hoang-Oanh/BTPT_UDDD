class FavoriteRoute {
  final int? id;
  final String title;
  final String startLocation;
  final String endLocation;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final String travelMode;

  FavoriteRoute({
    this.id,
    required this.title,
    required this.startLocation,
    required this.endLocation,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.travelMode,
  });

  // Chuyển JSON từ SQL Server trả về thành Object
  factory FavoriteRoute.fromJson(Map<String, dynamic> json) {
    return FavoriteRoute(
      id: json['Id'] ?? json['id'],
      title: json['Title'] ?? json['title'] ?? '',
      startLocation: json['StartLocation'] ?? json['startLocation'] ?? '',
      endLocation: json['EndLocation'] ?? json['endLocation'] ?? '',
      startLat: (json['StartLat'] ?? json['startLat'] as num).toDouble(),
      startLng: (json['StartLng'] ?? json['startLng'] as num).toDouble(),
      endLat: (json['EndLat'] ?? json['endLat'] as num).toDouble(),
      endLng: (json['EndLng'] ?? json['endLng'] as num).toDouble(),
      travelMode: json['TravelMode'] ?? json['travelMode'] ?? 'driving',
    );
  }

  // Chuyển Object thành JSON để gửi lên API SQL Server
  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'StartLocation': startLocation,
      'EndLocation': endLocation,
      'StartLat': startLat,
      'StartLng': startLng,
      'EndLat': endLat,
      'EndLng': endLng,
      'TravelMode': travelMode,
    };
  }
}