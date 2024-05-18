import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextRecognizerPage extends StatefulWidget {
  @override
  _TextRecognizerPageState createState() => _TextRecognizerPageState();
}

class _TextRecognizerPageState extends State<TextRecognizerPage> {
  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);
  final FlutterTts _flutterTts = FlutterTts();
  String _extractedText = '';
  File? _imageFile;

  Future<void> _recognizeText() async {
    if (_imageFile != null) {
      final InputImage inputImage = InputImage.fromFile(_imageFile!);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text;
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      await _recognizeText();
    }
  }

  Future<void> _speakText() async {
    await _flutterTts.setLanguage("es-MX");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(_extractedText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lector de Texto'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _getImageFromCamera,
              child: Text('Tomar Foto'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    _extractedText,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speakText,
              child: Text('Reproducir Texto'),
            ),
          ],
        ),
      ),
    );
  }
}
