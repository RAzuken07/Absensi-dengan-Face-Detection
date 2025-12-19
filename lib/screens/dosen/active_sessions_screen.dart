import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/dosen_provider.dart';
import '../../widgets/gradient_background.dart';
import '../../config/app_colors.dart';

class ActiveSessionsScreen extends ConsumerWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(dosenActiveSessionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Sesi Aktif',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(dosenActiveSessionsProvider),
          ),
        ],
      ),
      body: GradientBackground(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: sessions.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(dosenActiveSessionsProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 64, color: Colors.white70),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada sesi aktif',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Buka sesi dari menu Kelas Saya',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final sesi = sessions[index];
              final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sesi.namaKelas ?? 'Kelas',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (sesi.namaMatakuliah != null)
                                  Text(
                                    sesi.namaMatakuliah!,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: sesi.isActive ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sesi.statusSesi.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.topic,
                        'Topik',
                        sesi.topik ?? '-',
                      ),
                      _buildInfoRow(
                        Icons.numbers,
                        'Pertemuan',
                        'Ke-${sesi.pertemuanKe ?? '-'}',
                      ),
                      _buildInfoRow(
                        Icons.access_time,
                        'Dibuka',
                        dateFormat.format(sesi.waktuBuka),
                      ),
                      _buildInfoRow(
                        Icons.timer,
                        'Sisa Waktu',
                        sesi.isExpired
                            ? 'Expired'
                            : '${sesi.sisaMenit} menit',
                        color: sesi.isExpired ? Colors.red : Colors.green,
                      ),
                      if (sesi.kodeSesi != null)
                        _buildInfoRow(
                          Icons.qr_code,
                          'Kode Sesi',
                          sesi.kodeSesi!,
                        ),
                      const SizedBox(height: 16),
                      // Detail Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/dosen/pertemuan-detail',
                              arguments: sesi,
                            );
                          },
                          icon: const Icon(Icons.list),
                          label: const Text('Lihat Daftar Kehadiran'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (sesi.isActive)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmClose(context, ref, sesi.idSesi),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            icon: const Icon(Icons.close),
                            label: const Text('Tutup Sesi'),
                          ),
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClose(BuildContext context, WidgetRef ref, int idSesi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutup Sesi'),
        content: const Text('Yakin ingin menutup sesi absensi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await ref
                  .read(dosenActiveSessionsProvider.notifier)
                  .closeSesi(idSesi);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Sesi berhasil ditutup' : 'Gagal menutup sesi',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Tutup Sesi'),
          ),
        ],
      ),
    );
  }
}
