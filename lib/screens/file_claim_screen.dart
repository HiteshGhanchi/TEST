import 'package:flutter/material.dart';

class FileClaimScreen extends StatefulWidget {
  const FileClaimScreen({super.key});

  @override
  State<FileClaimScreen> createState() => _FileClaimScreenState();
}

class _FileClaimScreenState extends State<FileClaimScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File a Claim'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Claim Details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter claim details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Claim submitted successfully!')),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Submit Claim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
