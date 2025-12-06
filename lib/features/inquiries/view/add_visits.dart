// lib/features/inquiries/view/add_visits.dart
import 'package:flutter/material.dart';
import 'package:cmit/core/vehicle_driver_service.dart'; // Adjust path if needed
import 'package:cmit/features/inquiries/model/vehicle_driver_model.dart';

class AddVisitsScreen extends StatefulWidget {
  final int inquiryId;
  final Function(Map<String, String>) onAddVisit;

  const AddVisitsScreen({
    super.key,
    required this.inquiryId,
    required this.onAddVisit,
  });

  @override
  State<AddVisitsScreen> createState() => _AddVisitsScreenState();
}

class _AddVisitsScreenState extends State<AddVisitsScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDriverId;   // Now stores ID (e.g., "1")
  String? _selectedVehicleId;  // Now stores ID (e.g., "2")

  // Live data from API
  Map<String, String> driversMap = {};
  Map<String, String> vehiclesMap = {};

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDriversAndVehicles();
  }

  Future<void> _fetchDriversAndVehicles() async {
    final result = await VehicleDriverService.getVehicleDriverData();

    if (result['success'] == true) {
      final VehicleDriverModel data = result['data'];
      setState(() {
        driversMap = data.drivers;   // { "1": "Ishtiyaq", "2": "Naveed Ahmed", ... }
        vehiclesMap = data.vehicles; // { "1": "CMIT01", "2": "CMIT02", ... }
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = result['message'] ?? "Failed to load drivers & vehicles";
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final visitData = {
        'date': _selectedDate!.toIso8601String().split('T').first,
        'time': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        'driver_id': _selectedDriverId!,
        'vehicle_id': _selectedVehicleId!,
        'inquiry_id': widget.inquiryId.toString(),
      };

      widget.onAddVisit(visitData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Record Field Visit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => isLoading = true);
                _fetchDriversAndVehicles();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Picker
                    _buildDateSection(),
                    const SizedBox(height: 8),
                    // Time Picker
                    _buildTimeSection(),
                    const SizedBox(height: 8),
                    // Driver Dropdown (Live)
                    _buildDriverSection(),
                    const SizedBox(height: 8),
                    // Vehicle Dropdown (Live)
                    _buildVehicleSection(),
                  ],
                ),
              ),
            ),
            // Bottom Buttons
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Visit Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _selectedDate != null ? Colors.grey[400]! : Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null
                      ? 'Select date'
                      : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                  style: TextStyle(fontSize: 14, color: _selectedDate != null ? Colors.black87 : Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
        if (_selectedDate == null)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 12),
            child: Text('Please select a date', style: TextStyle(fontSize: 12, color: Colors.red)),
          ),
      ],
    ),
  );

  Widget _buildTimeSection() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Visit Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _selectedTime != null ? Colors.grey[400]! : Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  _selectedTime == null ? 'Select time' : _selectedTime!.format(context),
                  style: TextStyle(fontSize: 14, color: _selectedTime != null ? Colors.black87 : Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
        if (_selectedTime == null)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 12),
            child: Text('Please select a time', style: TextStyle(fontSize: 12, color: Colors.red)),
          ),
      ],
    ),
  );

  Widget _buildDriverSection() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Driver', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDriverId,
          hint: Text('Select driver', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          validator: (v) => v == null ? 'Please select a driver' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[400]!)),
          ),
          items: driversMap.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (v) => setState(() => _selectedDriverId = v),
        ),
      ],
    ),
  );

  Widget _buildVehicleSection() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vehicle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedVehicleId,
          hint: Text('Select vehicle', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          validator: (v) => v == null ? 'Please select a vehicle' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[400]!)),
          ),
          items: vehiclesMap.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (v) => setState(() => _selectedVehicleId = v),
        ),
      ],
    ),
  );

  Widget _buildBottomButtons() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_selectedDate == null || _selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select date and time'), backgroundColor: Colors.red),
                );
                return;
              }
              _submit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save Visit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    ),
  );
}