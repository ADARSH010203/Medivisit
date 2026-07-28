import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'supabase_function_service.dart';

class CloudinaryService {
  static const String _cloudName = 'iqg0bmp';

  // Upload image to Cloudinary (FREE tier) using Supabase signed URL
  static Future<String?> uploadImage(String filePath, String folder, {Function(double)? onProgress}) async {
    try {
      if (onProgress != null) onProgress(0.05);
      
      // 1. Get signature from Supabase Edge Function
      final signatureData = await SupabaseFunctionService.getUploadSignature(folder);
      if (signatureData == null) return null;

      if (onProgress != null) onProgress(0.15);

      final signature = signatureData['signature'];
      final timestamp = signatureData['timestamp'];
      final apiKey = signatureData['api_key'];

      // 2. Upload to Cloudinary using http multipart request
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['folder'] = 'medivisit/$folder';
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['api_key'] = apiKey;

      final file = File(filePath);
      final length = await file.length();
      int byteCount = 0;

      final stream = file.openRead().transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: (List<int> data, EventSink<List<int>> sink) {
            byteCount += data.length;
            if (onProgress != null) {
              // Map byte progress from 15% to 95%
              final fileProgress = byteCount / length;
              onProgress(0.15 + (fileProgress * 0.8));
            }
            sink.add(data);
          },
        ),
      );

      final multipartFile = http.MultipartFile('file', stream, length, filename: filePath.split('/').last);
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (onProgress != null) onProgress(1.0);
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['secure_url'];
      } else {
        debugPrint('Cloudinary upload error: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload exception: $e');
      return null;
    }
  }

  // Get optimized image URL (simple transformation string logic instead of SDK for now)
  static String getImageUrl(String url, {int width = 400}) {
    if (!url.contains('res.cloudinary.com')) return url;
    final parts = url.split('/upload/');
    if (parts.length == 2) {
      return '${parts[0]}/upload/w_$width,c_scale,q_auto,f_auto/${parts[1]}';
    }
    return url;
  }
}
