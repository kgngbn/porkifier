import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'app_drawer.dart';
import 'package:tflite/tflite.dart';

File? _imageFile;
List<dynamic>? _recognitions;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    setState(() {
      _imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _classifyImage() async {
    if (_imageFile == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Tflite.loadModel(
      model: 'assets/tflite_model_another.tflite',
      labels: 'assets/labels.txt',
    );

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: _imageFile!.path,
      );

      String result = 'Unknown';

      if (recognitions != null && recognitions.isNotEmpty) {
        result = recognitions[0]['label'];
      }

      // Show the classification result as a SnackBar or a Toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The pork is $result.'),
        ),
      );
    } catch (e) {
      print('Error classifying image: $e');
    } finally {
      Tflite.close();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAE9),
      appBar: AppBar(
        backgroundColor: Color(0xFFEC615A),
        title: Text(
          'PorkSafe',
          style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.edit),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/logo.png',
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                  SizedBox(height: 10),
                  Text(
                    'Scan Pork to Detect Spoilage or Freshness',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(ImageSource.gallery);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF5347D9),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                    ),
                    child: Text('Select from gallery'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(ImageSource.camera);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF5347D9),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                    ),
                    child: Text('Take a photo'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _classifyImage,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF5347D9),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator() // Show loading indicator
                        : Text('Classify Image'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
    );
  }
}
