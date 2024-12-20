import 'dart:convert';
import 'package:http/http.dart' as http;

class DaDataService {
  final String apiKey = 'dbafccafab6746582b3c61ca11591119541760fd';
  final String secretKey = '3fcf5bcf936fb7d718dde10e937befdc43a8f786';
  final String baseUrl = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/findById/party';

  Future<Map<String, dynamic>?> getOrganizationInfo(String inn) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $apiKey',
      },
      body: jsonEncode({'query': inn}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['suggestions'] != null && data['suggestions'].isNotEmpty) {
        return data['suggestions'][0]['data'];
      }
    }
    return null;
  }
}
