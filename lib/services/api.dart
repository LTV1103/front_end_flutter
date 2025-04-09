import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String api = 'https://node-js-api.up.railway.app/api/';

  // Người dùng
  Future<List<dynamic>> layDanhSachNguoiDung() async {
    return _getRequest('nguoidung');
  }

  Future<dynamic> layNguoiDungTheoId(int id) async {
    return _getRequest('nguoidung/$id');
  }

  Future<dynamic> dangKyNguoiDung(Map<String, dynamic> data) async {
    return _postRequest('nguoidung/regeister', data);
  }

  Future<dynamic> dangNhapNguoiDung(Map<String, dynamic> data) async {
    return _postRequest('nguoidung/login', data);
  }

  Future<dynamic> xoaNguoiDung(String id) async {
    return _deleteRequest('nguoidung/$id');
  }

  Future<dynamic> capNhatNguoiDung(int id, Map<String, dynamic> data) async {
    return _putRequest('nguoidung/$id', data);
  }

  // Uống thuốc
  Future<List<dynamic>> layLoiNhacThuoc(String userId) async {
    return _getRequest('uongthuoc/$userId');
  }

  Future<dynamic> themLoiNhacThuoc(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('https://node-js-api.up.railway.app/api/uongthuoc'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
          'API Response Body: ${response.body}',
        ); // Kiểm tra phản hồi từ API
        return json.decode(response.body);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Lỗi API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('API Exception: $e');
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  Future<dynamic> capNhatLoiNhacThuoc(Map<String, dynamic> data, int id) async {
    try {
      final response = await http.put(
        Uri.parse('https://node-js-api.up.railway.app/api/uongthuoc/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Lỗi API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  Future<dynamic> xoaLoiNhacThuoc(int id) async {
    return _deleteRequest('uongthuoc/$id');
  }

  // Chỉ số
  Future<List<dynamic>> layChiSoTheoId(int id) async {
    return _getRequest('chiso/$id');
  }

  Future<dynamic> layChiTietChiSo(String id) async {
    return _getRequest('chiso/chitiet/$id');
  }

  Future<dynamic> themChiSo(String id, Map<String, dynamic> data) async {
    return _postRequest('chiso/$id', data);
  }

  Future<dynamic> capNhatChiSo(Map<String, dynamic> data, int id) async {
    return _putRequest('chiso/$id', data);
  }

  Future<dynamic> xoaChiSo(int id) async {
    return _deleteRequest('chiso/$id');
  }

  // Nhật ký
  Future<List<dynamic>> layNhatKy(int id) async {
    return _getRequest('nhatky/$id');
  }

  Future<dynamic> layChiTietNhatKy(String id) async {
    return _getRequest('nhatky/chitiet/$id');
  }

  Future<dynamic> themHoatDongNhatKy(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _postRequest('nhatky/$id', data);
  }

  Future<dynamic> capNhatNhatKy(Map<String, dynamic> data, int id) async {
    try {
      final response = await http.put(
        Uri.parse('https://node-js-api.up.railway.app/api/nhatky/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['status'] == 'success') {
          return jsonBody; // Trả về phản hồi nếu thành công
        } else {
          throw Exception(jsonBody['message'] ?? 'Lỗi cập nhật nhật ký');
        }
      } else {
        throw Exception('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  Future<dynamic> xoaNhatKy(int id) async {
    return _deleteRequest('nhatky/$id');
  }

  // Uống nước
  Future<dynamic> layTongLuongNuoc(String id, String ngay) async {
    return _getRequest('uongnuoc/tong/$id/$ngay');
  }

  Future<List<dynamic>> layDanhSachLuongNuoc(String id) async {
    return _getRequest('uongnuoc/$id');
  }

  Future<dynamic> themLuongNuoc(Map<String, dynamic> data) async {
    return _postRequest('uongnuoc/them', data);
  }

  Future<dynamic> capNhatLuongNuoc(Map<String, dynamic> data, int maLuongNuoc) async {
    return _putRequest('uongnuoc/capnhat', data);
  }

  Future<dynamic> xoaLuongNuoc(int id) async {
    return _deleteRequest('uongnuoc/xoa/$id');
  }

  // Ghi chép
  Future<List<dynamic>> layGhiChep(String id) async {
    return _getRequest('ghichep/$id');
  }

  Future<dynamic> layChiTietGhiChep(String id) async {
    return _getRequest('ghichep/chitiet/$id');
  }

  Future<dynamic> themGhiChep(Map<String, dynamic> data) async {
    return _postRequest('ghichep', data);
  }

  Future<dynamic> xoaGhiChep(String id) async {
    return _deleteRequest('ghichep/$id');
  }

  // Các hàm HTTP chung
  Future<List<dynamic>> _getRequest(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$api$endpoint'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['data']; // Trả về phần data nếu status là success
        } else {
          throw Exception(jsonResponse['message'] ?? 'Lỗi tải dữ liệu');
        }
      } else {
        throw Exception('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  Future<dynamic> _postRequest(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$api$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  Future<dynamic> _putRequest(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$api$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  Future<dynamic> _deleteRequest(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$api$endpoint'));
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }
}
