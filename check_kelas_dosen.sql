-- Check kelas_dosen table to see if assignments exist
-- Run this query to see what data is in the kelas_dosen table

SELECT * FROM kelas_dosen ORDER BY id_kelas;

-- Check detailed view with mata kuliah info
SELECT 
    kd.id_kelas_dosen,
    kd.id_kelas,
    k.nama_kelas,
    kd.nip_dosen,
    d.nama as nama_dosen,
    kd.id_matakuliah,
    mk.kode_mk,
    mk.nama_matakuliah,
    kd.ruangan,
    kd.hari,
    kd.jam_mulai,
    kd.jam_selesai
FROM kelas_dosen kd
LEFT JOIN kelas k ON kd.id_kelas = k.id_kelas
LEFT JOIN dosen d ON kd.nip_dosen = d.nip
LEFT JOIN matakuliah mk ON kd.id_matakuliah = mk.id_matakuliah
ORDER BY k.nama_kelas, mk.nama_matakuliah;

-- Check specifically for TI-3E (id_kelas = 4)
SELECT 
    kd.*,
    mk.nama_matakuliah,
    d.nama as nama_dosen
FROM kelas_dosen kd
LEFT JOIN matakuliah mk ON kd.id_matakuliah = mk.id_matakuliah
LEFT JOIN dosen d ON kd.nip_dosen = d.nip
WHERE kd.id_kelas = 4;
