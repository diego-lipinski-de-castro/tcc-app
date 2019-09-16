import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseUser user;
  Observable<FirebaseUser> userStream;

  AuthService() {
    userStream = Observable(_firebaseAuth.onAuthStateChanged);

    _firebaseAuth.onAuthStateChanged.listen((FirebaseUser firebaseUser) {
      user = firebaseUser;
    });
  }

  Future<bool> googleSignIn() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken
      );

      await _firebaseAuth.signInWithCredential(authCredential);

      return true;
    }  catch (error) {
      print(error);
      return false;
    } 
  }

  googleSignOut() async {
//    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}