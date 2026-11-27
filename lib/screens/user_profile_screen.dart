import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/navigation_refresh_observer.dart';
import '../providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _fieldsInitialized = false;
  bool _editingPhone = false;
  bool _editingAddress = false;
  String? _savingField;
  bool _uploadingPhoto = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _saveProfileField(
    String uid,
    String field,
    TextEditingController controller,
  ) async {
    setState(() {
      _savingField = field;
      _error = null;
    });
    try {
      final reference = FirebaseFirestore.instance.collection('users').doc(uid);
      final latestProfile = await reference.get(
        const GetOptions(source: Source.server),
      );
      if (!latestProfile.exists) {
        throw StateError('The profile no longer exists.');
      }
      await reference.update({field: controller.text.trim()});
      if (mounted) {
        setState(() {
          if (field == 'phone') {
            _editingPhone = false;
          } else {
            _editingAddress = false;
          }
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Unable to save profile: $error');
      }
    } finally {
      if (mounted) setState(() => _savingField = null);
    }
  }

  Future<void> _signOut() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    if (auth.error != null) {
      setState(() => _error = 'Unable to sign out: ${auth.error}');
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _selectProfilePhoto(String uid) async {
    setState(() {
      _uploadingPhoto = true;
      _error = null;
    });
    try {
      final selected = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (selected == null || !mounted) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: selected.path,
        maxWidth: 512,
        maxHeight: 512,
        compressQuality: 85,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop profile photo',
            cropStyle: CropStyle.circle,
          ),
          IOSUiSettings(
            title: 'Crop profile photo',
            cropStyle: CropStyle.circle,
          ),
          WebUiSettings(context: context),
        ],
      );
      if (cropped == null || !mounted) return;

      final reference = FirebaseStorage.instance.ref('profile_photos/$uid.jpg');
      await reference.putData(
        await cropped.readAsBytes(),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final photoUrl = await reference.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoUrl': photoUrl,
      });
    } catch (error) {
      if (mounted) setState(() => _error = 'Unable to upload photo: $error');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User profile')),
        body: const Center(child: Text('No signed-in user')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User profile')),
      body: NavigationLoadingBody(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Unable to load profile: ${snapshot.error}'),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() ?? <String, dynamic>{};
            if (!_fieldsInitialized || !_editingPhone) {
              _phone.text = (data['phone'] as String?) ?? '';
            }
            if (!_fieldsInitialized || !_editingAddress) {
              _address.text = (data['address'] as String?) ?? '';
            }
            _fieldsInitialized = true;
            final name =
                (data['name'] as String?) ??
                user.displayName ??
                user.email?.split('@').first ??
                'User';
            final email = (data['email'] as String?) ?? user.email ?? '';
            final photoUrl = (data['photoUrl'] as String?) ?? '';

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _ProfilePhoto(url: photoUrl, name: name, radius: 64),
                          IconButton.filled(
                            tooltip: 'Change profile photo',
                            onPressed: _uploadingPhoto
                                ? null
                                : () => _selectProfilePhoto(user.uid),
                            icon: _uploadingPhoto
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(email, textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _EditableProfileField(
                  controller: _phone,
                  label: 'Contact phone',
                  icon: Icons.phone_outlined,
                  isEditing: _editingPhone,
                  isSaving: _savingField == 'phone',
                  onEdit: () {
                    setState(() {
                      _phone.text = (data['phone'] as String?) ?? '';
                      _editingPhone = true;
                      _error = null;
                    });
                  },
                  onCancel: () => setState(() {
                    _phone.text = (data['phone'] as String?) ?? '';
                    _editingPhone = false;
                  }),
                  onSave: () => _saveProfileField(user.uid, 'phone', _phone),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _EditableProfileField(
                  controller: _address,
                  label: 'Address',
                  icon: Icons.home_outlined,
                  isEditing: _editingAddress,
                  isSaving: _savingField == 'address',
                  onEdit: () {
                    setState(() {
                      _address.text = (data['address'] as String?) ?? '';
                      _editingAddress = true;
                      _error = null;
                    });
                  },
                  onCancel: () => setState(() {
                    _address.text = (data['address'] as String?) ?? '';
                    _editingAddress = false;
                  }),
                  onSave: () =>
                      _saveProfileField(user.uid, 'address', _address),
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 2,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _savingField != null || _uploadingPhoto
                      ? null
                      : _signOut,
                  child: const Text('Sign out'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EditableProfileField extends StatelessWidget {
  const _EditableProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isEditing,
    required this.isSaving,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
    required this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final TextInputType keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: !isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isEditing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Save $label',
                    onPressed: isSaving ? null : onSave,
                    icon: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                  ),
                  IconButton(
                    tooltip: 'Cancel editing $label',
                    onPressed: isSaving ? null : onCancel,
                    icon: const Icon(Icons.close),
                  ),
                ],
              )
            : IconButton(
                tooltip: 'Edit $label',
                onPressed: isSaving ? null : onEdit,
                icon: const Icon(Icons.edit),
              ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}

class UserProfileAvatar extends StatefulWidget {
  const UserProfileAvatar({required this.uid, required this.name, super.key});

  final String uid;
  final String? name;

  @override
  State<UserProfileAvatar> createState() => _UserProfileAvatarState();
}

class _UserProfileAvatarState extends State<UserProfileAvatar> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _profileStream;

  @override
  void initState() {
    super.initState();
    _updateProfileStream();
  }

  @override
  void didUpdateWidget(covariant UserProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.uid != oldWidget.uid) _updateProfileStream();
  }

  void _updateProfileStream() {
    _profileStream = widget.uid.isEmpty
        ? null
        : FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.uid.isEmpty) {
      return _ProfilePhoto(url: '', name: widget.name ?? '', radius: 18);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _profileStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        return _ProfilePhoto(
          url: (data?['photoUrl'] as String?) ?? '',
          name: (data?['name'] as String?) ?? widget.name ?? '',
          radius: 18,
        );
      },
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({
    required this.url,
    required this.name,
    required this.radius,
  });

  final String url;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        _initials(name),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: radius * 0.65),
      ),
    );
    if (url.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        url,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty);
  final words = parts.toList();
  if (words.isEmpty) return 'U';
  if (words.length == 1) {
    final word = words.first;
    return word.substring(0, word.length > 1 ? 2 : 1).toUpperCase();
  }
  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}
