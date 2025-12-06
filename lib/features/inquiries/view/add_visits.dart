// lib/features/inquiries/view/add_visits.dart
import 'package:flutter/material.dart';
import 'package:cmit/core/vehicle_driver_service.dart';
import 'package:cmit/features/inquiries/model/vehicle_driver_model.dart';
import 'package:cmit/core/visit_inquiry_service.dart';

class AddVisitsScreen extends StatefulWidget {
  final int inquiryId;
  final VoidCallback? onVisitAdded; // ← Correct parameter name

  const AddVisitsScreen({
    super.key,
    required this.inquiryId,
    this.onVisitAdded,
  });

  @override
  State<AddVisitsScreen> createState() => _AddVisitsScreenState();
}

class _AddVisitsScreenState extends State<AddVisitsScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDriverId;
  String? _selectedVehicleId;

  Map<String, String> driversMap = {};
  Map<String, String> vehiclesMap = {};

  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDriversAndVehicles();
  }

  Future<void> _fetchDriversAndVehicles() async {
    final result = await VehicleDriverService.getVehicleDriverData();
    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'] as VehicleDriverModel;
      setState(() {
        driversMap = data.drivers;
        vehiclesMap = data.vehicles;
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = result['message'] ?? "Failed to load data";
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final visitDate = _selectedDate!.toIso8601String().split('T').first;
    final visitTime =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    final result = await VisitInquiryService.addVisit(
      visitDate: visitDate,
      visitTime: visitTime,
      vehicleId: int.parse(_selectedVehicleId!),
      driverId: int.parse(_selectedDriverId!),
      inquiryId: widget.inquiryId,
    );

    if (!mounted) return;
    setState(() => isSubmitting = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Visit added!"), backgroundColor: Colors.green),
      );
      widget.onVisitAdded?.call(); // ← This triggers refresh in parent
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Failed"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text('Record Field Visit', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  children: [
                    _buildDateSection(),
                    const SizedBox(height: 8),
                    _buildTimeSection(),
                    const SizedBox(height: 8),
                    _buildDriverSection(),
                    const SizedBox(height: 8),
                    _buildVehicleSection(),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // UI Builders (unchanged – kept clean)
  Widget _buildDateSection() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Visit Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 8),
      InkWell(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
          child: Row(children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 12),
            Text(_selectedDate == null
                ? 'Select date'
                : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'),
          ]),
        ),
      ),
      if (_selectedDate == null) const Padding(padding: EdgeInsets.only(top: 6, left: 12), child: Text('Required', style: TextStyle(color: Colors.red, fontSize: 12))),
    ]),
  );

  Widget _buildTimeSection() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Visit Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 8),
      InkWell(
        onTap: _selectTime,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
          child: Row(children: [
            const Icon(Icons.access_time, size: 18),
            const SizedBox(width: 12),
            Text(_selectedTime == null ? 'Select time' : _selectedTime!.format(context)),
          ]),
        ),
      ),
      if (_selectedTime == null) const Padding(padding: EdgeInsets.only(top: 6, left: 12), child: Text('Required', style: TextStyle(color: Colors.red, fontSize: 12))),
    ]),
  );

  Widget _buildDriverSection() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Driver', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _selectedDriverId,
        hint: const Text('Select driver'),
        validator: (v) => v == null ? 'Please select a driver' : null,
        decoration: InputDecoration(filled: true, fillColor: Colors.grey[50], contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        items: driversMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
        onChanged: (v) => setState(() => _selectedDriverId = v),
      ),
    ]),
  );

  Widget _buildVehicleSection() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Vehicle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _selectedVehicleId,
        hint: const Text('Select vehicle'),
        validator: (v) => v == null ? 'Please select a vehicle' : null,
        decoration: InputDecoration(filled: true, fillColor: Colors.grey[50], contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        items: vehiclesMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
        onChanged: (v) => setState(() => _selectedVehicleId = v),
      ),
    ]),
  );

  Widget _buildBottomButtons() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Expanded(child: OutlinedButton(onPressed: isSubmitting ? null : () => Navigator.pop(context), child: const Text('Cancel'))),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
          child: isSubmitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Visit', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    ]),
  );
}