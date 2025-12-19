# Test Query untuk Debug Session Not Found

Jalankan query ini di MySQL/MariaDB untuk mengecek sesi ke-15:

```sql
-- 1. Cek sesi dengan id_sesi = 15
SELECT * FROM sesi_absensi WHERE id_sesi = 15;

-- 2. Cek pertemuan yang terkait dengan sesi tersebut
SELECT 
    s.id_sesi,
    s.id_pertemuan,
    s.nip_dosen,
    s.status_sesi,
    s.waktu_buka,
    s.waktu_tutup,
    p.id_kelas,
    p.pertemuan_ke,
    p.topik
FROM sesi_absensi s
LEFT JOIN pertemuan p ON s.id_pertemuan = p.id_pertemuan
WHERE s.id_sesi = 15;

-- 3. Full join untuk cek semua relasi
SELECT 
    s.id_sesi,
    s.id_pertemuan,
    s.nip_dosen,
    s.status_sesi,
    p.pertemuan_ke,
    p.topik,
    p.id_kelas,
    k.nama_kelas,
    k.id_matakuliah,
    mk.nama_matakuliah,
    d.nama as nama_dosen
FROM sesi_absensi s
LEFT JOIN pertemuan p ON s.id_pertemuan = p.id_pertemuan
LEFT JOIN kelas k ON p.id_kelas = k.id_kelas
LEFT JOIN matakuliah mk ON k.id_matakuliah = mk.id_matakuliah
LEFT JOIN dosen d ON s.nip_dosen = d.nip
WHERE s.id_sesi = 15;

-- 4. List semua sesi aktif
SELECT id_sesi, id_pertemuan, status_sesi, waktu_buka 
FROM sesi_absensi 
WHERE status_sesi = 'aktif'
ORDER BY id_sesi DESC
LIMIT 10;
```

**Yang perlu dicek:**
1. Apakah id_sesi 15 ada di tabel sesi_absensi?
2. Apakah id_pertemuan di sesi tersebut valid?
3. Apakah semua foreign key relationship valid (kelas, matakuliah, dosen)?
4. Apakah ada NULL values di salah satu kolom yang di-JOIN?
