import 'package:dio/dio.dart';
import '../models/dosen_model.dart';
import '../models/mahasiswa_model.dart';
import '../models/matakuliah_model.dart';
import '../models/kelas_model.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  // ============ DOSEN OPERATIONS ============

  Future<List<DosenModel>> getAllDosen() async {
    try {
      final response = await _apiService.get('/admin/dosen');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => DosenModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting dosen: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createDosen(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/admin/dosen', data: data);

      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateDosen(
    String nip,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put('/admin/dosen/$nip', data: data);

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteDosen(String nip) async {
    try {
      final response = await _apiService.delete('/admin/dosen/$nip');

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============ MAHASISWA OPERATIONS ============

  Future<List<MahasiswaModel>> getAllMahasiswa() async {
    try {
      final response = await _apiService.get('/admin/mahasiswa');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MahasiswaModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting mahasiswa: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createMahasiswa(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.post('/admin/mahasiswa', data: data);

      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateMahasiswa(
    String nim,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put(
        '/admin/mahasiswa/$nim',
        data: data,
      );

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteMahasiswa(String nim) async {
    try {
      final response = await _apiService.delete('/admin/mahasiswa/$nim');

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============ MATA KULIAH OPERATIONS ============

  Future<List<MataKuliahModel>> getAllMataKuliah() async {
    try {
      final response = await _apiService.get('/admin/matakuliah');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MataKuliahModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting mata kuliah: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createMataKuliah(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.post('/admin/matakuliah', data: data);

      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateMataKuliah(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put(
        '/admin/matakuliah/$id',
        data: data,
      );

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteMataKuliah(int id) async {
    try {
      final response = await _apiService.delete('/admin/matakuliah/$id');

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============ KELAS OPERATIONS ============

  Future<List<KelasModel>> getAllKelas() async {
    try {
      print('Calling /admin/kelas endpoint...');
      final response = await _apiService.get('/admin/kelas');

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        print('Found ${data.length} kelas');
        final kelasList = data
            .map((json) => KelasModel.fromJson(json))
            .toList();
        print('Parsed ${kelasList.length} kelas models');
        return kelasList;
      }
      print('Response not 200, returning empty list');
      return [];
    } on DioException catch (e) {
      print('DioException getting kelas: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      return [];
    } catch (e, stackTrace) {
      print('Error getting kelas: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<Map<String, dynamic>> createKelas(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/admin/kelas', data: data);

      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateKelas(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      print('[updateKelas] Updating kelas $id with data: $data');
      final response = await _apiService.put('/admin/kelas/$id', data: data);
      
      print('[updateKelas] Response status: ${response.statusCode}');
      print('[updateKelas] Response data: ${response.data}');

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } on DioException catch (e) {
      print('[updateKelas] DioException: ${e.message}');
      print('[updateKelas] Response: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['error'] ?? e.message ?? 'Gagal update kelas',
      };
    } catch (e) {
      print('[updateKelas] Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteKelas(int id) async {
    try {
      final response = await _apiService.delete('/admin/kelas/$id');

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Gagal hapus kelas',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============ KELAS-DOSEN ASSIGNMENT ============

  Future<Map<String, dynamic>> assignDosenToKelas(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.post('/admin/kelas-dosen', data: data);

      return {
        'success': response.statusCode == 201,
        'message': response.data['message'] ?? 'Success',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Gagal assign dosen',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<dynamic>> getDosenByKelas(int idKelas) async {
    try {
      final response = await _apiService.get('/admin/kelas/$idKelas/dosen');

      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting dosen by kelas: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> removeDosenFromKelas(int idKelasDosen) async {
    try {
      final response = await _apiService.delete(
        '/admin/kelas-dosen/$idKelasDosen',
      );

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Gagal hapus assignment',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============ KELAS-DOSEN ASSIGNMENT OPERATIONS ============

  Future<List<Map<String, dynamic>>> getKelasAssignments(int idKelas) async {
    try {
      print('[getKelasAssignments] Fetching assignments for kelas $idKelas');
      final response = await _apiService.get('/admin/kelas/$idKelas/dosen');

      print('[getKelasAssignments] Response status: ${response.statusCode}');
      print('[getKelasAssignments] Response data type: ${response.data.runtimeType}');
      print('[getKelasAssignments] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        print('[getKelasAssignments] Data field type: ${data.runtimeType}');
        print('[getKelasAssignments] Data length: ${data is List ? data.length : 'not a list'}');
        
        if (data is List) {
          final result = List<Map<String, dynamic>>.from(data);
          print('[getKelasAssignments] Returning ${result.length} assignments');
          if (result.isNotEmpty) {
            print('[getKelasAssignments] First assignment: ${result[0]}');
          }
          return result;
        }
      }
      print('[getKelasAssignments] Returning empty list');
      return [];
    } catch (e, stackTrace) {
      print('[getKelasAssignments] Error: $e');
      print('[getKelasAssignments] Stack trace: $stackTrace');
      return [];
    }
  }

  Future<Map<String, dynamic>> assignDosenMatakuliah(
    int idKelas,
    String nip,
    int idMatakuliah, {
    String? ruangan,
    String? hari,
    String? jamMulai,
    String? jamSelesai,
  }) async {
    final data = {
      'id_kelas': idKelas,
      'nip': nip.trim(),
      'id_matakuliah': idMatakuliah,
      if (ruangan != null && ruangan.isNotEmpty) 'ruangan': ruangan.trim(),
      if (hari != null && hari.isNotEmpty) 'hari': hari,
      if (jamMulai != null && jamMulai.isNotEmpty) 'jam_mulai': jamMulai.trim(),
      if (jamSelesai != null && jamSelesai.isNotEmpty)
        'jam_selesai': jamSelesai.trim(),
    };

    print('[assignDosenMatakuliah] Request data: $data');

    try {
      final response = await _apiService.post('/admin/kelas-dosen', data: data);
      print(
        '[assignDosenMatakuliah] Response: ${response.statusCode} ${response.data}',
      );
      final message = _extractServerMessage(response.data) ?? 'Success';
      return {
        'success': response.statusCode == 201 || response.statusCode == 200,
        'message': message,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print(
        '[assignDosenMatakuliah] DioException: status=${e.response?.statusCode} body=${e.response?.data}',
      );
      final msg =
          _extractServerMessage(e.response?.data) ??
          e.message ??
          'Gagal assign dosen';
      return {
        'success': false,
        'message': msg,
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      print('[assignDosenMatakuliah] Unknown error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> removeKelasDosen(int id) async {
    try {
      final response = await _apiService.delete('/admin/kelas-dosen/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('Error removing kelas-dosen: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllKelasDosen() async {
    try {
      final response = await _apiService.get(
        '/admin/kelas-dosen',
      ); // sesuaikan path jika backend lain
      final data = response.data;

      List items = [];

      if (data == null) {
        items = [];
      } else if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        // handle common shapes: { data: [...] } , { rows: [...] } , { result: [...] }
        if (data['data'] is List) {
          items = data['data'];
        } else if (data['rows'] is List) {
          items = data['rows'];
        } else if (data['result'] is List) {
          items = data['result'];
        } else {
          // single object -> wrap jadi list
          items = [data];
        }
      } else {
        // fallback
        items = [];
      }

      // Pastikan semua item menjadi Map<String, dynamic>
      final normalized = items.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is Map) return Map<String, dynamic>.from(e);
        return <String, dynamic>{};
      }).toList();

      return normalized;
    } on DioException catch (e) {
      // log detail bila perlu
      print('[AdminService] getAllKelasDosen DioException: ${e.message}');
      if (e.response != null) {
        print('[AdminService] response data: ${e.response?.data}');
      }
      return [];
    } catch (e, st) {
      print('[AdminService] getAllKelasDosen error: $e\n$st');
      return [];
    }
  }
}

// helper (tambahkan ke kelas AdminService jika belum ada)
String? _extractServerMessage(dynamic body) {
  try {
    if (body == null) return null;
    if (body is Map) {
      if (body.containsKey('error')) return body['error']?.toString();
      if (body.containsKey('message')) return body['message']?.toString();
      if (body.containsKey('detail')) return body['detail']?.toString();
      return body.values
          .map((v) => v?.toString())
          .where((v) => v != null)
          .join(' | ');
    } else {
      return body.toString();
    }
  } catch (e) {
    return body?.toString();
  }
}
