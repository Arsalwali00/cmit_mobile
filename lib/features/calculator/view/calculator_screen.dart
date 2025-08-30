import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cmit/features/home/model/calculator_model.dart';
import 'package:cmit/features/calculator/presenter/calculator_presenter.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _distance = '5k';
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  final _presenter = CalculatorPresenter();

  void _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    final input = CalculatorModel(
      distance: _distance!,
      hours: _hours,
      minutes: _minutes,
      seconds: _seconds,
    );

    final response = await _presenter.calculate(input);

    setState(() {
      _isLoading = false;
      if (response['success']) {
        _result = response['data']['predictions'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Text(
                      'Race Time Calculator',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Inputs
                  Text(
                    'Enter Your Best Race Time',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Race Distance Dropdown
                  DropdownButtonFormField<String>(
                    value: _distance,
                    decoration: InputDecoration(
                      labelText: 'Race Distance',
                      labelStyle: GoogleFonts.poppins(),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.teal[50],
                    ),
                    items: const [
                      DropdownMenuItem(value: '5k', child: Text('5K (5km)')),
                      DropdownMenuItem(value: '10k', child: Text('10K (10km)')),
                      DropdownMenuItem(value: 'half', child: Text('Half Marathon (21.1km)')),
                      DropdownMenuItem(value: 'marathon', child: Text('Marathon (42.2km)')),
                      DropdownMenuItem(value: 'oceans', child: Text('Two Oceans (56km)')),
                      DropdownMenuItem(value: 'comrades', child: Text('Comrades (89km)')),
                    ],
                    onChanged: (value) => setState(() => _distance = value),
                    validator: (value) => value == null ? 'Select a distance' : null,
                  ),
                  const SizedBox(height: 16),

                  // Time Inputs
                  Row(
                    children: [
                      // Hours
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Hours',
                            labelStyle: GoogleFonts.poppins(),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.teal[50],
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter hours';
                            int? hours = int.tryParse(value);
                            if (hours == null || hours < 0 || hours > 24) {
                              return 'Enter 0-24';
                            }
                            return null;
                          },
                          onChanged: (value) => setState(() => _hours = int.tryParse(value) ?? 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Minutes
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Minutes',
                            labelStyle: GoogleFonts.poppins(),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.teal[50],
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter minutes';
                            int? minutes = int.tryParse(value);
                            if (minutes == null || minutes < 0 || minutes > 59) {
                              return 'Enter 0-59';
                            }
                            return null;
                          },
                          onChanged: (value) => setState(() => _minutes = int.tryParse(value) ?? 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Seconds
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Seconds',
                            labelStyle: GoogleFonts.poppins(),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.teal[50],
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter seconds';
                            int? seconds = int.tryParse(value);
                            if (seconds == null || seconds < 0 || seconds > 59) {
                              return 'Enter 0-59';
                            }
                            return null;
                          },
                          onChanged: (value) => setState(() => _seconds = int.tryParse(value) ?? 0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Calculate Button
                  Center(
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.teal[400])
                        : ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Calculate Predictions',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Results
                  if (_result != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Predicted Times for $_distance',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._result!.entries.map<Widget>((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    Text(
                                      entry.value.toString(),
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}