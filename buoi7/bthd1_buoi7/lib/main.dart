import 'package:flutter/material.dart';

import 'maps_screen.dart';
//import 'router_finder_screen.dart';
//import '../services/map_screen.dart';

void main() {
  //BAI 1 
  runApp(MapNavigatorApp());

  //BAI2
  //runApp(RouteFinderApp());

  //BAI3
  //runApp( const MyApp());
}

//BAI 1
class MapNavigatorApp extends StatelessWidget {
const MapNavigatorApp({super.key});
@override
Widget build(BuildContext context) {
return MaterialApp(title: 'Map Navigator', home: MapScreen());
}
}

//BAI 2
// class RouteFinderApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(title: 'Route Finder', home: RouteFinderScreen());
//   }
// }

//BAI 3
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Ứng dụng Bản đồ SQL Server',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: false,
//       ),
//       home: const MapScreen(), // Gọi sang màn hình chính
//     );
//   }
// }