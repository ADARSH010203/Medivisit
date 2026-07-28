import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  // Feature flag for mock OCR in dev builds
  final bool _useMockOcr = true;

  Future<Map<String, String>> extractExpenseDetails(String imagePath) async {
    if (_useMockOcr) {
      await Future.delayed(const Duration(seconds: 2)); // simulate processing delay
      return {
        'total': '1250.00',
        'date': '2023-10-25',
        'vendor': 'Hotel Taj',
      };
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      return _parseExpenseText(recognizedText.text);
    } catch (e) {
      print('OCR Error: $e');
      return {};
    }
  }

  Map<String, String> _parseExpenseText(String text) {
    final result = <String, String>{};
    
    // Basic regex for total amount (e.g. Total: $1250.00, Rs. 500)
    final amountRegex = RegExp(r'(total|amount|rs\.?|usd|\$|₹)\s*:?\s*(\d+[\.,]\d{2})', caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch != null) {
      result['total'] = amountMatch.group(2) ?? '';
    }

    // Basic regex for date (DD/MM/YYYY or YYYY-MM-DD)
    final dateRegex = RegExp(r'(\d{2}[/-]\d{2}[/-]\d{4}|\d{4}[/-]\d{2}[/-]\d{2})');
    final dateMatch = dateRegex.firstMatch(text);
    if (dateMatch != null) {
      result['date'] = dateMatch.group(1) ?? '';
    }
    
    // Fallbacks if nothing matched
    result['vendor'] = 'Extracted Vendor Name'; // Vendor extraction is notoriously hard with basic regex
    
    return result;
  }
  
  void dispose() {
    _textRecognizer.close();
  }
}
