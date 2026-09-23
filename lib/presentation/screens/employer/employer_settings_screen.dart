import 'package:flutter/widgets.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../repository/auth.dart';

class EmployerSettingsScreen extends StatefulWidget {
  const EmployerSettingsScreen({super.key});

  

  @override
  State<EmployerSettingsScreen> createState() => _EmployerSettingsScreenState();

}

class _EmployerSettingsScreenState extends State<EmployerSettingsScreen> {

  final AuthRepository _authRepo = AuthRepository();
  final UserRepository _userRepo = UserRepository();
  Map<String, dynamic>? _userProfile;


  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final String? userId = _authRepo.currentUser?.uid;
    
    if (userId == null) {
      return;
    }

    Map<String, dynamic>? userProfile = await _userRepo.fetchUserProfile(userId);

    print("User profile");
    print(userProfile);

    if (userProfile != null) {
      setState(() {
        _userProfile = userProfile;
        // _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}