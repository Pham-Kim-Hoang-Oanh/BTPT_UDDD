
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dien_thoai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Danh mục sản phẩm',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const DanhMucPage(),
    );
  }
}

// ================== DANH MỤC SẢN PHẨM ==================

class DanhMucPage extends StatefulWidget {
  const DanhMucPage({super.key});

  @override
  State<DanhMucPage> createState() => _DanhMucPageState();
}

class _DanhMucPageState extends State<DanhMucPage> {
  List<DienThoai> danhSach = [];
  bool dangTai = true;
  String loi = '';

  final String apiUrl =
      'http://10.0.2.2:5252/api/DienThoai';

  @override
  void initState() {
    super.initState();
    taiDanhSach();
  }

  Future<void> taiDanhSach() async {
    setState(() {
      dangTai = true;
      loi = '';
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode != 200) {
        throw Exception('Mã lỗi: ${response.statusCode}');
      }

      final List<dynamic> duLieu = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final ketQua = duLieu
          .map(
            (item) => DienThoai.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        danhSach = ketQua;
        dangTai = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loi = 'Không tải được danh sách sản phẩm.\n$e';
        dangTai = false;
      });
    }
  }

  String dinhDangGia(double gia) {
    final giaNguyen = gia.toStringAsFixed(0);
    final ketQua = StringBuffer();

    for (int i = 0; i < giaNguyen.length; i++) {
      if (i > 0 && (giaNguyen.length - i) % 3 == 0) {
        ketQua.write('.');
      }
      ketQua.write(giaNguyen[i]);
    }

    return '${ketQua.toString()} đ';
  }

  Widget anhDienThoai(
    String? tenAnh, {
    double width = 90,
    double height = 105,
  }) {
    if (tenAnh == null || tenAnh.trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade100,
        child: const Icon(
          Icons.phone_android,
          size: 45,
          color: Colors.grey,
        ),
      );
    }

    return Image.asset(
      'assets/$tenAnh',
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade100,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text(
          'DANH MỤC SẢN PHẨM',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: taiDanhSach,
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: dangTai
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : loi.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 45,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loi,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: taiDanhSach,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : danhSach.isEmpty
                  ? const Center(
                      child: Text('Chưa có sản phẩm nào.'),
                    )
                  : RefreshIndicator(
                      onRefresh: taiDanhSach,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(10),
                        itemCount: danhSach.length,
                        separatorBuilder: (context, index) {
                          return const Divider(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final dt = danhSach[index];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChiTietPage(
                                    dienThoai: dt,
                                    dinhDangGia: dinhDangGia,
                                    anhDienThoai: anhDienThoai,
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 125,
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(6),
                                    child: anhDienThoai(
                                      dt.hinhAnh,
                                      width: 95,
                                      height: 112,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dt.tenDt,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Expanded(
                                          child: Text(
                                            (dt.moTa?.isNotEmpty ??
                                                    false)
                                                ? dt.moTa!
                                                : 'Hãng ${dt.hangSx ?? 'chưa cập nhật'}',
                                            maxLines: 3,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Giá: ${dinhDangGia(dt.gia)}',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

// ================== THÔNG TIN SẢN PHẨM ==================

class ChiTietPage extends StatelessWidget {
  final DienThoai dienThoai;
  final String Function(double) dinhDangGia;
  final Widget Function(
    String?, {
    double width,
    double height,
  }) anhDienThoai;

  const ChiTietPage({
    super.key,
    required this.dienThoai,
    required this.dinhDangGia,
    required this.anhDienThoai,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'THÔNG TIN SẢN PHẨM',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tên: ${dienThoai.tenDt}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: anhDienThoai(
                dienThoai.hinhAnh,
                width: double.infinity,
                height: 330,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Giá: ${dinhDangGia(dienThoai.gia)}',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hãng sản xuất: ${dienThoai.hangSx ?? 'Chưa cập nhật'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Số lượng: ${dienThoai.soLuong}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mô tả',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (dienThoai.moTa?.isNotEmpty ?? false)
                  ? dienThoai.moTa!
                  : 'Chưa có mô tả sản phẩm.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
