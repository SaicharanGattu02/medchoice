import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiAii extends StatefulWidget {
  const GeminiAii({super.key});

  @override
  State<GeminiAii> createState() => _GeminiAiiState();
}

class _GeminiAiiState extends State<GeminiAii> {
  // API key (not used in this example)
  final String apiKey = "AIzaSyBElOz3OiPUZJY9KG09xfeZ6Tdia7eQ9zw";

  // Controller for text input
  final TextEditingController _controller = TextEditingController();

  // Variable to store AI response
  String _aiResponse = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Simulated AI interaction
  Future<void> _getAIResponse() async {
    try {
      // Simulate a network request
      final response = await http.post(
        Uri.parse('https://api.example.com/generate-text'), // Replace with actual API URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey', // Include your API key if required
        },
        body: jsonEncode({
          'prompt': _controller.text,
          'max_tokens': 60,
        }),
      );

      if (response.statusCode == 200) {
        print("${response.statusCode}");
        final data = jsonDecode(response.body);
        setState(() {
          _aiResponse = data['choices'][0]['text']; // Adjust based on actual API response
        });
      } else {
        setState(() {
          _aiResponse = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = 'Error: $e';
      });
    }
  }

  // Method to clear chat and refresh the page
  void _clearChat() {
    setState(() {
      _controller.clear();
      _aiResponse = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Interaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearChat, // Call method to clear chat and refresh page
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter your prompt',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _getAIResponse,
              child: const Text('Get AI Response'),
            ),
            const SizedBox(height: 16.0),
            if (_aiResponse.isNotEmpty)
              Text(
                'AI Response:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            const SizedBox(height: 8.0),
            if (_aiResponse.isNotEmpty)
              Text(
                _aiResponse,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}
