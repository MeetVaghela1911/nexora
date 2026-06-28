import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'firestore_chat_service.dart';

/// Helper class to debug Firestore sync issues
class FirestoreDebugHelper {
  static Future<void> checkFirestoreSetup() async {
    print('\n🔍 ========== FIRESTORE DEBUG CHECK ==========');
    
    try {
      // Check Firebase Auth
      final auth = GetIt.instance<FirebaseAuth>();
      final currentUser = auth.currentUser;
      
      print('📱 Firebase Auth Status:');
      print('   - Current User: ${currentUser?.uid ?? "null"}');
      print('   - Email: ${currentUser?.email ?? "null"}');
      print('   - Display Name: ${currentUser?.displayName ?? "null"}');
      print('   - Is Authenticated: ${currentUser != null}');
      
      // Check Firestore
      final firestore = GetIt.instance<FirebaseFirestore>();
      print('\n🔥 Firestore Status:');
      print('   - Instance: ${firestore.app.name}');
      
      // Check FirestoreChatService
      try {
        final firestoreService = GetIt.instance<FirestoreChatService>();
        print('\n☁️  FirestoreChatService Status:');
        print('   - Service Available: ✅');
        print('   - Is Authenticated: ${firestoreService.isAuthenticated}');
        
        if (firestoreService.isAuthenticated) {
          // Try to read from Firestore to test connection
          print('\n🧪 Testing Firestore Connection...');
          try {
            final userId = currentUser?.uid;
            final testPath = 'users/$userId/chats';
            final snapshot = await firestore.collection(testPath).limit(1).get();
            print('   - Connection Test: ✅ Success');
            print('   - Collection Path: $testPath');
            print('   - Existing Chats Count: ${snapshot.docs.length}');
          } catch (e) {
            print('   - Connection Test: ❌ Failed');
            print('   - Error: $e');
            print('   - This might be a Firestore security rules issue');
          }
        } else {
          print('   - ⚠️  User not authenticated - sync will not work');
        }
      } catch (e) {
        print('\n☁️  FirestoreChatService Status:');
        print('   - Service Available: ❌');
        print('   - Error: $e');
        print('   - Make sure FirestoreChatService is registered in MyInstanc.dart');
      }
      
    } catch (e) {
      print('❌ Error during debug check: $e');
    }
    
    print('🔍 ============================================\n');
  }
  
  /// Test writing to Firestore
  static Future<void> testWriteToFirestore() async {
    print('\n🧪 ========== TESTING FIRESTORE WRITE ==========');
    
    try {
      final auth = GetIt.instance<FirebaseAuth>();
      final firestore = GetIt.instance<FirebaseFirestore>();
      final currentUser = auth.currentUser;
      
      if (currentUser == null) {
        print('❌ User not authenticated. Please sign in first.');
        return;
      }
      
      final userId = currentUser.uid;
      final testPath = 'users/$userId/test';
      
      print('📝 Attempting test write...');
      print('   - User ID: $userId');
      print('   - Path: $testPath');
      
      await firestore.collection(testPath).doc('test_doc').set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'This is a test write',
      });
      
      print('✅ Test write successful!');
      print('   - Check Firestore console to verify');
      
      // Clean up test document
      await firestore.collection(testPath).doc('test_doc').delete();
      print('🧹 Test document cleaned up');
      
    } catch (e, stackTrace) {
      print('❌ Test write failed!');
      print('   - Error: $e');
      print('   - Stack trace: $stackTrace');
      print('\n💡 Common issues:');
      print('   1. Firestore security rules might be blocking writes');
      print('   2. Check Firebase console for security rules');
      print('   3. Make sure user is authenticated');
      print('   4. Check internet connection');
    }
    
    print('🧪 ============================================\n');
  }
}

