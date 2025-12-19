import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/sesi_model.dart';
import '../models/absensi_model.dart';
import 'api_service.dart';

class MahasiswaService {
  final ApiService _apiService = ApiService();
  
  Future<List<SesiModel>> getActiveSessions() async {
    try {
      final response = await _apiService.get('/absensi/active-sessions');
      
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
  
  Future<List<Map<String, dynamic>>> getMyMatakuliah() async {
    try {
      final response = await _apiService.get('/absensi/my-matakuliah');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error getting mata kuliah: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> submitAbsensi(
    Map<String, dynamic> data,
    File? faceImage,
  ) async {
    try {
      FormData formData;
      
      if (faceImage != null) {
        // Submit with face image
        String fileName = faceImage.path.split('/').last;
        formData = FormData.fromMap({
          ...data,
          'face_image': await MultipartFile.fromFile(
            faceImage.path,
            filename: fileName,
          ),
        });
      } else {
        formData = FormData.fromMap(data);
      }
      
      final response = await _apiService.post('/absensi/submit', data: formData);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Absensi berhasil',
        };
      }
      
      return {
        'success': false,
        'message': response.data['error'] ?? 'Failed to submit attendance',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Gagal submit absensi',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  Future<List<AbsensiModel>> getHistory() async {
    try {
      final response = await _apiService.get('/absensi/history');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AbsensiModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>?> getStatistics() async {
    try {
      final response = await _apiService.get('/absensi/statistics');
      
      if (response.statusCode == 200) {
        // Backend returns {data: {...}} format
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting statistics: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>> registerFace(dynamic faceImage) async {
    try {
      dynamic requestData;
      
      // Support both File and base64 string
      if (faceImage is File) {
        // Compress image first for faster upload
        final compressedImage = await _compressImage(faceImage);
        
        // File upload
        String fileName = compressedImage.path.split('/').last;
        requestData = FormData.fromMap({
          'face_image': await MultipartFile.fromFile(
            compressedImage.path,
            filename: fileName,
          ),
        });
      } else {
        // Base64 string
        requestData = {
          'face_image': faceImage,
        };
      }
      
      final response = await _apiService.post(
        '/face/register',
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
      return {
        'success': false,
        'message': e.toString(),
      };
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
  
  Future<Map<String, dynamic>> getFaceStatus(String nim) async {
    try {
      final response = await _apiService.get('/face/status/$nim');
      
      if (response.statusCode == 200) {
        return {
          'registered': response.data['face_registered'] ?? false,
        };
      }
      return {' registered': false};
    } catch (e) {
      return {'registered': false};
    }
  }
  
  Future<List<Map<String, dynamic>>> getPertemuanStatus(int idKelas, String nim) async {
    try {
      final response = await _apiService.get('/absensi/pertemuan-status/$idKelas/$nim');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error getting pertemuan status: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>?> getSessionInfo(int idSesi) async {
    try {
      final response = await _apiService.get('/absensi/sesi/$idSesi');
      
      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting session info: $e');
      return null;
    }
  }
}
