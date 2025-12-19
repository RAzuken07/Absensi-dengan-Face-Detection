-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 19 Des 2025 pada 08.29
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `absensi_pnl`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `absensi`
--

CREATE TABLE `absensi` (
  `id_absensi` int(11) NOT NULL,
  `nim` varchar(20) DEFAULT NULL,
  `id_pertemuan` int(11) DEFAULT NULL,
  `id_sesi` int(11) DEFAULT NULL,
  `status` enum('hadir','izin','sakit','alpha') DEFAULT 'alpha',
  `waktu_absen` datetime DEFAULT NULL,
  `metode` enum('qr_code','face_recognition','manual') DEFAULT NULL,
  `qr_validated` tinyint(1) DEFAULT 0,
  `face_validated` tinyint(1) DEFAULT 0,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `lokasi_lat` decimal(10,8) DEFAULT NULL,
  `lokasi_long` decimal(11,8) DEFAULT NULL,
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `absensi`
--

INSERT INTO `absensi` (`id_absensi`, `nim`, `id_pertemuan`, `id_sesi`, `status`, `waktu_absen`, `metode`, `qr_validated`, `face_validated`, `confidence_score`, `lokasi_lat`, `lokasi_long`, `keterangan`, `created_at`) VALUES
(1, '2023573010085', 1, 1, 'alpha', '2025-12-16 15:27:45', 'manual', 0, 0, 81.21, 5.11692420, 97.16626270, NULL, '2025-12-16 08:27:45');

-- --------------------------------------------------------

--
-- Struktur dari tabel `barcode`
--

CREATE TABLE `barcode` (
  `id_barcode` int(11) NOT NULL,
  `kode_barcode` varchar(255) NOT NULL,
  `id_sesi` int(11) NOT NULL,
  `nip_dosen` varchar(20) NOT NULL,
  `waktu_dibuat` datetime DEFAULT current_timestamp(),
  `waktu_kadaluarsa` datetime DEFAULT NULL,
  `status` enum('aktif','kadaluarsa') DEFAULT 'aktif'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `barcode`
--

INSERT INTO `barcode` (`id_barcode`, `kode_barcode`, `id_sesi`, `nip_dosen`, `waktu_dibuat`, `waktu_kadaluarsa`, `status`) VALUES
(1, '019471', 1, '2023573010001', '2025-12-16 15:25:36', '2025-12-16 16:55:36', 'aktif'),
(2, '026073', 2, '2023573010001', '2025-12-16 15:45:27', '2025-12-16 17:15:27', 'aktif'),
(3, '038902', 3, '2023573010001', '2025-12-16 15:47:44', '2025-12-16 17:17:44', 'aktif');

-- --------------------------------------------------------

--
-- Struktur dari tabel `dosen`
--

CREATE TABLE `dosen` (
  `nip` varchar(20) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `no_hp` varchar(15) DEFAULT NULL,
  `id_prodi` int(11) DEFAULT NULL,
  `id_jurusan` int(11) DEFAULT NULL,
  `foto_wajah` varchar(255) DEFAULT NULL,
  `face_descriptor` text DEFAULT NULL,
  `face_registered` tinyint(1) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `dosen`
--

INSERT INTO `dosen` (`nip`, `nama`, `email`, `no_hp`, `id_prodi`, `id_jurusan`, `foto_wajah`, `face_descriptor`, `face_registered`, `created_at`, `updated_at`) VALUES
('2023573010001', 'prof. hakim, Spb. U', 'hakim01@pnl.ac.id', '08230981237', NULL, NULL, NULL, NULL, NULL, '2025-12-16 08:21:58', '2025-12-16 08:21:58');

--
-- Trigger `dosen`
--
DELIMITER $$
CREATE TRIGGER `tr_after_face_register_dosen` AFTER UPDATE ON `dosen` FOR EACH ROW BEGIN
    IF NEW.face_registered = 1 AND OLD.face_registered = 0 THEN
        INSERT INTO face_scan_log (user_type, user_id, action)
        VALUES ('dosen', NEW.nip, 'register');
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `face_scan_log`
--

CREATE TABLE `face_scan_log` (
  `id_log` int(11) NOT NULL,
  `user_type` enum('dosen','mahasiswa') DEFAULT NULL,
  `user_id` varchar(20) DEFAULT NULL,
  `action` enum('register','verify','failed','update') DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `device_info` varchar(255) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `lokasi_lat` decimal(10,8) DEFAULT NULL,
  `lokasi_long` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `face_scan_log`
--

INSERT INTO `face_scan_log` (`id_log`, `user_type`, `user_id`, `action`, `confidence_score`, `ip_address`, `device_info`, `user_agent`, `lokasi_lat`, `lokasi_long`, `created_at`) VALUES
(1, 'mahasiswa', '2023573010108', 'register', NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-03 09:36:19');

-- --------------------------------------------------------

--
-- Struktur dari tabel `jurusan`
--

CREATE TABLE `jurusan` (
  `id_jurusan` int(11) NOT NULL,
  `nama_jurusan` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `kelas`
--

CREATE TABLE `kelas` (
  `id_kelas` int(11) NOT NULL,
  `nama_kelas` varchar(50) DEFAULT NULL,
  `id_matakuliah` int(11) DEFAULT NULL,
  `tahun_ajaran` varchar(20) DEFAULT NULL,
  `semester` varchar(10) DEFAULT NULL,
  `ruangan` varchar(50) DEFAULT NULL,
  `hari` varchar(20) DEFAULT NULL,
  `jam_mulai` time DEFAULT NULL,
  `jam_selesai` time DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kelas`
--

INSERT INTO `kelas` (`id_kelas`, `nama_kelas`, `id_matakuliah`, `tahun_ajaran`, `semester`, `ruangan`, `hari`, `jam_mulai`, `jam_selesai`, `created_at`) VALUES
(1, 'TI-1A', 1, '2024/2025', '1', 'Lab 1', 'Senin', '08:00:00', '10:00:00', '2025-12-16 08:24:39');

-- --------------------------------------------------------

--
-- Struktur dari tabel `kelas_dosen`
--

CREATE TABLE `kelas_dosen` (
  `id_kelas_dosen` int(11) NOT NULL,
  `id_kelas` int(11) NOT NULL,
  `nip_dosen` varchar(20) NOT NULL,
  `id_matakuliah` int(11) NOT NULL,
  `tahun_ajaran` varchar(20) DEFAULT NULL,
  `semester` varchar(10) DEFAULT NULL,
  `ruangan` varchar(50) DEFAULT NULL,
  `hari` varchar(20) DEFAULT NULL,
  `jam_mulai` time DEFAULT NULL,
  `jam_selesai` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kelas_dosen`
--

INSERT INTO `kelas_dosen` (`id_kelas_dosen`, `id_kelas`, `nip_dosen`, `id_matakuliah`, `tahun_ajaran`, `semester`, `ruangan`, `hari`, `jam_mulai`, `jam_selesai`) VALUES
(1, 1, '2023573010001', 1, NULL, NULL, '200', 'Senin', '00:00:08', '00:00:10');

-- --------------------------------------------------------

--
-- Struktur dari tabel `kelas_matakuliah`
--

CREATE TABLE `kelas_matakuliah` (
  `id_kelas_mk` int(11) NOT NULL,
  `id_kelas` int(11) DEFAULT NULL,
  `id_matakuliah` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `mahasiswa`
--

CREATE TABLE `mahasiswa` (
  `nim` varchar(20) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `no_hp` varchar(15) DEFAULT NULL,
  `id_kelas` int(11) DEFAULT NULL,
  `id_prodi` int(11) DEFAULT NULL,
  `id_jurusan` int(11) DEFAULT NULL,
  `angkatan` varchar(10) DEFAULT NULL,
  `foto_wajah` varchar(255) DEFAULT NULL,
  `face_descriptor` text DEFAULT NULL,
  `face_registered` tinyint(1) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `mahasiswa`
--

INSERT INTO `mahasiswa` (`nim`, `nama`, `email`, `no_hp`, `id_kelas`, `id_prodi`, `id_jurusan`, `angkatan`, `foto_wajah`, `face_descriptor`, `face_registered`, `created_at`, `updated_at`) VALUES
('2023573010085', 'Ichsan Maulana', 'ichsan_maulana085@student.pnl.ac.id', '081379397276', 1, NULL, NULL, '2023', NULL, '[-0.18296293914318085, 0.03706839680671692, -0.024752017110586166, -0.024890106171369553, -0.10241840034723282, 0.033594392240047455, 0.00047404319047927856, -0.01009816862642765, 0.1871914267539978, -0.13295434415340424, 0.1312781572341919, 0.006106718443334103, -0.23022551834583282, -0.08699516206979752, 0.027531322091817856, 0.13502711057662964, -0.2143016904592514, -0.18853940069675446, 0.019955752417445183, 0.0002623423933982849, 0.0851021260023117, -0.012226872146129608, -0.011697662062942982, 0.09677423536777496, -0.1395757794380188, -0.42478710412979126, -0.09524786472320557, -0.1265435665845871, 0.11522728949785233, -0.05151249095797539, -0.053902897983789444, 0.045292481780052185, -0.20139412581920624, -0.03521890193223953, -0.010136143304407597, 0.10047285258769989, -0.0018078847788274288, 0.023346301168203354, 0.19699284434318542, 0.0009290585294365883, -0.2715699076652527, -0.07276760786771774, 0.04967183992266655, 0.31103864312171936, 0.13033610582351685, 0.05505374073982239, 0.01014840230345726, 0.0023124180734157562, 0.05190369486808777, -0.18709057569503784, 0.06292444467544556, 0.1718568354845047, 0.1931304633617401, 0.022149790078401566, 0.023020189255475998, -0.1629268079996109, -0.0017583705484867096, 0.06850166618824005, -0.17065370082855225, 0.07037681341171265, 0.02357337437570095, -0.10528770089149475, 0.036824967712163925, -0.003377674613147974, 0.301199346780777, 0.010612915270030499, -0.1123879998922348, -0.12089865654706955, 0.20545417070388794, -0.16604983806610107, -0.003738139756023884, 0.0182562917470932, -0.12987081706523895, -0.18800757825374603, -0.30965471267700195, 0.043828435242176056, 0.3661375343799591, 0.12791100144386292, -0.12665735185146332, 0.13870865106582642, -0.08854764699935913, -0.04053349047899246, 0.07612932473421097, 0.18589645624160767, -0.08531886339187622, 0.05839435011148453, -0.08491283655166626, 0.04830138757824898, 0.16428466141223907, -0.03528060391545296, 0.01704571396112442, 0.1376800239086151, 0.019300639629364014, 0.0397094301879406, 0.0531902052462101, -0.0015978638548403978, -0.08259911090135574, -0.023177657276391983, -0.12249168753623962, 0.005406682379543781, -0.008540819399058819, -0.09230981022119522, 0.027521776035428047, 0.13057194650173187, -0.17265500128269196, 0.07770998030900955, 0.04208962991833687, -0.04686298593878746, 0.004998629912734032, 0.1090468093752861, -0.1572508066892624, -0.16951946914196014, 0.08977291733026505, -0.2536632716655731, 0.19483396410942078, 0.20911379158496857, 0.018404830247163773, 0.17731276154518127, 0.10076384991407394, 0.09349879622459412, 0.013370953500270844, -0.005998356267809868, -0.16894292831420898, -0.011502448469400406, 0.12373611330986023, -0.07125750184059143, 0.06418866664171219, 0.02811325341463089]', 1, '2025-12-16 08:23:21', '2025-12-16 08:27:10');

--
-- Trigger `mahasiswa`
--
DELIMITER $$
CREATE TRIGGER `tr_after_face_register_mahasiswa` AFTER UPDATE ON `mahasiswa` FOR EACH ROW BEGIN
    IF NEW.face_registered = 1 AND OLD.face_registered = 0 THEN
        INSERT INTO face_scan_log (user_type, user_id, action)
        VALUES ('mahasiswa', NEW.nim, 'register');
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `matakuliah`
--

CREATE TABLE `matakuliah` (
  `id_matakuliah` int(11) NOT NULL,
  `kode_mk` varchar(20) DEFAULT NULL,
  `nama_matakuliah` varchar(100) DEFAULT NULL,
  `sks` int(11) DEFAULT NULL,
  `semester` int(11) DEFAULT NULL,
  `nip_dosen` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `matakuliah`
--

INSERT INTO `matakuliah` (`id_matakuliah`, `kode_mk`, `nama_matakuliah`, `sks`, `semester`, `nip_dosen`, `created_at`) VALUES
(1, 'TI01', 'Pemrograman Web Dasar', 2, 1, NULL, '2025-12-16 08:24:00');

-- --------------------------------------------------------

--
-- Struktur dari tabel `notifikasi`
--

CREATE TABLE `notifikasi` (
  `id_notif` int(11) NOT NULL,
  `user_type` enum('dosen','mahasiswa','admin') NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `judul` varchar(255) NOT NULL,
  `pesan` text NOT NULL,
  `tipe` enum('info','warning','success','error') DEFAULT 'info',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `notifikasi`
--

INSERT INTO `notifikasi` (`id_notif`, `user_type`, `user_id`, `judul`, `pesan`, `tipe`, `is_read`, `created_at`) VALUES
(1, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-3 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-06 20:54:18'),
(2, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-36 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 14:44:07'),
(3, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-36 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 14:44:07'),
(5, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-37 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 14:44:49'),
(6, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-37 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 14:44:49'),
(8, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-1 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 14:48:41'),
(9, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-1 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 14:48:41'),
(11, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-2 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 14:51:09'),
(12, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-2 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 14:51:09'),
(14, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-3 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 15:04:35'),
(15, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-3 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 15:04:35'),
(17, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-4 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 15:09:46'),
(18, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-4 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 15:09:46'),
(20, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-5 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 15:15:38'),
(21, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-5 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 15:15:38'),
(23, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-6 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 15:18:27'),
(24, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-6 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 15:18:27'),
(26, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-7 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 17:20:41'),
(27, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-7 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 17:20:41'),
(28, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-8 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 17:36:31'),
(29, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-8 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 17:36:31'),
(31, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-9 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 18:04:53'),
(32, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-9 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 18:04:53'),
(34, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-10 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 18:37:19'),
(35, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-10 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-07 18:37:19'),
(36, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-11 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-09 14:31:25'),
(37, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-11 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-09 14:31:25'),
(39, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-12 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-09 15:04:36'),
(40, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-12 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-09 15:04:36'),
(41, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-13 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-10 14:04:27'),
(42, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-13 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-10 14:04:27'),
(43, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-14 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-16 06:39:22'),
(44, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-14 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-16 06:39:22'),
(46, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-15 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-16 06:56:32'),
(47, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-15 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-16 06:56:32'),
(49, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-16 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-16 07:19:15'),
(50, 'mahasiswa', '2023573010108', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-16 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-16 07:19:15'),
(52, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-2 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-16 08:45:27'),
(53, 'mahasiswa', '2023573010085', 'Sesi Absensi Dibuka', 'Sesi absensi untuk pertemuan ke-3 telah dibuka. Segera lakukan absensi!', 'info', 0, '2025-12-16 08:47:44');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pertemuan`
--

CREATE TABLE `pertemuan` (
  `id_pertemuan` int(11) NOT NULL,
  `id_kelas` int(11) DEFAULT NULL,
  `pertemuan_ke` int(11) DEFAULT NULL,
  `tanggal` date DEFAULT NULL,
  `topik` varchar(255) DEFAULT NULL,
  `deskripsi` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pertemuan`
--

INSERT INTO `pertemuan` (`id_pertemuan`, `id_kelas`, `pertemuan_ke`, `tanggal`, `topik`, `deskripsi`, `created_at`) VALUES
(1, 1, 1, '2025-12-16', 'Pertemuan ke-1', NULL, '2025-12-16 08:25:36'),
(2, 1, 2, '2025-12-16', 'Pertemuan ke-2', NULL, '2025-12-16 08:45:27'),
(3, 1, 3, '2025-12-16', 'Pertemuan ke-3', NULL, '2025-12-16 08:47:44');

-- --------------------------------------------------------

--
-- Struktur dari tabel `prodi`
--

CREATE TABLE `prodi` (
  `id_prodi` int(11) NOT NULL,
  `nama_prodi` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `sesi_absensi`
--

CREATE TABLE `sesi_absensi` (
  `id_sesi` int(11) NOT NULL,
  `id_pertemuan` int(11) DEFAULT NULL,
  `nip_dosen` varchar(20) DEFAULT NULL,
  `waktu_buka` datetime DEFAULT NULL,
  `waktu_tutup` datetime DEFAULT NULL,
  `status_sesi` enum('aktif','selesai') DEFAULT NULL,
  `durasi_menit` int(11) DEFAULT NULL,
  `lokasi_lat` decimal(10,8) DEFAULT NULL,
  `lokasi_long` decimal(11,8) DEFAULT NULL,
  `radius_meter` int(11) DEFAULT NULL,
  `kode_sesi` varchar(10) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `sesi_absensi`
--

INSERT INTO `sesi_absensi` (`id_sesi`, `id_pertemuan`, `nip_dosen`, `waktu_buka`, `waktu_tutup`, `status_sesi`, `durasi_menit`, `lokasi_lat`, `lokasi_long`, `radius_meter`, `kode_sesi`, `created_at`) VALUES
(1, 1, '2023573010001', '2025-12-16 15:25:36', NULL, 'aktif', 90, 5.11922000, 97.15678000, 0, '019471', '2025-12-16 08:25:36'),
(2, 2, '2023573010001', '2025-12-16 15:45:27', NULL, 'aktif', 90, 5.11922000, 97.15678000, 0, '026073', '2025-12-16 08:45:27'),
(3, 3, '2023573010001', '2025-12-16 15:47:44', NULL, 'aktif', 90, 5.11922000, 97.15678000, 0, '038902', '2025-12-16 08:47:44');

--
-- Trigger `sesi_absensi`
--
DELIMITER $$
CREATE TRIGGER `tr_after_sesi_opened` AFTER INSERT ON `sesi_absensi` FOR EACH ROW BEGIN
    INSERT INTO notifikasi (user_type, user_id, judul, pesan, tipe)
    SELECT 
        'mahasiswa',
        m.nim,
        'Sesi Absensi Dibuka',
        CONCAT('Sesi absensi untuk pertemuan ke-', p.pertemuan_ke, ' telah dibuka. Segera lakukan absensi!'),
        'info'
    FROM mahasiswa m
    JOIN pertemuan p ON NEW.id_pertemuan = p.id_pertemuan
    WHERE m.id_kelas = p.id_kelas;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id_user` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `level` enum('admin','dosen','mahasiswa') NOT NULL,
  `nim` varchar(20) DEFAULT NULL,
  `nip` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id_user`, `username`, `password`, `nama`, `level`, `nim`, `nip`, `created_at`) VALUES
(1, 'admin', '123456', 'Administrator', 'admin', NULL, NULL, '2025-11-23 16:58:42'),
(11, '2023573010001', '$2b$12$nvL/7CZmyScdgKyZN9E0vO17iBLpNW9MV5/FaygyuD1ipXBSaDlKm', 'prof. hakim, Spb. U', 'dosen', NULL, '2023573010001', '2025-12-16 08:21:59'),
(12, '2023573010085', '$2b$12$c6ATiBwI0nYQ4bLNdGaU6u89L9vFn3ZICyWmPfxYrNCBtG8GxuSHC', 'Ichsan Maulana', 'mahasiswa', '2023573010085', NULL, '2025-12-16 08:23:22');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_rekap_kehadiran`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_rekap_kehadiran` (
`nim` varchar(20)
,`nama` varchar(100)
,`nama_kelas` varchar(50)
,`nama_matakuliah` varchar(100)
,`total_pertemuan` bigint(21)
,`total_kehadiran` bigint(21)
,`hadir` decimal(22,0)
,`izin` decimal(22,0)
,`sakit` decimal(22,0)
,`alpha` decimal(22,0)
,`persentase_kehadiran` decimal(28,2)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_sesi_aktif`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_sesi_aktif` (
`id_sesi` int(11)
,`id_pertemuan` int(11)
,`nip_dosen` varchar(20)
,`waktu_buka` datetime
,`waktu_tutup` datetime
,`status_sesi` enum('aktif','selesai')
,`durasi_menit` int(11)
,`lokasi_lat` decimal(10,8)
,`lokasi_long` decimal(11,8)
,`radius_meter` int(11)
,`kode_sesi` varchar(10)
,`created_at` timestamp
,`pertemuan_ke` int(11)
,`tanggal` date
,`topik` varchar(255)
,`nama_kelas` varchar(50)
,`nama_matakuliah` varchar(100)
,`nama_dosen` varchar(100)
,`menit_berjalan` bigint(21)
,`sisa_menit` bigint(22)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `v_rekap_kehadiran`
--
DROP TABLE IF EXISTS `v_rekap_kehadiran`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_rekap_kehadiran`  AS SELECT `m`.`nim` AS `nim`, `m`.`nama` AS `nama`, `k`.`nama_kelas` AS `nama_kelas`, `mk`.`nama_matakuliah` AS `nama_matakuliah`, count(`p`.`id_pertemuan`) AS `total_pertemuan`, count(`a`.`id_absensi`) AS `total_kehadiran`, sum(case when `a`.`status` = 'hadir' then 1 else 0 end) AS `hadir`, sum(case when `a`.`status` = 'izin' then 1 else 0 end) AS `izin`, sum(case when `a`.`status` = 'sakit' then 1 else 0 end) AS `sakit`, sum(case when `a`.`status` = 'alpha' then 1 else 0 end) AS `alpha`, round(sum(case when `a`.`status` = 'hadir' then 1 else 0 end) / count(`p`.`id_pertemuan`) * 100,2) AS `persentase_kehadiran` FROM ((((`mahasiswa` `m` join `kelas` `k` on(`m`.`id_kelas` = `k`.`id_kelas`)) join `matakuliah` `mk` on(`k`.`id_matakuliah` = `mk`.`id_matakuliah`)) left join `pertemuan` `p` on(`k`.`id_kelas` = `p`.`id_kelas`)) left join `absensi` `a` on(`p`.`id_pertemuan` = `a`.`id_pertemuan` and `a`.`nim` = `m`.`nim`)) GROUP BY `m`.`nim` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_sesi_aktif`
--
DROP TABLE IF EXISTS `v_sesi_aktif`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_sesi_aktif`  AS SELECT `s`.`id_sesi` AS `id_sesi`, `s`.`id_pertemuan` AS `id_pertemuan`, `s`.`nip_dosen` AS `nip_dosen`, `s`.`waktu_buka` AS `waktu_buka`, `s`.`waktu_tutup` AS `waktu_tutup`, `s`.`status_sesi` AS `status_sesi`, `s`.`durasi_menit` AS `durasi_menit`, `s`.`lokasi_lat` AS `lokasi_lat`, `s`.`lokasi_long` AS `lokasi_long`, `s`.`radius_meter` AS `radius_meter`, `s`.`kode_sesi` AS `kode_sesi`, `s`.`created_at` AS `created_at`, `p`.`pertemuan_ke` AS `pertemuan_ke`, `p`.`tanggal` AS `tanggal`, `p`.`topik` AS `topik`, `k`.`nama_kelas` AS `nama_kelas`, `mk`.`nama_matakuliah` AS `nama_matakuliah`, `d`.`nama` AS `nama_dosen`, timestampdiff(MINUTE,`s`.`waktu_buka`,current_timestamp()) AS `menit_berjalan`, `s`.`durasi_menit`- timestampdiff(MINUTE,`s`.`waktu_buka`,current_timestamp()) AS `sisa_menit` FROM ((((`sesi_absensi` `s` join `pertemuan` `p` on(`s`.`id_pertemuan` = `p`.`id_pertemuan`)) join `kelas` `k` on(`p`.`id_kelas` = `k`.`id_kelas`)) join `matakuliah` `mk` on(`k`.`id_matakuliah` = `mk`.`id_matakuliah`)) join `dosen` `d` on(`s`.`nip_dosen` = `d`.`nip`)) WHERE `s`.`status_sesi` = 'aktif' AND timestampdiff(MINUTE,`s`.`waktu_buka`,current_timestamp()) <= `s`.`durasi_menit` ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `absensi`
--
ALTER TABLE `absensi`
  ADD PRIMARY KEY (`id_absensi`),
  ADD KEY `nim` (`nim`),
  ADD KEY `id_pertemuan` (`id_pertemuan`),
  ADD KEY `id_sesi` (`id_sesi`);

--
-- Indeks untuk tabel `barcode`
--
ALTER TABLE `barcode`
  ADD PRIMARY KEY (`id_barcode`),
  ADD KEY `fk_barcode_sesi` (`id_sesi`),
  ADD KEY `fk_barcode_dosen` (`nip_dosen`);

--
-- Indeks untuk tabel `dosen`
--
ALTER TABLE `dosen`
  ADD PRIMARY KEY (`nip`),
  ADD KEY `id_prodi` (`id_prodi`),
  ADD KEY `id_jurusan` (`id_jurusan`);

--
-- Indeks untuk tabel `face_scan_log`
--
ALTER TABLE `face_scan_log`
  ADD PRIMARY KEY (`id_log`);

--
-- Indeks untuk tabel `jurusan`
--
ALTER TABLE `jurusan`
  ADD PRIMARY KEY (`id_jurusan`);

--
-- Indeks untuk tabel `kelas`
--
ALTER TABLE `kelas`
  ADD PRIMARY KEY (`id_kelas`);

--
-- Indeks untuk tabel `kelas_dosen`
--
ALTER TABLE `kelas_dosen`
  ADD PRIMARY KEY (`id_kelas_dosen`),
  ADD KEY `id_kelas` (`id_kelas`),
  ADD KEY `nip_dosen` (`nip_dosen`);

--
-- Indeks untuk tabel `kelas_matakuliah`
--
ALTER TABLE `kelas_matakuliah`
  ADD PRIMARY KEY (`id_kelas_mk`),
  ADD KEY `id_kelas` (`id_kelas`),
  ADD KEY `id_matakuliah` (`id_matakuliah`);

--
-- Indeks untuk tabel `mahasiswa`
--
ALTER TABLE `mahasiswa`
  ADD PRIMARY KEY (`nim`),
  ADD KEY `id_kelas` (`id_kelas`),
  ADD KEY `id_prodi` (`id_prodi`),
  ADD KEY `id_jurusan` (`id_jurusan`);

--
-- Indeks untuk tabel `matakuliah`
--
ALTER TABLE `matakuliah`
  ADD PRIMARY KEY (`id_matakuliah`),
  ADD KEY `nip_dosen` (`nip_dosen`);

--
-- Indeks untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`id_notif`);

--
-- Indeks untuk tabel `pertemuan`
--
ALTER TABLE `pertemuan`
  ADD PRIMARY KEY (`id_pertemuan`),
  ADD KEY `id_kelas` (`id_kelas`);

--
-- Indeks untuk tabel `prodi`
--
ALTER TABLE `prodi`
  ADD PRIMARY KEY (`id_prodi`);

--
-- Indeks untuk tabel `sesi_absensi`
--
ALTER TABLE `sesi_absensi`
  ADD PRIMARY KEY (`id_sesi`),
  ADD KEY `id_pertemuan` (`id_pertemuan`),
  ADD KEY `nip_dosen` (`nip_dosen`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `absensi`
--
ALTER TABLE `absensi`
  MODIFY `id_absensi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `barcode`
--
ALTER TABLE `barcode`
  MODIFY `id_barcode` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `face_scan_log`
--
ALTER TABLE `face_scan_log`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `jurusan`
--
ALTER TABLE `jurusan`
  MODIFY `id_jurusan` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `kelas`
--
ALTER TABLE `kelas`
  MODIFY `id_kelas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `kelas_dosen`
--
ALTER TABLE `kelas_dosen`
  MODIFY `id_kelas_dosen` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `kelas_matakuliah`
--
ALTER TABLE `kelas_matakuliah`
  MODIFY `id_kelas_mk` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `matakuliah`
--
ALTER TABLE `matakuliah`
  MODIFY `id_matakuliah` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `id_notif` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT untuk tabel `pertemuan`
--
ALTER TABLE `pertemuan`
  MODIFY `id_pertemuan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `prodi`
--
ALTER TABLE `prodi`
  MODIFY `id_prodi` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `sesi_absensi`
--
ALTER TABLE `sesi_absensi`
  MODIFY `id_sesi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `absensi`
--
ALTER TABLE `absensi`
  ADD CONSTRAINT `absensi_ibfk_1` FOREIGN KEY (`nim`) REFERENCES `mahasiswa` (`nim`),
  ADD CONSTRAINT `absensi_ibfk_2` FOREIGN KEY (`id_pertemuan`) REFERENCES `pertemuan` (`id_pertemuan`),
  ADD CONSTRAINT `absensi_ibfk_3` FOREIGN KEY (`id_sesi`) REFERENCES `sesi_absensi` (`id_sesi`);

--
-- Ketidakleluasaan untuk tabel `dosen`
--
ALTER TABLE `dosen`
  ADD CONSTRAINT `dosen_ibfk_1` FOREIGN KEY (`id_prodi`) REFERENCES `prodi` (`id_prodi`),
  ADD CONSTRAINT `dosen_ibfk_2` FOREIGN KEY (`id_jurusan`) REFERENCES `jurusan` (`id_jurusan`);

--
-- Ketidakleluasaan untuk tabel `kelas_matakuliah`
--
ALTER TABLE `kelas_matakuliah`
  ADD CONSTRAINT `kelas_matakuliah_ibfk_1` FOREIGN KEY (`id_kelas`) REFERENCES `kelas` (`id_kelas`),
  ADD CONSTRAINT `kelas_matakuliah_ibfk_2` FOREIGN KEY (`id_matakuliah`) REFERENCES `matakuliah` (`id_matakuliah`);

--
-- Ketidakleluasaan untuk tabel `mahasiswa`
--
ALTER TABLE `mahasiswa`
  ADD CONSTRAINT `mahasiswa_ibfk_1` FOREIGN KEY (`id_kelas`) REFERENCES `kelas` (`id_kelas`),
  ADD CONSTRAINT `mahasiswa_ibfk_2` FOREIGN KEY (`id_prodi`) REFERENCES `prodi` (`id_prodi`),
  ADD CONSTRAINT `mahasiswa_ibfk_3` FOREIGN KEY (`id_jurusan`) REFERENCES `jurusan` (`id_jurusan`);

--
-- Ketidakleluasaan untuk tabel `matakuliah`
--
ALTER TABLE `matakuliah`
  ADD CONSTRAINT `matakuliah_ibfk_1` FOREIGN KEY (`nip_dosen`) REFERENCES `dosen` (`nip`);

--
-- Ketidakleluasaan untuk tabel `pertemuan`
--
ALTER TABLE `pertemuan`
  ADD CONSTRAINT `pertemuan_ibfk_1` FOREIGN KEY (`id_kelas`) REFERENCES `kelas` (`id_kelas`);

--
-- Ketidakleluasaan untuk tabel `sesi_absensi`
--
ALTER TABLE `sesi_absensi`
  ADD CONSTRAINT `sesi_absensi_ibfk_1` FOREIGN KEY (`id_pertemuan`) REFERENCES `pertemuan` (`id_pertemuan`),
  ADD CONSTRAINT `sesi_absensi_ibfk_2` FOREIGN KEY (`nip_dosen`) REFERENCES `dosen` (`nip`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
