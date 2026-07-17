import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:prime_access/providers/auth_provider.dart';

const _roles = ['DEVELOPPEUR', 'SCRUM MASTER', 'MANAGEUR'];
const _contractors = [
  '(SIC) SMART INNOVATION CENTER',
  'SYNELIA',
  '(OCI) ORANGE COTE D\'IVOIRE',
];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _loginController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late String? _selectedRole;
  late String? _selectedContractor;
  final _imagePicker = ImagePicker();
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _loginController = TextEditingController(text: user?.login ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _selectedRole = user?.role;
    _selectedContractor = user?.contractor;
  }

  @override
  void dispose() {
    _loginController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 400,
    );
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? Text(
                                _firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty
                                    ? '${_firstNameController.text[0]}${_lastNameController.text[0]}'.toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _loginController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Login', prefixIcon: Icon(Icons.person_outlined)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Le login est requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Prénoms'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'L\'email est requis';
                  if (!v.contains('@') || !v.contains('.')) return 'Format d\'email invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _roles.contains(_selectedRole) ? _selectedRole : null,
                decoration: const InputDecoration(
                  labelText: 'Fonction',
                  prefixIcon: Icon(Icons.work_outlined),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _contractors.contains(_selectedContractor) ? _selectedContractor : null,
                decoration: const InputDecoration(
                  labelText: 'Contractant',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                items: _contractors.map((contractor) {
                  return DropdownMenuItem(value: contractor, child: Text(contractor, overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (v) => setState(() => _selectedContractor = v),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    auth.updateUser(
      user.copyWith(
        login: _loginController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        role: _selectedRole,
        contractor: _selectedContractor,
      ),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour'), backgroundColor: Colors.green),
      );
    }
  }
}
