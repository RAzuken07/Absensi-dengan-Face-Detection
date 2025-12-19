import 'package:dio/dio.dart';
import 'api_service.dart';

class AdminAssignmentService {
  final ApiService _apiService = ApiService();

  // ============ DOSEN-KELAS ASSIGNMENT ============

  Future<Map<String, dynamic>> assignDosenToKelas(Map<String, dynamic> data) async {
    try {
      // Debug log sebelum mengirim
      print('[assignDosenToKelas] Request data: $data');
      final response = await _apiService.post('/admin/kelas-dosen', data: data);

      print('[assignDosenToKelas] Response status: ${response.statusCode}');
      print('[assignDosenToKelas] Response body: ${response.data}');

      return {
        'success': response.statusCode == 201 || response.statusCode == 200,
        'message': _extractServerMessage(response.data) ?? 'Success',
      };
    } on DioException catch (e) {
      final serverMessage = _extractServerMessage(e.response?.data) ?? e.message ?? 'Gagal assign dosen';
      print('[assignDosenToKelas] DioException: status=${e.response?.statusCode} body=${e.response?.data}');
      return {
        'success': false,
        'message': serverMessage,
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      print('[assignDosenToKelas] Unknown error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<List<dynamic>> getDosenByKelas(int idKelas) async {
    try {
      print('[getDosenByKelas] GET /admin/kelas/$idKelas/dosen');
      final response = await _apiService.get('/admin/kelas/$idKelas/dosen');

      print('[getDosenByKelas] status=${response.statusCode} data=${response.data}');

      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      }
      return [];
    } on DioException catch (e) {
      print('[getDosenByKelas] DioException: ${e.response?.statusCode} ${e.response?.data}');
      return [];
    } catch (e) {
      print('[getDosenByKelas] Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> removeDosenFromKelas(int idKelasDosen) async {
    try {
      print('[removeDosenFromKelas] DELETE /admin/kelas-dosen/$idKelasDosen');
      final response = await _apiService.delete('/admin/kelas-dosen/$idKelasDosen');

      print('[removeDosenFromKelas] status=${response.statusCode} body=${response.data}');

      return {
        'success': response.statusCode == 200,
        'message': _extractServerMessage(response.data) ?? 'Success',
      };
    } on DioException catch (e) {
      final serverMessage = _extractServerMessage(e.response?.data) ?? 'Gagal hapus assignment';
      print('[removeDosenFromKelas] DioException: status=${e.response?.statusCode} body=${e.response?.data}');
      return {
        'success': false,
        'message': serverMessage,
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      print('[removeDosenFromKelas] Unknown error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Helper: try to read user-friendly message from server response body
  String? _extractServerMessage(dynamic body) {
    try {
      if (body == null) return null;
      if (body is Map) {
        if (body.containsKey('error')) return body['error']?.toString();
        if (body.containsKey('message')) return body['message']?.toString();
        if (body.containsKey('detail')) return body['detail']?.toString();
        // fallback: return concatenation of fields
        return body.values.map((v) => v?.toString()).where((v) => v != null).join(' | ');
      } else {
        return body.toString();
      }
    } catch (e) {
      return body?.toString();
    }
  }
}