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
    );
  }
}

class EducareHomePage extends StatefulWidget {
  const EducareHomePage({super.key});

  @override
  State<EducareHomePage> createState() => _EducareHomePageState();
}

class _EducareHomePageState extends State<EducareHomePage> {
  String? fromCountry;
  String? toCountry;

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
    setState(() {
      resultText = 'Fetching data...';
    });

    if (fromCountry == null) {
      setState(() {
        resultText = 'Please select a departure country.';
      });
      return;
    }

    if (toCountry == null) {
      setState(() {
        resultText = 'Please select a destination country.';
      });
      return;
    }

    final url = Uri.parse(
        'https://educare-ai-tool.onrender.com/requirements?from_country=$fromCountry&to_country=$toCountry');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            resultText = 'Requirement:\n${data['requirement']}';
          });
        } else {
          setState(() {
            resultText = 'No requirement found for this selection.';
          });
        }
      } else {
        setState(() {
          resultText = 'Server error. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        resultText = 'Error: ${e.toString()}';
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
  void initState() {
    super.initState();
    // Set default value for fromCountry to United States since it's the only option
    fromCountry = fromCountries[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educare AI Tool'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Educare',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
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

            // From Country dropdown (only United States)
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

            // To Country dropdown
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
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ),

            const SizedBox(height: 30),
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

