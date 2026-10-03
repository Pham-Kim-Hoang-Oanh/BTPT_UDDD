import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  File? _avatar;

  bool _isSaving = false;

  // =========================
  // CHỌN ẢNH
  // =========================

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _avatar = File(pickedFile.path);
    });
  }

  // =========================
  // LƯU DANH BẠ
  // =========================

  Future<void> _saveContact() async {
    if (_isSaving) {
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    // Kiểm tra tên
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập tên!',
          ),
        ),
      );

      return;
    }

    // Kiểm tra số điện thoại
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập số điện thoại!',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // =========================
      // XIN QUYỀN DANH BẠ
      // =========================

      final permission =
          await Permission.contacts.request();

      if (!permission.isGranted) {
        if (!mounted) return;

        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ứng dụng chưa được cấp quyền danh bạ!',
            ),
          ),
        );

        if (permission.isPermanentlyDenied) {
          await openAppSettings();
        }

        return;
      }

      // =========================
      // TÁCH TÊN
      // =========================

      final parts = name.split(
        RegExp(r'\s+'),
      );

      String givenName;
      String familyName = '';

      if (parts.length == 1) {
        givenName = parts.first;
      } else {
        familyName = parts.last;

        givenName = parts
            .sublist(
              0,
              parts.length - 1,
            )
            .join(' ');
      }

      // =========================
      // CHUẨN BỊ ẢNH
      // =========================

      final avatarBytes = _avatar != null
          ? await _avatar!.readAsBytes()
          : null;

      // =========================
      // TẠO CONTACT
      // =========================

      final contact = ContactInfo(
        givenName: givenName,
        familyName: familyName,

        phones: [
          ValueItem(
            label: 'mobile',
            value: phone,
          ),
        ],

        emails: email.isNotEmpty
            ? [
                ValueItem(
                  label: 'home',
                  value: email,
                ),
              ]
            : [],

        avatar: avatarBytes,
      );

      // =========================
      // LƯU VÀO DANH BẠ ANDROID
      // =========================

      await FlutterContactsService.addContact(
        contact,
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã lưu danh bạ thành công!',
          ),
        ),
      );

      // Quay về màn hình danh bạ
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi khi lưu danh bạ: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // GIAO DIỆN
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm danh bạ',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // ẢNH ĐẠI DIỆN
            // =========================

            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _avatar != null
                    ? FileImage(_avatar!)
                    : null,
                child: _avatar == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 45,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // TÊN
            // =========================

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // SỐ ĐIỆN THOẠI
            // =========================

            TextField(
              controller: _phoneController,
              keyboardType:
                  TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.phone,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // EMAIL
            // =========================

            TextField(
              controller: _emailController,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.email,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // NÚT LƯU
            // =========================

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _isSaving ? null : _saveContact,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(),
                      )
                    : const Text(
                        'Lưu',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    super.dispose();
  }
}