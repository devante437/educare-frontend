import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const EducareApp());
}

class EducareApp extends StatelessWidget {
  const EducareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educare AI Tool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const EducareHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EducareHomePage extends StatefulWidget {
  const EducareHomePage({super.key});

  @override
  State<EducareHomePage> createState() => _EducareHomePageState();
}

class _EducareHomePageState extends State<EducareHomePage> {
  String? fromCountry = 'United States';
  String? toCountry;
  bool isLoading = false;

  final List<String> fromCountries = [
    'United States',
  ];

  final List<String> toCountries = [
    'France',
    'Germany',
    'Spain',
    'Netherlands',
    'Italy',
  ];

  String resultText = '';

  Future<void> _submit() async {
    if (fromCountry == null || toCountry == null) {
      setState(() {
        resultText = 'Please select both From and To countries.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      resultText = '';
    });

    final url = Uri.parse(
      'https://educare-ai-tool.onrender.com/api/requirements?from_country=$fromCountry&to_country=$toCountry',
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      setState(() {
        if (response.statusCode == 200 && data['status'] == 'success') {
          resultText = 'Requirement:\n${data['requirement']}';
        } else {
          resultText = 'No requirement found for this selection.';
        }
      });
    } catch (e) {
      setState(() {
        resultText = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchURL() async {
    const url = 'https://educare-ai-tool.onrender.com/';
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educare AI Tool'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Educare',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'See requirements for studying abroad with our AI-powered tool.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _launchURL,
              child: const Text(
                'Visit API Site',
                style: TextStyle(
                  color: Colors.deepPurple,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'From Country',
                border: OutlineInputBorder(),
              ),
              value: fromCountry,
              items: fromCountries
                  .map((country) =>
                      DropdownMenuItem(value: country, child: Text(country)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  fromCountry = value;
                });
              },
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'To Country',
                border: OutlineInputBorder(),
              ),
              value: toCountry,
              items: toCountries
                  .map((country) =>
                      DropdownMenuItem(value: country, child: Text(country)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  toCountry = value;
                });
              },
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: const Text('Submit'),
              ),
            ),
            const SizedBox(height: 30),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: Text(
                  resultText,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

