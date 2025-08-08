import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// User Model Class
class UserModel {
  final String id;
  final String email;
  final String name;
  final DateTime expectedDueDate;
  final DateTime pregnancyStartDate;
  final int currentWeek;
  final int trimester;
  final DateTime dateOfBirth;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isProfileComplete;
  final int tokens;
  final int totalTokensEarned;
  final Map<String, dynamic>? preferences;
  final List<String>? allergies;
  final double? height;
  final double? prePregnancyWeight;
  final String? bloodType;
  final List<String>? medicalConditions;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.expectedDueDate,
    required this.pregnancyStartDate,
    required this.currentWeek,
    required this.trimester,
    required this.dateOfBirth,
    required this.createdAt,
    required this.lastActiveAt,
    this.photoUrl,
    this.phoneNumber,
    this.isProfileComplete = false,
    this.tokens = 0,
    this.totalTokensEarned = 0,
    this.preferences,
    this.allergies,
    this.height,
    this.prePregnancyWeight,
    this.bloodType,
    this.medicalConditions,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'expectedDueDate': Timestamp.fromDate(expectedDueDate),
      'pregnancyStartDate': Timestamp.fromDate(pregnancyStartDate),
      'currentWeek': currentWeek,
      'trimester': trimester,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isProfileComplete': isProfileComplete,
      'tokens': tokens,
      'totalTokensEarned': totalTokensEarned,
      'preferences': preferences,
      'allergies': allergies,
      'height': height,
      'prePregnancyWeight': prePregnancyWeight,
      'bloodType': bloodType,
      'medicalConditions': medicalConditions,
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      expectedDueDate: (map['expectedDueDate'] as Timestamp).toDate(),
      pregnancyStartDate: (map['pregnancyStartDate'] as Timestamp).toDate(),
      currentWeek: map['currentWeek'] ?? 1,
      trimester: map['trimester'] ?? 1,
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastActiveAt: (map['lastActiveAt'] as Timestamp).toDate(),
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      isProfileComplete: map['isProfileComplete'] ?? false,
      tokens: map['tokens'] ?? 0,
      totalTokensEarned: map['totalTokensEarned'] ?? 0,
      preferences: map['preferences'],
      allergies: map['allergies'] != null ? List<String>.from(map['allergies']) : null,
      height: map['height']?.toDouble(),
      prePregnancyWeight: map['prePregnancyWeight']?.toDouble(),
      bloodType: map['bloodType'],
      medicalConditions: map['medicalConditions'] != null 
          ? List<String>.from(map['medicalConditions']) 
          : null,
    );
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? expectedDueDate,
    DateTime? pregnancyStartDate,
    int? currentWeek,
    int? trimester,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? photoUrl,
    String? phoneNumber,
    bool? isProfileComplete,
    int? tokens,
    int? totalTokensEarned,
    Map<String, dynamic>? preferences,
    List<String>? allergies,
    double? height,
    double? prePregnancyWeight,
    String? bloodType,
    List<String>? medicalConditions,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      expectedDueDate: expectedDueDate ?? this.expectedDueDate,
      pregnancyStartDate: pregnancyStartDate ?? this.pregnancyStartDate,
      currentWeek: currentWeek ?? this.currentWeek,
      trimester: trimester ?? this.trimester,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      tokens: tokens ?? this.tokens,
      totalTokensEarned: totalTokensEarned ?? this.totalTokensEarned,
      preferences: preferences ?? this.preferences,
      allergies: allergies ?? this.allergies,
      height: height ?? this.height,
      prePregnancyWeight: prePregnancyWeight ?? this.prePregnancyWeight,
      bloodType: bloodType ?? this.bloodType,
      medicalConditions: medicalConditions ?? this.medicalConditions,
    );
  }
}

// Fixed AuthRepository
class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Fixed: Use correct GoogleSignIn constructor
  final _googleSignIn = GoogleSignIn.standard(
    scopes: ['email'],
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last active timestamp
      if (credential.user != null) {
        await _updateLastActiveTimestamp(credential.user!.uid);
      }
      
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required DateTime expectedDueDate,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);
        
        // Create user profile in Firestore
        await _createUserProfile(
          user: credential.user!,
          name: name,
          expectedDueDate: expectedDueDate,
        );
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Fixed: Use correct property names
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if user profile exists, if not create one
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
            
        if (!userDoc.exists) {
          // Create basic profile for new Google users
          await _createBasicUserProfile(userCredential.user!);
        } else {
          // Update last active timestamp
          await _updateLastActiveTimestamp(userCredential.user!.uid);
        }
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      await user.updateEmail(newEmail);
      
      // Update email in Firestore as well
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'email': newEmail});
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      // Delete user data from Firestore first
      await _deleteUserData(user.uid);
      
      // Delete the user account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  Future<void> updateUserTokens(String uid, int tokenChange) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'tokens': FieldValue.increment(tokenChange),
        'totalTokensEarned': tokenChange > 0 ? FieldValue.increment(tokenChange) : null,
      });
    } catch (e) {
      throw Exception('Failed to update user tokens: ${e.toString()}');
    }
  }

  Future<void> updatePregnancyWeek(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final pregnancyStartDate = (userData['pregnancyStartDate'] as Timestamp).toDate();
        final currentWeek = _calculateCurrentWeek(pregnancyStartDate);
        final trimester = _calculateTrimester(currentWeek);
        
        await _firestore
            .collection('users')
            .doc(uid)
            .update({
          'currentWeek': currentWeek,
          'trimester': trimester,
          'lastActiveAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update pregnancy week: ${e.toString()}');
    }
  }

  // Private helper methods
  Future<void> _createUserProfile({
    required User user,
    required String name,
    required DateTime expectedDueDate,
  }) async {
    final pregnancyStartDate = expectedDueDate.subtract(const Duration(days: 280));
    final currentWeek = _calculateCurrentWeek(pregnancyStartDate);
    final trimester = _calculateTrimester(currentWeek);

    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      name: name,
      expectedDueDate: expectedDueDate,
      pregnancyStartDate: pregnancyStartDate,
      currentWeek: currentWeek,
      trimester: trimester,
      dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)), // Default age
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      isProfileComplete: true,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());
  }

  Future<void> _createBasicUserProfile(User user) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      name: user.displayName ?? 'User',
      expectedDueDate: DateTime.now().add(const Duration(days: 200)), // Default
      pregnancyStartDate: DateTime.now().subtract(const Duration(days: 80)), // Default
      currentWeek: 12, // Default
      trimester: 1, // Default
      dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)), // Default age
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      isProfileComplete: false, // Will need to complete profile later
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());
  }

  Future<void> _updateLastActiveTimestamp(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'lastActiveAt': Timestamp.now()});
    } catch (e) {
      // Silently handle this error as it's not critical
      print('Failed to update last active timestamp: $e');
    }
  }

  Future<void> _deleteUserData(String uid) async {
    try {
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_firestore.collection('users').doc(uid));

      // Delete user's symptoms
      final symptomsQuery = await _firestore
          .collection('symptoms')
          .where('userId', isEqualTo: uid)
          .get();
      
      for (final doc in symptomsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's meal plans
      final mealsQuery = await _firestore
          .collection('meals')
          .where('userId', isEqualTo: uid)
          .get();
      
      for (final doc in mealsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's appointments
      final appointmentsQuery = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: uid)
          .get();
      
      for (final doc in appointmentsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's community posts
      final postsQuery = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();
      
      for (final doc in postsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's tokens and transactions
      final tokensQuery = await _firestore
          .collection('tokens')
          .where('userId', isEqualTo: uid)
          .get();
      
      for (final doc in tokensQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user data: ${e.toString()}');
    }
  }

  int _calculateCurrentWeek(DateTime pregnancyStartDate) {
    final daysSinceStart = DateTime.now().difference(pregnancyStartDate).inDays;
    return (daysSinceStart / 7).floor().clamp(1, 42); // Pregnancy can go up to 42 weeks
  }

  int _calculateTrimester(int week) {
    if (week <= 12) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      case 'invalid-credential':
        return 'The authentication credential is invalid.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}