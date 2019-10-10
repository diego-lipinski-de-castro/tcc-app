import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String _verificationId;

  FirebaseUser user;
  Observable<FirebaseUser> userStream;

  AuthService() {
    _firebaseAuth.setLanguageCode('pt-br');

    userStream = Observable(_firebaseAuth.onAuthStateChanged);

    _firebaseAuth.onAuthStateChanged.listen((FirebaseUser firebaseUser) {
      user = firebaseUser;
    });
  }

  Future<FirebaseUser> currentUser() async {
    try {
      return (await _firebaseAuth.currentUser());
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> confirmPhone(smsCode) async {
    try {
      AuthCredential phoneAuthProvider =
          PhoneAuthProvider.getCredential(verificationId: _verificationId, smsCode: smsCode);

      await user.updatePhoneNumberCredential(phoneAuthProvider);

      return true;
    } catch (error) {
      print(error);

      return false;
    }
  }

  Future<bool> verifyPhone(phoneNumber) async {
    phoneNumber = '+55$phoneNumber';

    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: Duration(seconds: 60),
          // int forceResendingToken,
          verificationCompleted: (AuthCredential authCredential) {
            print('verificationCompleted');
          },
          verificationFailed: (AuthException authException) {
            print('verificationFailed');
            print(authException.code);
            print(authException.message);
          },
          codeSent: (String codeSent, [int number]) {
            print('codeSent');
            _verificationId = codeSent;
          },
          codeAutoRetrievalTimeout: (String timeout) {
            print('timeout');
            _verificationId = timeout;
          });

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      await _firebaseAuth.signInWithCredential(authCredential);

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  googleSignOut() async {
//    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}