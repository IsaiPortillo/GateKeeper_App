import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getData() async{
  List data=[];

  CollectionReference collectionReferenceData = db.collection('data');
  QuerySnapshot queryData = await collectionReferenceData.get();

  queryData.docs.forEach((documento){
    data.add(documento.data());
  });

  return data;
}