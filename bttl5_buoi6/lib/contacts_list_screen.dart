import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'add_contact_screen.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() =>
      _ContactsListScreenState();
}

class _ContactsListScreenState
    extends State<ContactsListScreen> {
  List<ContactInfo> _contacts = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    final status =
        await Permission.contacts.request();

    if (status.isGranted) {
      await _loadContacts();
    } else {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng cấp quyền để đọc danh bạ!',
          ),
        ),
      );

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contacts =
          await FlutterContactsService.getContacts(
        withThumbnails: true,
      );

      if (!mounted) return;

      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi đọc danh bạ: $e',
          ),
        ),
      );
    }
  }

  String _getPhone(ContactInfo contact) {
    if (contact.phones == null ||
        contact.phones!.isEmpty) {
      return 'Không có số';
    }

    return contact.phones!.first.value ??
        'Không có số';
  }

  String _getEmail(ContactInfo contact) {
    if (contact.emails == null ||
        contact.emails!.isEmpty) {
      return 'Không có email';
    }

    return contact.emails!.first.value ??
        'Không có email';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh bạ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AddContactScreen(),
                ),
              );

              // Đọc lại danh bạ sau khi thêm
              await _loadContacts();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _contacts.isEmpty
              ? const Center(
                  child: Text(
                    'Không có danh bạ nào.',
                  ),
                )
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact =
                        _contacts[index];

                    return ListTile(
                      leading: contact.avatar != null
                          ? CircleAvatar(
                              backgroundImage:
                                  MemoryImage(
                                contact.avatar!,
                              ),
                            )
                          : const CircleAvatar(
                              child: Icon(
                                Icons.person,
                              ),
                            ),

                      title: Text(
                        contact.displayName ??
                            '${contact.givenName ?? ''} '
                                '${contact.familyName ?? ''}'
                                .trim(),
                      ),

                      subtitle: Text(
                        '${_getPhone(contact)}\n'
                        '${_getEmail(contact)}',
                      ),

                      isThreeLine: true,
                    );
                  },
                ),
    );
  }
}