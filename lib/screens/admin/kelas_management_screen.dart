import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../models/kelas_model.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_card.dart';
import '../../config/app_colors.dart';

class KelasManagementScreen extends ConsumerWidget {
  const KelasManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kelasList = ref.watch(kelasListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Management Kelas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showKelasForm(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kelas'),
        backgroundColor: AppColors.primary,
      ),
      body: GradientBackground(
        child: kelasList.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.white70),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(kelasListProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
          data: (kelasList) {
            if (kelasList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.class_outlined,
                      size: 80,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada data kelas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap tombol + untuk menambah kelas',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kelasList.length,
              itemBuilder: (context, index) {
                final kelas = kelasList[index];
                return ModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.class_,
                            size: 32,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Kelas Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kelas.namaKelas,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (kelas.tahunAjaran != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        kelas.tahunAjaran!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  if (kelas.semester != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Semester ${kelas.semester}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Popup Menu Button
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showKelasForm(context, ref, kelas);
                            } else if (value == 'delete') {
                              _confirmDelete(context, ref, kelas);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showKelasForm(
      BuildContext context, WidgetRef ref, KelasModel? kelas) {
    final namaKelasController =
        TextEditingController(text: kelas?.namaKelas ?? '');
    final tahunAjaranController =
        TextEditingController(text: kelas?.tahunAjaran ?? '');
    final semesterController =
        TextEditingController(text: kelas?.semester?.toString() ?? '');
    final ruanganController =
        TextEditingController(text: kelas?.ruangan ?? '');
    
    String? selectedHari = kelas?.hari;
    TimeOfDay? jamMulai;
    TimeOfDay? jamSelesai;
    
    // Parse existing jam if available
    if (kelas?.jamMulai != null) {
      final parts = kelas!.jamMulai!.split(':');
      if (parts.length >= 2) {
        jamMulai = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    if (kelas?.jamSelesai != null) {
      final parts = kelas!.jamSelesai!.split(':');
      if (parts.length >= 2) {
        jamSelesai = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            kelas == null ? 'Tambah Kelas' : 'Edit Kelas',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Kelas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: namaKelasController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kelas',
                      hintText: 'Contoh: TIF-3A',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.class_),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Nama kelas wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: tahunAjaranController,
                    decoration: const InputDecoration(
                      labelText: 'Tahun Ajaran',
                      hintText: 'Contoh: 2024/2025',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: semesterController,
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      hintText: 'Contoh: 1',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Jadwal Kelas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Dropdown Hari
                  DropdownButtonFormField<String>(
                    value: selectedHari,
                    decoration: const InputDecoration(
                      labelText: 'Hari',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Senin', child: Text('Senin')),
                      DropdownMenuItem(value: 'Selasa', child: Text('Selasa')),
                      DropdownMenuItem(value: 'Rabu', child: Text('Rabu')),
                      DropdownMenuItem(value: 'Kamis', child: Text('Kamis')),
                      DropdownMenuItem(value: 'Jumat', child: Text('Jumat')),
                      DropdownMenuItem(value: 'Sabtu', child: Text('Sabtu')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedHari = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Jam Mulai
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: jamMulai ?? const TimeOfDay(hour: 8, minute: 0),
                      );
                      if (picked != null) {
                        setState(() {
                          jamMulai = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Jam Mulai',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        jamMulai != null 
                            ? '${jamMulai!.hour.toString().padLeft(2, '0')}:${jamMulai!.minute.toString().padLeft(2, '0')}'
                            : 'Pilih jam mulai',
                        style: TextStyle(
                          color: jamMulai != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Jam Selesai
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: jamSelesai ?? const TimeOfDay(hour: 10, minute: 0),
                      );
                      if (picked != null) {
                        setState(() {
                          jamSelesai = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Jam Selesai',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time_filled),
                      ),
                      child: Text(
                        jamSelesai != null 
                            ? '${jamSelesai!.hour.toString().padLeft(2, '0')}:${jamSelesai!.minute.toString().padLeft(2, '0')}'
                            : 'Pilih jam selesai',
                        style: TextStyle(
                          color: jamSelesai != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Ruangan
                  TextFormField(
                    controller: ruanganController,
                    decoration: const InputDecoration(
                      labelText: 'Ruangan',
                      hintText: 'Contoh: Lab 1',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                  ),
                ],
              ),
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Parse semester - handle both numeric and text input
                int? semesterValue;
                final semesterText = semesterController.text.trim();
                if (semesterText.isNotEmpty) {
                  // Try to parse as integer first
                  semesterValue = int.tryParse(semesterText);
                  // If not a number, convert text to number
                  if (semesterValue == null) {
                    if (semesterText.toLowerCase().contains('ganjil') || 
                        semesterText.toLowerCase() == 'i' ||
                        semesterText == '1') {
                      semesterValue = 1;
                    } else if (semesterText.toLowerCase().contains('genap') ||
                               semesterText.toLowerCase() == 'ii' ||
                               semesterText == '2') {
                      semesterValue = 2;
                    }
                  }
                }

                // Format jam ke HH:MM:SS untuk database
                String? jamMulaiStr;
                String? jamSelesaiStr;
                
                if (jamMulai != null) {
                  jamMulaiStr = '${jamMulai!.hour.toString().padLeft(2, '0')}:${jamMulai!.minute.toString().padLeft(2, '0')}:00';
                }
                if (jamSelesai != null) {
                  jamSelesaiStr = '${jamSelesai!.hour.toString().padLeft(2, '0')}:${jamSelesai!.minute.toString().padLeft(2, '0')}:00';
                }

                final data = {
                  'nama_kelas': namaKelasController.text.trim(),
                  'tahun_ajaran': tahunAjaranController.text.isNotEmpty
                      ? tahunAjaranController.text.trim()
                      : null,
                  'semester': semesterValue,
                  'hari': selectedHari,
                  'jam_mulai': jamMulaiStr,
                  'jam_selesai': jamSelesaiStr,
                  'ruangan': ruanganController.text.isNotEmpty
                      ? ruanganController.text.trim()
                      : null,
                };

                print('[KelasManagement] Saving kelas with data: $data');
                print('[KelasManagement] Is edit mode: ${kelas != null}');
                if (kelas != null) {
                  print('[KelasManagement] Editing kelas ID: ${kelas.idKelas}');
                }

                bool success;
                if (kelas == null) {
                  success = await ref
                      .read(kelasListProvider.notifier)
                      .createKelas(data);
                } else {
                  success = await ref
                      .read(kelasListProvider.notifier)
                      .updateKelas(kelas.idKelas, data);
                }

                print('[KelasManagement] Save result: $success');

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Berhasil menyimpan data'
                          : 'Gagal menyimpan data'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ),
  );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, KelasModel kelas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Kelas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Yakin ingin menghapus ${kelas.namaKelas}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final success = await ref
                  .read(kelasListProvider.notifier)
                  .deleteKelas(kelas.idKelas);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Berhasil menghapus data'
                        : 'Gagal menghapus data'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
