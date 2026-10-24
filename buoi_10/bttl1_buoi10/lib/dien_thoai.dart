
class DienThoai {
  final int maDt;
  final String tenDt;
  final String? hangSx;
  final double gia;
  final int soLuong;
  final String? hinhAnh;
  final String? moTa;

  DienThoai({
    required this.maDt,
    required this.tenDt,
    this.hangSx,
    required this.gia,
    required this.soLuong,
    this.hinhAnh,
    this.moTa,
  });

  factory DienThoai.fromJson(Map<String, dynamic> json) {
    return DienThoai(
      maDt: json['maDt'] ?? json['MaDt'] ?? json['MaDT'] ?? 0,
      tenDt: json['tenDt'] ?? json['TenDt'] ?? json['TenDT'] ?? '',
      hangSx: json['hangSx'] ?? json['HangSx'] ?? json['HangSX'],
      gia: double.tryParse(
            (json['gia'] ?? json['Gia'] ?? 0).toString(),
          ) ??
          0,
      soLuong: int.tryParse(
            (json['soLuong'] ?? json['SoLuong'] ?? 0).toString(),
          ) ??
          0,
      hinhAnh: json['hinhAnh'] ?? json['HinhAnh'],
      moTa: json['moTa'] ?? json['MoTa'],
    );
  }
}
