import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _noteleponController = TextEditingController();
  File? _imageProfile;
  File? _imageKtp;
  File? _imageSim;
  final picker = ImagePicker();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _pickImage(String type) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        if (type == 'profile') {
          _imageProfile = File(pickedFile.path);
        } else if (type == 'ktp') {
          _imageKtp = File(pickedFile.path);
        } else if (type == 'sim') {
          _imageSim = File(pickedFile.path);
        }
      }
    });
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.13:5006/api/drivers/register'),
    );
    request.fields['username'] = _usernameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['password'] = _passwordController.text;
    request.fields['no_telepon'] = _noteleponController.text;

    if (_imageProfile != null) {
      request.files.add(await http.MultipartFile.fromPath('images', _imageProfile!.path));
    }
    if (_imageKtp != null) {
      request.files.add(await http.MultipartFile.fromPath('images_ktp', _imageKtp!.path));
    }
    if (_imageSim != null) {
      request.files.add(await http.MultipartFile.fromPath('images_sim', _imageSim!.path));
    }

    var response = await request.send();

    response.stream.transform(utf8.decoder).listen((value) {
      if (response.statusCode == 201) {
        Navigator.pushReplacementNamed(context, '/driver-login');
      } else {
        setState(() {
          _errorMessage = json.decode(value)['message'] ?? 'Registration failed';
        });
      }
    });

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[700],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
                SizedBox(height: 20),
                Text(
                  'Buat Akun',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
                SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickImage('profile'),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.purple[300],
                    child: _imageProfile != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        _imageProfile!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Container(
                      decoration: BoxDecoration(
                          color: Colors.purple[300],
                          borderRadius: BorderRadius.circular(50)),
                      width: 100,
                      height: 100,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickImage('ktp'),
                  child: Container(
                    color: Colors.purple[300],
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.file_upload, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Upload KTP', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickImage('sim'),
                  child: Container(
                    color: Colors.purple[300],
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.file_upload, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Upload SIM', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.purple[300],
                    hintText: 'Nama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.purple[300],
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _noteleponController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.purple[300],
                    hintText: 'No Telepon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.purple[300],
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: Text('Daftar'),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/driver-login');
                  },
                  child: Text(
                    'Sudah punya akun? Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
