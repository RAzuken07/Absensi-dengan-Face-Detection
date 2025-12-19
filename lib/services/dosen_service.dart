import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/sesi_model.dart';
import '../models/kelas_model.dart';
import 'api_service.dart';

class DosenService {
  final ApiService _apiService = ApiService();

  // Register Face for Dosen
  Future<Map<String, dynamic>> registerFace(File faceImage) async {
    try {
      String fileName = faceImage.path.split('/').last;
      final requestData = FormData.fromMap({
        'face_image': await MultipartFile.fromFile(
          faceImage.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.post(
        '/dosen/face/register',
        data: requestData,
      );

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Gagal upload wajah',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Verify Face for Dosen (before opening session)
  Future<Map<String, dynamic>> verifyFace(File faceImage) async {
    try {
      // Compress image before sending to reduce transfer time
      final compressedImage = await _compressImage(faceImage);
      
      String fileName = compressedImage.path.split('/').last;
      final requestData = FormData.fromMap({
        'face_image': await MultipartFile.fromFile(
          compressedImage.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.post(
        '/dosen/face/verify',
        data: requestData,
      );

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Verifikasi berhasil',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Verifikasi gagal',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Compress image to reduce file size and speed up upload
  Future<File> _compressImage(File file) async {
    try {
      final image = img.decodeImage(await file.readAsBytes());
      if (image == null) return file;

      // Resize to max width 600px for faster transfer
      final resized = image.width > 600
          ? img.copyResize(image, width: 600)
          : image;

      // Compress with quality 70
      final compressed = img.encodeJpg(resized, quality: 70);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressed);

      return tempFile;
    } catch (e) {
      print('Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }

  Future<List<KelasModel>> getKelas() async {
    try {
      final response = await _apiService.get('/dosen/kelas');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => KelasModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting kelas: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> openSesi(Map<String, dynamic> data) async {
    try {
      print('openSesi: Sending data to backend: $data');

      final response = await _apiService.post('/dosen/open-sesi', data: data);

      print('openSesi: Response status: ${response.statusCode}');
      print('openSesi: Response body: ${response.data}');

      if (response.statusCode == 201) {
        return {'success': true, 'data': response.data['data']};
      }

      // Handle other status codes
      return {
        'success': false,
        'error':
            response.data['error'] ??
            response.data['message'] ??
            'Gagal membuka sesi (Status: ${response.statusCode})',
      };
    } on DioException catch (e) {
      print('openSesi: DioException - ${e.type}');
      print('openSesi: Status code: ${e.response?.statusCode}');
      print('openSesi: Response: ${e.response?.data}');

      String errorMessage = 'Gagal membuka sesi';

      if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data['error'] ?? 'Request tidak valid';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Anda belum login atau session telah berakhir';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Terjadi kesalahan di server';
      }

      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('openSesi: Exception - $e');
      return {'success': false, 'error': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  // Get pertemuan status - which pertemuan have sessions created
  Future<List<int>> getPertemuanStatus(int idKelas) async {
    try {
      final response = await _apiService.get(
        '/dosen/pertemuan-status/$idKelas',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map<int>((item) => item['pertemuan_ke'] as int).toList();
      }
      return [];
    } catch (e) {
      print('Error getting pertemuan status: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> closeSesi(int idSesi) async {
    try {
      final response = await _apiService.post('/dosen/close-sesi/$idSesi');

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Success',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<dynamic>> getRekap(int idKelas) async {
    try {
      final response = await _apiService.get('/dosen/rekap/$idKelas');

      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      print('Error getting rekap: $e');
      return [];
    }
  }

  Future<List<SesiModel>> getActiveSessions() async {
    try {
      final response = await _apiService.get('/dosen/active-sessions');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => SesiModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting active sessions: $e');
      return [];
    }
  }

  // Get Pertemuan by Kelas
  Future<List<Map<String, dynamic>>> getPertemuanByKelas(int idKelas) async {
    try {
      final response = await _apiService.get('/dosen/pertemuan/$idKelas');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting pertemuan: $e');
      return [];
    }
  }

  // Get Absensi Detail by Pertemuan
  Future<List<Map<String, dynamic>>> getAbsensiByPertemuan(
    int idPertemuan,
  ) async {
    try {
      final response = await _apiService.get(
        '/dosen/absensi/pertemuan/$idPertemuan',
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting absensi detail: $e');
      return [];
    }
  }

  // Update Attendance Status
  Future<Map<String, dynamic>> updateAttendanceStatus({
    required int idPertemuan,
    required String nim,
    required String newStatus,
  }) async {
    try {
      final response = await _apiService.put(
        '/dosen/absensi/update-status',
        data: {
          'id_pertemuan': idPertemuan,
          'nim': nim,
          'new_status': newStatus,
        },
      );

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Status updated successfully',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Failed to update status',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
