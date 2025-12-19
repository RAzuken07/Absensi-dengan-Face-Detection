import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_service.dart';
import '../../models/kelas_model.dart';
import '../../models/dosen_model.dart';
import '../../models/matakuliah_model.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_card.dart';
import '../../config/app_colors.dart';

class KelasAssignmentScreen extends ConsumerStatefulWidget {
  const KelasAssignmentScreen({super.key});

  @override
  ConsumerState<KelasAssignmentScreen> createState() =>
      _KelasAssignmentScreenState();
}

class _KelasAssignmentScreenState extends ConsumerState<KelasAssignmentScreen> {
  final AdminService _adminService = AdminService();

  List<KelasModel> _kelasList = [];
  List<Map<String, dynamic>> _assignments = [];
  List<DosenModel> _dosenList = [];
  List<MataKuliahModel> _matakuliahList = [];

  int? _selectedKelasId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final kelas = await _adminService.getAllKelas();
      final dosen = await _adminService.getAllDosen();
      final mk = await _adminService.getAllMataKuliah();

      setState(() {
        _kelasList = kelas;
        _dosenList = dosen;
        _matakuliahList = mk;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Gagal memuat data: $e');
    }
  }

  Future<void> _loadAssignments(int idKelas) async {
    print('[_loadAssignments] START - Loading assignments for kelas $idKelas');
    setState(() => _isLoading = true);
    try {
      // 1) coba endpoint per-kelas dulu
      print('[_loadAssignments] Step 1: Calling getKelasAssignments');
      var assignments = await _adminService.getKelasAssignments(idKelas);
      print('[_loadAssignments] Step 1 Result: ${assignments.length} assignments');
      if (assignments.isNotEmpty) {
        print('[_loadAssignments] Step 1 First assignment: ${assignments[0]}');
      }

      // 2) fallback: jika kosong, ambil semua dan filter secara lokal
      if (assignments.isEmpty) {
        print('[_loadAssignments] Step 2: Fallback - Getting all kelas_dosen assignments');
        final all = await _adminService.getAllKelasDosen();
        print('[_loadAssignments] Step 2: Got ${all.length} total assignments');
        
        assignments = all
            .where((m) {
              final id = m['id_kelas'] ?? m['idKelas'] ?? m['idKelas'];
              final parsed = id is int
                  ? id
                  : int.tryParse(id?.toString() ?? '');
              final matches = parsed == idKelas;
              if (matches) {
                print('[_loadAssignments] Step 2: Found matching assignment: $m');
              }
              return matches;
            })
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        print('[_loadAssignments] Step 2 Result: ${assignments.length} filtered assignments');
      }

      // 3) enrich items using local _matakuliahList if needed
      print('[_loadAssignments] Step 3: Enriching ${assignments.length} assignments');
      print('[_loadAssignments] Step 3: Available matakuliah count: ${_matakuliahList.length}');
      
      final mkById = {for (var mk in _matakuliahList) mk.idMatakuliah: mk};
      final enriched = assignments.map((item) {
        final map = Map<String, dynamic>.from(item);
        // ensure id_matakuliah field name possibilities
        final rawId =
            map['id_matakuliah'] ??
            map['id_mk'] ??
            map['idMk'] ??
            map['id_matakuliah'];
        final idMk = rawId is int
            ? rawId
            : int.tryParse(rawId?.toString() ?? '');
        if ((map['nama_mk'] == null || map['nama_mk'] == '') &&
            idMk != null &&
            mkById.containsKey(idMk)) {
          final mk = mkById[idMk]!;
          map['nama_mk'] = mk.namaMatakuliah;
          map['kode_mk'] = mk.kodeMk;
          map['sks'] = mk.sks;
          print('[_loadAssignments] Step 3: Enriched with MK data: ${mk.namaMatakuliah}');
        }
        // normalize dosen name if missing
        map['nama_dosen'] =
            map['nama_dosen'] ??
            map['nama_dosen'] ??
            map['namaDosen'] ??
            map['dosen'] ??
            '';
        // normalize id_kelas_dosen
        map['id_kelas_dosen'] =
            map['id_kelas_dosen'] ??
            map['id_kelas_dosen'] ??
            map['id'] ??
            map['id_kelas_mk'];
        return map;
      }).toList();

      print('[_loadAssignments] Step 3 Result: ${enriched.length} enriched assignments');
      if (enriched.isNotEmpty) {
        print('[_loadAssignments] Step 3 First enriched: ${enriched[0]}');
      }

      setState(() {
        _assignments = enriched;
        _isLoading = false;
      });
      
      print('[_loadAssignments] COMPLETE - Set ${_assignments.length} assignments to state');
    } catch (e, st) {
      setState(() => _isLoading = false);
      _showError('Gagal memuat jadwal: $e');
      print('[_loadAssignments] ERROR: $e\n$st');
    }
  }

  Future<void> _showAddDialog() async {
    String? selectedNip;
    int? selectedMkId;
    String? selectedHari;
    final ruanganController = TextEditingController();
    final jamMulaiController = TextEditingController();
    final jamSelesaiController = TextEditingController();

    final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Jadwal Mata Kuliah'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pilih Dosen
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Dosen',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: selectedNip,
                      items: _dosenList.map<DropdownMenuItem<String>>((
                        DosenModel dosen,
                      ) {
                        return DropdownMenuItem<String>(
                          value: dosen.nip,
                          child: Text(dosen.nama),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedNip = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Pilih Mata Kuliah
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Mata Kuliah',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: selectedMkId,
                      items: _matakuliahList.map<DropdownMenuItem<int>>((
                        MataKuliahModel mk,
                      ) {
                        return DropdownMenuItem<int>(
                          value: mk.idMatakuliah,
                          child: Text('${mk.kodeMk} - ${mk.namaMatakuliah}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedMkId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Ruangan
                    TextField(
                      controller: ruanganController,
                      decoration: const InputDecoration(
                        labelText: 'Ruangan',
                        hintText: 'e.g., Lab 301',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Hari
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Hari',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: selectedHari,
                      items: hariList.map((hari) {
                        return DropdownMenuItem(value: hari, child: Text(hari));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedHari = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Jam Mulai
                    TextField(
                      controller: jamMulaiController,
                      decoration: const InputDecoration(
                        labelText: 'Jam Mulai',
                        hintText: 'e.g., 08:00',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Jam Selesai
                    TextField(
                      controller: jamSelesaiController,
                      decoration: const InputDecoration(
                        labelText: 'Jam Selesai',
                        hintText: 'e.g., 10:30',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: selectedNip != null && selectedMkId != null
                      ? () async {
                          Navigator.pop(context);
                          await _addAssignment(
                            selectedNip!,
                            selectedMkId!,
                            ruanganController.text,
                            selectedHari,
                            jamMulaiController.text,
                            jamSelesaiController.text,
                          );
                        }
                      : null,
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addAssignment(
    String nip,
    int idMatakuliah,
    String? ruangan,
    String? hari,
    String? jamMulai,
    String? jamSelesai,
  ) async {
    if (_selectedKelasId == null) {
      _showError('Pilih kelas terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _adminService.assignDosenMatakuliah(
        _selectedKelasId!,
        nip,
        idMatakuliah,
        ruangan: ruangan,
        hari: hari,
        jamMulai: jamMulai,
        jamSelesai: jamSelesai,
      );

      if (result['success'] == true) {
        _showSuccess(
          result['message'] ?? 'Jadwal mata kuliah berhasil ditambahkan',
        );
        await _loadAssignments(_selectedKelasId!);
      } else {
        final errorMsg = result['message'] ?? 'Gagal menambahkan jadwal';
        _showError(errorMsg);
        print('Add assignment failed: $result');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
      print('Exception in _addAssignment: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeAssignment(int idKelasDosen) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Hapus mata kuliah ini dari kelas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _adminService.removeKelasDosen(idKelasDosen);
        if (success) {
          _showSuccess('Mata kuliah berhasil dihapus');
          await _loadAssignments(_selectedKelasId!);
        }
      } catch (e) {
        _showError('Gagal menghapus: $e');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Kelola Jadwal Kelas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: Column(
          children: [
            // Kelas Selector
            Container(
              padding: const EdgeInsets.all(16),
              child: ModernCard(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Pilih Kelas',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  initialValue: _selectedKelasId,
                  items: _kelasList.map<DropdownMenuItem<int>>((
                    KelasModel kelas,
                  ) {
                    return DropdownMenuItem<int>(
                      value: kelas.idKelas,
                      child: Text(kelas.namaKelas),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedKelasId = value);
                      _loadAssignments(value);
                    }
                  },
                ),
              ),
            ),

            // Assignments List
            if (_selectedKelasId != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mata Kuliah yang Dikelola:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add_circle, color: Colors.white),
                      iconSize: 32,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _assignments.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada mata kuliah',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _assignments.length,
                        itemBuilder: (context, index) {
                          final assignment = _assignments[index];
                          return _buildAssignmentCard(assignment);
                        },
                      ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Text(
                    'Pilih kelas untuk mengelola jadwal',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    // Resolve fallback values
    final rawId =
        assignment['id_matakuliah'] ??
        assignment['id_mk'] ??
        assignment['idMk'];
    final idMk = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final mkFound = _findMatakuliahById(idMk);
    final namaMk =
        assignment['nama_mk'] ??
        (mkFound != null ? mkFound.namaMatakuliah : 'Mata Kuliah');
    final kodeMk =
        assignment['kode_mk'] ?? (mkFound != null ? mkFound.kodeMk : '-');
    final sks = assignment['sks'] ?? (mkFound?.sks ?? 0);

    final namaDosen =
        assignment['nama_dosen'] ??
        assignment['namaDosen'] ??
        assignment['dosen'] ??
        '-';
    final ruangan = assignment['ruangan'] ?? '-';
    final hari = assignment['hari'] ?? '-';
    final jamMulai = assignment['jam_mulai'] ?? '';
    final jamSelesai = assignment['jam_selesai'] ?? '';
    final waktu =
        (jamMulai.isNotEmpty ? jamMulai : '') +
        (jamMulai.isNotEmpty && jamSelesai.isNotEmpty ? ' - ' : '') +
        (jamSelesai.isNotEmpty ? jamSelesai : '');

    // Avatar text
    String avatarText = kodeMk != '-' && kodeMk.isNotEmpty
        ? kodeMk
        : namaMk.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join();

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF0B6477),
              child: Text(
                avatarText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaMk,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        kodeMk,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $sks SKS',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Dosen: $namaDosen',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (ruangan.isNotEmpty && ruangan != '-') ...[
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ruangan,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (hari != null && hari != '-') ...[
                        const Icon(
                          Icons.event,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hari,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (waktu.isNotEmpty) ...[
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          waktu,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeAssignment(
                assignment['id_kelas_dosen'] ?? assignment['id'],
              ),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Hapus',
            ),
          ],
        ),
      ),
    );
  }

  MataKuliahModel? _findMatakuliahById(int? id) {
    if (id == null) return null;
    for (final m in _matakuliahList) {
      if (m.idMatakuliah == id) return m;
    }
    return null;
  }
}
