import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/mahasiswa_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_background.dart';
import '../../config/app_colors.dart';

class MahasiswaPertemuanListScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> matakuliah;

  const MahasiswaPertemuanListScreen({super.key, required this.matakuliah});

  @override
  ConsumerState<MahasiswaPertemuanListScreen> createState() =>
      _MahasiswaPertemuanListScreenState();
}

class _MahasiswaPertemuanListScreenState
    extends ConsumerState<MahasiswaPertemuanListScreen> {
  List<Map<String, dynamic>> _pertemuanList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPertemuanStatus();
  }

  Future<void> _loadPertemuanStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = ref.read(authStateProvider).user;
      final nim = user?.nim;
      
      if (nim == null) {
        throw Exception('NIM not found');
      }

      final mahasiswaService = MahasiswaService();
      final idKelas = widget.matakuliah['id_kelas'] as int?;
      
      if (idKelas == null) {
        throw Exception('ID Kelas not found');
      }

      final pertemuanList = await mahasiswaService.getPertemuanStatus(idKelas, nim);

      if (mounted) {
        setState(() {
          _pertemuanList = pertemuanList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.matakuliah['nama_mk'] ?? 'Detail Mata Kuliah',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPertemuanStatus,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: GradientBackground(
        child: Column(
          children: [
            // Header Info
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.matakuliah['nama_mk'] ?? 'Mata Kuliah',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.class_, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Kelas: ${widget.matakuliah['nama_kelas'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Dosen: ${widget.matakuliah['nama_dosen'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Pertemuan Grid
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPertemuanStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group into max 16 pertemuan (create placeholders if needed)
    final maxPertemuan = 16;
    final displayList = List<Map<String, dynamic>?>.generate(
      maxPertemuan,
      (index) {
        final pertemuanKe = index + 1;
        try {
          return _pertemuanList.firstWhere(
            (p) => p['pertemuan_ke'] == pertemuanKe,
          );
        } catch (e) {
          return null; // placeholder for pertemuan that doesn't exist yet
        }
      },
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status 16 Pertemuan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: _loadPertemuanStatus,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid 4x4
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final pertemuanKe = index + 1;
                      final pertemuan = displayList[index];
                      return _buildPertemuanBox(pertemuanKe, pertemuan);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Legend
                  _buildLegend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPertemuanBox(int pertemuanKe, Map<String, dynamic>? pertemuan) {
    Color boxColor;
    Color textColor;
    IconData? icon;
    bool isClickable = false;

    if (pertemuan == null) {
      // No pertemuan data
      boxColor = Colors.grey.shade200;
      textColor = Colors.grey.shade600;
    } else {
      final statusAbsensi = pertemuan['status_absensi'];
      final statusSesi = pertemuan['status_sesi'];
      final idSesi = pertemuan['id_sesi'];

      if (statusAbsensi == 'hadir') {
        // Sudah absen - GREEN
        boxColor = Colors.green.shade400;
        textColor = Colors.white;
        icon = Icons.check;
      } else if (statusAbsensi == 'izin') {
        // Izin - YELLOW
        boxColor = Colors.yellow.shade700;
        textColor = Colors.white;
        icon = Icons.event_note;
      } else if (statusAbsensi == 'sakit') {
        // Sakit - BLUE
        boxColor = Colors.blue.shade600;
        textColor = Colors.white;
        icon = Icons.local_hospital;
      } else if (idSesi != null && statusSesi == 'aktif') {
        // Ada sesi aktif, belum absen - ORANGE/YELLOW
        boxColor = Colors.orange.shade400;
        textColor = Colors.white;
        icon = Icons.qr_code_scanner;
        isClickable = true;
      } else if (idSesi != null && statusSesi == 'selesai') {
        // Sesi sudah ditutup, tidak absen - RED
        boxColor = Colors.red.shade300;
        textColor = Colors.white;
        icon = Icons.close;
      } else {
        // Belum ada sesi - WHITE/GREY
        boxColor = Colors.grey.shade200;
        textColor = Colors.grey.shade600;
      }
    }

    return Material(
      color: boxColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isClickable
            ? () => _handlePertemuanTap(pertemuanKe, pertemuan!)
            : () => _showPertemuanInfo(pertemuanKe, pertemuan),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: boxColor == Colors.grey.shade200
                  ? Colors.grey.shade400
                  : boxColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, size: 20, color: textColor)
              else
                const SizedBox(height: 20),
              const SizedBox(height: 4),
              Text(
                '$pertemuanKe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildLegendItem(Colors.green.shade400, 'Hadir'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.orange.shade400, 'Belum Absen'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildLegendItem(Colors.yellow.shade700, 'Izin'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.blue.shade600, 'Sakit'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildLegendItem(Colors.red.shade300, 'Alpha'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.grey.shade200, 'Belum Dibuat'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color == Colors.grey.shade200
                  ? Colors.grey.shade400
                  : color.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _handlePertemuanTap(int pertemuanKe, Map<String, dynamic> pertemuan) {
    // Navigate to scan QR for active session
    Navigator.pushNamed(
      context,
      '/mahasiswa/scan-qr',
      arguments: pertemuan,
    );
  }

  void _showPertemuanInfo(int pertemuanKe, Map<String, dynamic>? pertemuan) {
    String message;
    IconData icon;
    Color color;

    if (pertemuan == null) {
      message = 'Pertemuan ke-$pertemuanKe belum dibuat oleh dosen.';
      icon = Icons.info_outline;
      color = Colors.grey;
    } else {
      final statusAbsensi = pertemuan['status_absensi'];
      final statusSesi = pertemuan['status_sesi'];
      
      if (statusAbsensi == 'hadir') {
        message = 'Anda sudah absen pada pertemuan ke-$pertemuanKe.';
        icon = Icons.check_circle;
        color = Colors.green;
      } else if (statusAbsensi == 'izin') {
        message = 'Anda izin pada pertemuan ke-$pertemuanKe.';
        icon = Icons.event_note;
        color = Colors.yellow[700]!;
      } else if (statusAbsensi == 'sakit') {
        message = 'Anda sakit pada pertemuan ke-$pertemuanKe.';
        icon = Icons.local_hospital;
        color = Colors.blue;
      } else if (statusSesi == 'selesai') {
        message = 'Sesi untuk pertemuan ke-$pertemuanKe sudah ditutup.\nAnda tidak bisa absen lagi.';
        icon = Icons.cancel;
        color = Colors.red;
      } else {
        message = 'Belum ada sesi aktif untuk pertemuan ke-$pertemuanKe.';
        icon = Icons.info_outline;
        color = Colors.grey;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(icon, size: 48, color: color),
        title: Text('Pertemuan ke-$pertemuanKe'),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
