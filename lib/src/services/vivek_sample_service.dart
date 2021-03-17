import 'package:firebase_auth/firebase_auth.dart';

class VivekSampleService {
  FirebaseAuth auth;
  static VivekSampleService instance = VivekSampleService();

  VivekSampleService() {
    auth = FirebaseAuth.instance;
  }
}
