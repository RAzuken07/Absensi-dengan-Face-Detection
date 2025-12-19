from database.db import Database
from datetime import datetime
from utils.geolocation import validate_location
from utils.qr_generator import validate_qr_data
from services.face_service import FaceService

class AbsensiService:
    """Service for attendance operations"""
    
    @staticmethod
    def get_active_sessions_for_student(nim):
        """Get active sessions for student's classes"""
        query = """
            SELECT v.* 
            FROM v_sesi_aktif v
            JOIN pertemuan p ON v.id_pertemuan = p.id_pertemuan
            JOIN kelas k ON p.id_kelas = k.id_kelas
            JOIN mahasiswa m ON m.id_kelas = k.id_kelas
            WHERE m.nim = %s AND v.sisa_menit > 0
            ORDER BY v.waktu_buka DESC
        """
        return Database.execute_query(query, (nim,), fetch_all=True)
    
    @staticmethod
    def get_session_info(id_sesi):
        """Get session information"""
        # First, check if session exists at all
        simple_query = "SELECT * FROM sesi_absensi WHERE id_sesi = %s"
        simple_result = Database.execute_query(simple_query, (id_sesi,), fetch_one=True)
        
        print(f"[DEBUG] Simple session lookup for id_sesi {id_sesi}: {simple_result}")
        
        if not simple_result:
            print(f"[ERROR] Session {id_sesi} does not exist in sesi_absensi table")
            return None
        
        # Now try the full query with all joins
        query = """
            SELECT s.*, p.pertemuan_ke, p.topik, k.nama_kelas, 
                   mk.nama_matakuliah, d.nama as nama_dosen
            FROM sesi_absensi s
            LEFT JOIN pertemuan p ON s.id_pertemuan = p.id_pertemuan
            LEFT JOIN kelas k ON p.id_kelas = k.id_kelas
            LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
            LEFT JOIN dosen d ON s.nip_dosen = d.nip
            WHERE s.id_sesi = %s
        """
        result = Database.execute_query(query, (id_sesi,), fetch_one=True)
        print(f"[DEBUG] Full session info for id_sesi {id_sesi}: {result}")
        return result
    
    @staticmethod
    def check_already_absent(nim, id_pertemuan):
        """Check if student already submitted attendance"""
        query = """
            SELECT id_absensi FROM absensi 
            WHERE nim = %s AND id_pertemuan = %s
        """
        result = Database.execute_query(query, (nim, id_pertemuan), fetch_one=True)
        return result is not None
    
    @staticmethod
    def submit_absensi(data):
        """
        Submit attendance with multi-layer validation
        
        Required data:
        - nim: Student NIM
        - id_sesi: Session ID
        - qr_data: Scanned QR code data
        - face_image: Face image for verification
        - latitude: Student location latitude
        - longitude: Student location longitude
        
        Returns:
            tuple: (success: bool, message: str or dict)
        """
        try:
            nim = data['nim']
            id_sesi = data['id_sesi']
            
            print(f"[DEBUG] Attempting to submit absensi for NIM: {nim}, id_sesi: {id_sesi}")
            
            # 1. Get session info
            sesi = AbsensiService.get_session_info(id_sesi)
            if not sesi:
                print(f"[ERROR] Session not found for id_sesi: {id_sesi}")
                # Check if session exists in database
                check_query = "SELECT id_sesi, status_sesi FROM sesi_absensi WHERE id_sesi = %s"
                session_check = Database.execute_query(check_query, (id_sesi,), fetch_one=True)
                if session_check:
                    print(f"[DEBUG] Session exists but query failed. Status: {session_check.get('status_sesi')}")
                else:
                    print(f"[DEBUG] Session with id_sesi {id_sesi} does not exist in database")
                return False, f"Session not found (id_sesi: {id_sesi}). Pastikan dosen sudah membuka sesi untuk pertemuan ini."
            
            # 2. Check if session is still active
            if sesi['status_sesi'] != 'aktif':
                return False, "Session is closed"
            
            # 3. Check session time
            waktu_buka = sesi['waktu_buka']
            durasi_menit = sesi['durasi_menit']
            waktu_sekarang = datetime.now()
            
            # Convert to datetime if needed
            if isinstance(waktu_buka, str):
                waktu_buka = datetime.fromisoformat(waktu_buka)
            
            waktu_berlalu = (waktu_sekarang - waktu_buka).total_seconds() / 60
            
            if waktu_berlalu > durasi_menit:
                return False, f"Session timeout ({int(waktu_berlalu)} minutes elapsed, limit: {durasi_menit} minutes)"
            
            # 4. Check if already submitted
            if AbsensiService.check_already_absent(nim, sesi['id_pertemuan']):
                return False, "You have already submitted attendance for this session"
            
            # 5. Validate QR code
            qr_valid, qr_result = validate_qr_data(data['qr_data'], id_sesi)
            if not qr_valid:
                return False, f"QR validation failed: {qr_result.get('error', 'Invalid QR code')}"
            
            # 6. Validate face recognition
            face_valid, face_result = FaceService.verify_face(
                nim, 
                data['face_image'],
                tolerance=0.6
            )
            
            if not face_valid:
                return False, f"Face verification failed: {face_result}"
            
            confidence_score = face_result  # face_result is confidence score if valid
            
            # 7. Validate geolocation
            if sesi['lokasi_lat'] and sesi['lokasi_long']:
                location_validation = validate_location(
                    float(data['latitude']),
                    float(data['longitude']),
                    float(sesi['lokasi_lat']),
                    float(sesi['lokasi_long']),
                    sesi['radius_meter']
                )
                
                if not location_validation['valid']:
                    return False, location_validation['message']
            
            # 8. All validations passed - Insert attendance
            query = """
                INSERT INTO absensi 
                (nim, id_pertemuan, id_sesi, status, metode, confidence_score, 
                 lokasi_lat, lokasi_long, waktu_absen)
                VALUES (%s, %s, %s, 'hadir', 'face_recognition', %s, %s, %s, NOW())
            """
            
            absensi_id = Database.execute_query(
                query,
                (nim, sesi['id_pertemuan'], id_sesi, confidence_score,
                 data['latitude'], data['longitude']),
                commit=True
            )
            
            return True, {
                'id_absensi': absensi_id,
                'message': 'Attendance submitted successfully',
                'confidence_score': confidence_score,
                'waktu_absen': waktu_sekarang.isoformat()
            }
            
        except KeyError as e:
            return False, f"Missing required field: {str(e)}"
        except Exception as e:
            return False, f"Error submitting attendance: {str(e)}"
    
    @staticmethod
    def get_history(nim):
        """Get attendance history for student"""
        query = """
            SELECT 
                a.*,
                p.pertemuan_ke, p.tanggal, p.topik,
                k.nama_kelas,
                mk.nama_matakuliah,
                s.waktu_buka, s.waktu_tutup
            FROM absensi a
            JOIN pertemuan p ON a.id_pertemuan = p.id_pertemuan
            JOIN sesi_absensi s ON a.id_sesi = s.id_sesi
            JOIN kelas k ON p.id_kelas = k.id_kelas
            JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
            WHERE a.nim = %s
            ORDER BY p.tanggal DESC, a.waktu_absen DESC
        """
        return Database.execute_query(query, (nim,), fetch_all=True)
    
    @staticmethod
    def get_statistics(nim):
        """Get attendance statistics for student"""
        query = """
            SELECT 
                k.nama_kelas,
                mk.nama_matakuliah,
                COUNT(DISTINCT p.id_pertemuan) as total_pertemuan,
                COUNT(DISTINCT CASE WHEN a.status = 'hadir' THEN a.id_absensi END) as hadir,
                COUNT(DISTINCT CASE WHEN a.status = 'izin' THEN a.id_absensi END) as izin,
                COUNT(DISTINCT CASE WHEN a.status = 'sakit' THEN a.id_absensi END) as sakit,
                ROUND(
                    COUNT(DISTINCT CASE WHEN a.status = 'hadir' THEN a.id_absensi END) / 
                    COUNT(DISTINCT p.id_pertemuan) * 100, 2
                ) as persentase_kehadiran
            FROM mahasiswa m
            JOIN kelas k ON m.id_kelas = k.id_kelas
            JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
            CROSS JOIN pertemuan p ON p.id_kelas = k.id_kelas
            LEFT JOIN absensi a ON a.nim = m.nim AND a.id_pertemuan = p.id_pertemuan
            WHERE m.nim = %s
            GROUP BY k.nama_kelas, mk.nama_matakuliah
        """
        return Database.execute_query(query, (nim,), fetch_all=True)
    
    @staticmethod
    def get_pertemuan_status_mahasiswa(id_kelas, nim):
        """
        Get pertemuan list with attendance status for mahasiswa
        
        Returns list of pertemuan with:
        - Basic info: pertemuan_ke, topik, tanggal
        - Session info: id_sesi, status_sesi (aktif/selesai), waktu_buka, durasi_menit
        - Attendance info: status_absensi (hadir/null), waktu_absen
        """
        query = """
            SELECT 
                p.id_pertemuan,
                p.pertemuan_ke,
                p.topik,
                p.tanggal,
                s.id_sesi,
                s.status_sesi,
                s.waktu_buka,
                s.durasi_menit,
                a.status as status_absensi,
                a.waktu_absen
            FROM pertemuan p
            LEFT JOIN sesi_absensi s ON s.id_pertemuan = p.id_pertemuan
            LEFT JOIN absensi a ON a.id_pertemuan = p.id_pertemuan AND a.nim = %s
            WHERE p.id_kelas = %s
            ORDER BY p.pertemuan_ke
        """
        return Database.execute_query(query, (nim, id_kelas), fetch_all=True)

