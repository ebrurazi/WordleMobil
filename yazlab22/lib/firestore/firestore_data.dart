import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreData {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");

  get currentUser => null;

  Future<void> registerUser({required String name, required String email, required String password, required String id}) async {
    // Create a new document with a unique ID in the "users" collection
    await userCollection.doc(id).set({
      "email": email,
      "name": name,
      "password": password
    });
  }
}
