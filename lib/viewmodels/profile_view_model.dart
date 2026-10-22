import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// State management untuk profil pengguna (MVVM).
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel() : _profile = kDemoUserProfile;

  UserProfile _profile;

  UserProfile get profile => _profile;

  /// Simpan perubahan profil dari EditProfileScreen.
  void saveProfile(UserProfile updated) {
    _profile = updated;
    notifyListeners();
  }

  /// Toggle ikuti/batal mengikuti dari layar lain (placeholder).
  void toggleFollow() {
    _profile = _profile.copyWith(
      followers: _profile.followers + 1,
    );
    notifyListeners();
  }
}
