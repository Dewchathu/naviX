import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'auth_service.dart';

class StorageService{

  static final StorageService _instance = StorageService.internal();
  factory StorageService() => _instance;
  StorageService.internal();

  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadFile(File filePath, String folderName, String fileName) async{
    final doc = await AuthService().getCurrentUserId();
    if(doc != null){
      try {
        await storage.ref('$folderName/${"${doc}_$fileName"}').putFile(filePath);
        final downloadUrl = await storage.ref('$folderName/${"${doc}_$fileName"}').getDownloadURL();
        return downloadUrl;
      }catch (e){
        debugPrint("upload error");
      }
    }
    return null;
  }

  Future<void> deleteFile(downloadUrl) async{
    try {
      return await storage.refFromURL(downloadUrl).delete();
    }catch (e){
      debugPrint("delete error");
    }
  }



}