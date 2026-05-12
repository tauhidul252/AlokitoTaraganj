import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/api_service.dart';

class ComplaintBoxScreen extends StatefulWidget {
  const ComplaintBoxScreen({super.key});

  @override
  State<ComplaintBoxScreen> createState() => _ComplaintBoxScreenState();
}

class _ComplaintBoxScreenState extends State<ComplaintBoxScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();
  String _complaintType = 'Road';
  bool _isAnonymous = false;
  bool _submitting = false;

  final List<String> _types = ['Road', 'Water', 'Electricity', 'Corruption', 'Health', 'Education', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final data = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'complaint_type': _complaintType,
      'description': _descController.text,
      'is_anonymous': _isAnonymous,
    };

    final success = await ApiService.submitComplaint(data);

    setState(() => _submitting = false);

    if (mounted) {
      if (success) {
        _nameController.clear();
        _phoneController.clear();
        _descController.clear();
        setState(() {
          _isAnonymous = false;
          _complaintType = 'Road';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint Submitted Successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit complaint. Try again.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Complaint Box',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepOrange.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield, color: Colors.deepOrange, size: 30),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'We respect your privacy. Your identity will be kept confidential if requested.',
                        style: GoogleFonts.inter(
                          color: Colors.deepOrange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Submit your complaint',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                'Fill out the form below to reach District Admin directly.',
                style: GoogleFonts.inter(color: Colors.grey[500]),
              ),
              const SizedBox(height: 25),
              _buildTextField(
                controller: _nameController,
                label: 'Your Name',
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _complaintType,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.category, color: Colors.grey),
                    labelText: 'Complaint Type',
                    labelStyle: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _complaintType = v!),
                ),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _descController,
                label: 'Description',
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (v) => setState(() => _isAnonymous = v!),
                    activeColor: Colors.deepOrange,
                  ),
                  Text('Keep me anonymous', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Submit Complaint', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
