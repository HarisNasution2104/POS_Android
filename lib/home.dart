import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _dbname = "";
  bool _isLoading = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _getDatabaseNameFromSharedPreferences();
  }

  // Fungsi untuk mengambil data database_name dari SharedPreferences
  Future<void> _getDatabaseNameFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Mengambil nilai database_name yang disimpan
    String? dbname = prefs.getString('database_name');

    if (dbname != null) {
      setState(() {
        _dbname = dbname;
      });

      print("Database name yang disimpan di SharedPreferences: $_dbname");

      // Kirimkan koneksi ke API setelah mengambil nama database
      _connectToApiWithDatabaseName(_dbname);
    } else {
      setState(() {
        _errorMessage = "Database name tidak ditemukan di SharedPreferences.";
      });
      print("Database name tidak ditemukan di SharedPreferences.");
    }
  }

  // Fungsi untuk mengirimkan database_name ke API
  Future<void> _connectToApiWithDatabaseName(String dbname) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/POS/User/select_user.php'),  // Ganti dengan URL API yang sesuai
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'database_name': dbname,  // Kirimkan database_name ke API
        }),
      );

      if (response.statusCode == 200) {
        // Berhasil mengirimkan data ke API
        final data = jsonDecode(response.body);
        print('Response from API: $data');
        // Anda bisa melakukan tindakan lebih lanjut berdasarkan respons API
      } else {
        setState(() {
          _errorMessage = 'Gagal mengirim data ke API';
        });
        print('Failed to connect to API: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select User Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_dbname.isNotEmpty)
              Text(
                'Database name: $_dbname',
                style: const TextStyle(fontSize: 20),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getDatabaseNameFromSharedPreferences,
              child: const Text('Re-fetch Database Name'),
            ),
          ],
        ),
      ),
    );
  }
}
