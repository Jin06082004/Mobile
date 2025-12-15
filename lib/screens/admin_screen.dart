import 'package:flutter/material.dart';
import '../database/seed_data.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final SeedData _seedData = SeedData();
  bool _isLoading = false;
  String _message = '';

  Future<void> _seedDatabase() async {
    setState(() {
      _isLoading = true;
      _message = 'Đang thêm dữ liệu...';
    });

    try {
      await _seedData.seedAll();
      setState(() {
        _message = '✅ Đã thêm dữ liệu mẫu thành công!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = '❌ Lỗi: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa tất cả dữ liệu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _message = 'Đang xóa dữ liệu...';
    });

    try {
      await _seedData.clearAllData();
      setState(() {
        _message = '✅ Đã xóa dữ liệu thành công!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = '❌ Lỗi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản trị dữ liệu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Firebase Database Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm hoặc xóa dữ liệu mẫu trong Firestore',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _seedDatabase,
              icon: const Icon(Icons.upload),
              label: const Text('Thêm dữ liệu mẫu'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _clearDatabase,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Xóa tất cả dữ liệu'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _message.contains('✅')
                      ? Colors.green[50]
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _message.contains('✅') ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('✅')
                        ? Colors.green[900]
                        : Colors.red[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ℹ️ Hướng dẫn:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Nhấn "Thêm dữ liệu mẫu" để thêm phòng vào Firebase\n'
                    '2. Dữ liệu sẽ xuất hiện trong app ngay lập tức\n'
                    '3. Nhấn "Xóa tất cả" để xóa dữ liệu khi cần',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
