import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as Path;
import 'package:http/http.dart' as http;

//import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
 

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   //List<File> _images = [];
   //Reference sightingRef =FirebaseStorage.instance.collection('image').doc();
  File _image; // Used only if you need a single picture
  String _uploadedFileURL; 


  Future uploadFile() async {    
   Reference storageReference = FirebaseStorage.instance    
       .ref()    
       .child('image/${Path.basename(_image.path)}}');    
   Task uploadTask = storageReference.putFile(_image);    
   await uploadTask.whenComplete;    
   print('File Uploaded');    
   storageReference.getDownloadURL().then((fileURL) {    
     setState(() {    
       _uploadedFileURL = fileURL;    
     });    
   });    
 }  
 void retrieveFile() async{
           _uploadedFileURL != null    
               ? Image.network(    
                   _uploadedFileURL,    
                   height: 150,    
                 )    
               : Container();
 }
  
//saveImages(_images,sightingRef);

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if (gallery) {
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
      Navigator.of(this.context).pop();
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile = await picker.getImage(
        source: ImageSource.camera,
      );
      Navigator.of(this.context).pop();
    }

    setState(() {
      if (pickedFile != null) {
        //  _images.add(File(pickedFile.path));
        _image = File(pickedFile.path);

        // Use if you only need a single picture
      } else {
        print('No image selected.');
      }
    });
  }

  void _showDialog() {
    showDialog(
      context: this.context,
      builder: (ctx) => Center(
        child: Container(
          padding: EdgeInsets.all(5),
          height: 300,
          width: 350,
          child: AlertDialog(
            title: Text('Upload Image'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                    onPressed: () {
                      getImage(false);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Photo with Camera',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                        Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.black54,
                        ),
                      ],
                    )),
                TextButton(
                    onPressed: () => _image == null
                        ? getImage(true)
                        : Navigator.of(this.context).pop(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Photo from Gallery',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                        Icon(
                          Icons.photo,
                          color: Colors.black54,
                        ),
                      ],
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.of(this.context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                        SizedBox(
                          width: 33,
                        ),
                        Icon(
                          Icons.cancel_rounded,
                          color: Colors.black54,
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  // This method is rerun every time setState is called, for instance as done
  // by the _incrementCounter method above.
  //
  // The Flutter framework has been optimized to make rerunning build methods
  // fast, so that you can just rebuild anything that needs updating rather
  // than having to individually change instances of widgets.

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Start Uploading Image'),
      ),
      body: _image == null
          ? Center(
              child: Container(
              width: 250,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.orange,
              ),
              child: TextButton(
                  onPressed: _showDialog,
                  child: Text('Upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ))),
            ))
          : Container(
              padding: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: _image == null
                  ? Text('No image selected',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ))
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              width: MediaQuery.of(context).size.width,
                              child: Image.file(_image, fit: BoxFit.cover)),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Write the caption',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                //color: Colors.black,
                                // color: Colors.blue,
                              ),

                              //color: Colors.black,

                              // floatingLabelBehavior:
                              // FloatingLabelBehavior.always,
                            ),
                          ),
                           SizedBox(height:30),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Where was this photo taken?',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                //color: Colors.black,
                                //  color: Colors.blue,
                              ),

                              //color: Colors.black,

                              // floatingLabelBehavior:
                              // FloatingLabelBehavior.always,
                            ),
                          ),
                          SizedBox(height:80),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                alignment: Alignment.bottomRight,
                                height: 40,
                                width: 150,
                                color: Colors.grey[400],
                                child: TextButton(
                                  
                                  onPressed: retrieveFile,
                                  child: Center(
                                    child: Text(
                                      'Retrieve Image',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ), 
                                ),
                              ),
                          
                              Container(
                                alignment: Alignment.bottomRight,
                                height: 40,
                                width: 100,
                                color: Colors.grey[400],
                                child: TextButton(
                                  
                                  onPressed: uploadFile,
                                  child: Center(
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ), 
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),

      /*   */

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
