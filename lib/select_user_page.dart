import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';

class SelectUserPage extends StatefulWidget {
  const SelectUserPage({super.key});

  @override
  State<SelectUserPage> createState() => _SelectUserPageState();
}

class _SelectUserPageState extends State<SelectUserPage> {
  String _dbname = "";
  bool _isLoading = false;
  String _errorMessage = "";
  List<dynamic> _users = []; // Menyimpan daftar pengguna dari API
  String? _selectedUsername; // Untuk menyimpan username yang dipilih
  TextEditingController _passwordController =
      TextEditingController(); // Controller untuk password

  @override
  void initState() {
    super.initState();
    _getDatabaseNameFromSharedPreferences();
  }

  // Fungsi untuk mengambil data database_name dari SharedPreferences
  Future<void> _getDatabaseNameFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
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

  // Fungsi untuk mengirimkan database_name ke API dan mengambil data pengguna
  Future<void> _connectToApiWithDatabaseName(String dbname) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://seputar-it.eu.org/POS/User/select_user.php'), // Ganti dengan URL API yang sesuai
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'database_name': dbname, // Kirimkan database_name ke API
        }),
      );

      if (response.statusCode == 200) {
        // Berhasil mengirimkan data ke API
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // Jika data berhasil diterima, simpan dalam daftar _users
          setState(() {
            _users = data['data']; // Menyimpan data pengguna dari API
            if (_users.isNotEmpty) {
              _selectedUsername = _users[0]
                  ['username']; // Pilih username pertama sebagai default
            }
          });

          print('Response from API: $data');
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Terjadi kesalahan pada server';
          });
        }
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

  Future<void> _login() async {
    final password = _passwordController.text;
    if (_selectedUsername == null || password.isEmpty) {
      setState(() {
        _errorMessage = "Username dan Password harus diisi.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = ""; // Reset error message
    });

    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/POS/User/Login.php'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _selectedUsername, // Mengirimkan username
          'password': password, // Mengirimkan password
          'database_name': _dbname, // Mengirimkan nama database
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == 'success') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'username', _selectedUsername!); // Simpan username

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Login gagal';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Terjadi kesalahan saat login';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade800,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1300),
                    child: const Text(
                      "Welcome Back",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 60),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(225, 95, 27, .3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              // Dropdown untuk memilih username
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: _users.isEmpty
                                    ? const CircularProgressIndicator()
                                    : DropdownButton<String>(
                                        value: _selectedUsername,
                                        hint: const Text("Select Username"),
                                        isExpanded: true,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedUsername = newValue;
                                          });
                                        },
                                        items: _users
                                            .map<DropdownMenuItem<String>>(
                                          (user) {
                                            return DropdownMenuItem<String>(
                                              value: user['username'],
                                              child: Text(user['username']),
                                            );
                                          },
                                        ).toList(),
                                      ),
                              ),
                              // Password field
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : FadeInUp(
                              duration: const Duration(milliseconds: 1600),
                              child: MaterialButton(
                                onPressed: _login,
                                height: 50,
                                color: Colors.orange[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 20),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1700),
                        child: const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1800),
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/register');
                          },
                          height: 50,
                          color: Colors.orange[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
