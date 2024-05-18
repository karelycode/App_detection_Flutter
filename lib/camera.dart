/*
 * Copyright 2023 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'image_classification_helper.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  ImageClassificationHelper? imageClassificationHelper;
  final imagePicker = ImagePicker();
  String? imagePath;
  img.Image? image;
  Map<String, double>? classification;
  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper!.initHelper();
    abrircamara();
    super.initState();
  }

  Future abrircamara() async{
  cleanResult();
  final result = await imagePicker.pickImage(
    source: ImageSource.camera,
  );
  imagePath = result?.path;
  setState(() {});
  processImage();
}
  // Clean old results when press some take picture button
  void cleanResult() {
    imagePath = null;
    image = null;
    classification = null;
    setState(() {});
  }

  // Process picked image
  Future<void> processImage() async {
    if (imagePath != null) {
       final imageData = File(imagePath!).readAsBytesSync();
      image = img.decodeImage(imageData);
      setState(() {});
      classification = await imageClassificationHelper?.inferenceImage(image!);
      setState(() {});
    }
  }

  @override
  void dispose() {
    imageClassificationHelper?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [

          Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (imagePath != null) Image.file(File(imagePath!)),
                  if (image == null)
                    const Text("Tomar foto"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show classification result
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            if (classification != null)
                              ...(classification!.entries.toList()
                                ..sort(
                                      (a, b) => a.value.compareTo(b.value),
                                ))
                                  .reversed
                                  .take(3)
                                  .map(
                                    (e) => Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      Text(e.key),
                                      const Spacer(),
                                      Text(e.value.toStringAsFixed(2))
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
