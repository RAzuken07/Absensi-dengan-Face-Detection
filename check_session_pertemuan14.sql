-- Query untuk mengecek sesi pertemuan 14
-- Ganti id_kelas sesuai dengan kelas yang digunakan

-- 1. Cek pertemuan ke-14 ada atau tidak
SELECT * FROM pertemuan 
WHERE pertemuan_ke = 14 
ORDER BY id_kelas;

-- 2. Cek sesi untuk pertemuan ke-14
SELECT 
    p.id_pertemuan,
    p.id_kelas,
    p.pertemuan_ke,
    p.topik,
    p.tanggal,
    s.id_sesi,
    s.status_sesi,
    s.waktu_buka,
    s.waktu_tutup,
    s.kode_sesi,
    s.nip_dosen
FROM pertemuan p
LEFT JOIN sesi_absensi s ON p.id_pertemuan = s.id_pertemuan
WHERE p.pertemuan_ke = 14
ORDER BY p.id_kelas;

-- 3. Cek status pertemuan untuk mahasiswa tertentu (ganti NIM)
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
LEFT JOIN absensi a ON a.id_pertemuan = p.id_pertemuan AND a.nim = '202357301085'
WHERE p.pertemuan_ke = 14
ORDER BY p.id_kelas;
