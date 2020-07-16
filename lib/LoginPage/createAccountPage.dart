import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_group_sliver/flutter_group_sliver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import './auth.dart';

class CreateAccountPage extends StatefulWidget {
  final BaseAuth auth;
  String userType;
  Color bgColor;

  CreateAccountPage({this.auth, @required this.userType, this.bgColor});
  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class BounceScrollBehavior extends ScrollBehavior {
  @override
  getScrollPhysics(_) => const BouncingScrollPhysics();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  bool hidePassword;
  String restaurantName, email, city, address, addressNo, selectedVal, restaurantMaster = '';
  int password, confirmPassword, tempPassword;
  List organizationList;
  Map chosenMaster;

  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    hidePassword = true;
    tempPassword = null;
    selectedVal = 'Select Restaurant Master';
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      debugPrint('Form is VALID. Restaurant Name: $restaurantName, Email: $email, Password: $password, City: $city, Address: $address, Address Number: $addressNo');
      return true;
    } else {
      debugPrint('Form is INVALID. Restaurant Name: $restaurantName, Email: $email, Password: $password, City: $city, Address: $address, Address Number: $addressNo');
      return false;
    }
  }

  void validateAndSubmit() async {
    if(validateAndSave()) {
      try {
        String userId = await widget.auth.createUserWithEmailAndPassword(email, password.toString());
        // FirebaseUser user = (await _auth.signInWithEmailAndPassword(email: _email, password: _password)).user;
        debugPrint('Created user: $userId');
        (widget.userType == 'Main')
        ? _addOrganization()
        : _addBranch(chosenMaster);
        debugPrint('New user added');
        // widget.userId(userId);
        // setState(() {
        //   isLoading = false;
        // });
        Navigator.of(context).pop();
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  Future<void> _addOrganization() async{
    CollectionReference reference = Firestore.instance.collection('restaurant');
    final docRef = await reference.add({
      'city': city,
      'address': address,
      'addressNo': addressNo,
      'restaurantName': restaurantName,
      'restaurantId': '',
      'branch': [],
      'email': email,
      'worker': [],
    });
    var docId = docRef.documentID;
    debugPrint('---------$docId---------');
    _addUser(docId);
  }

  Future<void> _addBranch(chosenMaster) async{
    CollectionReference reference = Firestore.instance.collection('restaurant');
    var obj = {
      'city': city,
      'address': address,
      'addressNo': addressNo,
      'restaurantName': restaurantName,
      'restaurantId': '',
      'email': email,
    };
    await reference
    .document(chosenMaster['docId'])
    .updateData({
      'branch': FieldValue.arrayUnion([obj]),
    });
    var docId = chosenMaster['docId'];
    debugPrint('---------added to $docId---------');
    _addUser(docId);
  }

  Future<void> _addUser(docId) async {
    CollectionReference restaurantReference = Firestore.instance.collection('restaurant');
    CollectionReference userReference = Firestore.instance.collection('user');
    
    List branchList = [];

    var docRef = await userReference.add({
      'authority': (widget.userType =='Main') ? 500 : 400,
      'email': email,
      'restaurant': Firestore.instance.document('/restaurant/$docId'),
      'name': restaurantName,
      'userType': widget.userType,
    });
    var user_docId = docRef.documentID;

    if(widget.userType == 'Main') 
    {
      await restaurantReference
      .document(docId)
      .updateData({
        'restaurantId': user_docId,
      });
    } 
    else if(widget.userType == 'Branch') 
    {
      debugPrint('masuk');
      var restaurantDocReference = Firestore.instance.collection('restaurant').document('$docId');

      restaurantDocReference.get().then((dataSnapshot) async {
        // branchList = dataSnapshot.data['branch'].toList();
        for(int i = 0; i < dataSnapshot.data['branch'].length; i++) {
          debugPrint('masuk2');
          branchList.add(dataSnapshot.data['branch'][i]);
          debugPrint('ini: ' + branchList[i].toString());
        }

        for(int i = 0; i < dataSnapshot.data['branch'].length; i++) {
          debugPrint('masuk3');
          if(branchList[i]['restaurantId'] == '') {
            debugPrint('ada');
            branchList[i]['restaurantId'] = user_docId;
            break;
          }
        }
        debugPrint(branchList.length.toString());
        for(int i = 0; i < branchList.length; i++) {
          debugPrint('masuk4');
          debugPrint('ini' + branchList[i].toString());
        }
        await restaurantReference
        .document(docId)
        .updateData({
          'branch': branchList,
        });
      });
    } 
  }

  Future<void> restaurantMasterSelection(BuildContext context, List restaurantList) {
    String search = '';
    List searchList = [], _temp = [];
    // for(int i = 0; i < restaurantList.length; i++){
    //   if(restaurantList[i] == search){
    //     _temp.add(restaurantList[i]);
    //   }
    // }
    // searchList = _temp;
    // _temp = [];
    debugPrint('search: $search');
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:BorderRadius.all(Radius.circular(10))
              ),
              content: Builder(
                builder: (context) {
                  var height = MediaQuery.of(context).size.height;
                  var width = MediaQuery.of(context).size.width;
                  return GestureDetector(
                    onTap: (){
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Container(
                      height: height - 300,
                      width: width - 100,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            TextField(
                              onChanged: (String str){
                                setState(() {
                                  search = str;
                                });
                                debugPrint('$search');
                                for(int i = 0; i < restaurantList.length; i++){
                                  if(restaurantList[i] == search){
                                    _temp.add(restaurantList[i]);
                                  }
                                }
                                searchList = _temp;
                                _temp = [];
                              },
                              //textAlign: TextAlign.end,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search), 
                                  onPressed: (){
                                    
                                  },
                                ),
                                // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                // enabled: enableText,
                                labelText: 'Search Restaurant',
                                labelStyle: TextStyle(fontSize: 17, fontFamily: 'Balsamiq_Sans'),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              // children: (search == '')
                              // ? restaurantList.map<Widget>((item) => choice(item)).toList()
                              // : searchList.map<Widget>((item) => choice(item)).toList(),
                              children: <Widget>[
                                SizedBox(
                                  height: 500,
                                  child: ListView.builder(
                                    itemCount: (search.length > 0) ? searchList.length: restaurantList.length,
                                    itemBuilder: (context, i) => (search.length > 0) ? choice(searchList[i]) : choice(restaurantList[i]),
                                  ),
                                )
                              ]
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            );
          }
        );
      }
    ).then((value) => setState(() {}));
  }

  Widget choice(restaurantName){
    return GestureDetector(
      onTap: (){
        setState(() {
          restaurantMaster = restaurantName['restaurantName'];
          chosenMaster = restaurantName;
          debugPrint('chosen masterId: ${restaurantName['docId']}');
        });
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Text(restaurantName['restaurantName'], style: TextStyle(fontFamily: 'Balsamiq_Sans')),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double spaceBetween = 20.0;
    double totWidth = MediaQuery.of(context).size.width-30;
    Color sliverColor = Colors.yellow[600];
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: StreamBuilder(
        stream: Firestore.instance.collection('restaurant').snapshots(),
        builder: (context, snapshot) {
          List _organizationList = [];
          Map _temp = {};
          if(!snapshot.hasData) return const SpinKitDualRing(color: Colors.red, size: 50.0,);
          for(int i = 0; i < snapshot.data.documents.length; i++) {
            // _organizationList.add(snapshot.data.documents[i]['restaurantName']);
            _temp.addAll({
              'restaurantName': snapshot.data.documents[i]['restaurantName'],
              'docId': snapshot.data.documents[i].documentID,
            });
            _organizationList.add(_temp);
            _temp = {};
          }
          // _organizationList.sort();
          _organizationList.sort((a, b) {
            return a['restaurantName'].toString().toLowerCase().compareTo(b['restaurantName'].toString().toLowerCase());
          });
          // _organizationList.insert(0, 'Select Restaurant Master');
          // organizationList = _organizationList;
          organizationList = _organizationList;
          
          // for(int i = 0; i < organizationList.length; i++){
          //   debugPrint(organizationList[i].toString());
          // }
          _organizationList = [];
          return Scaffold(
            backgroundColor: widget.bgColor,
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  leading: IconButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  floating: false,
                  pinned: false,
                  snap: false,
                  backgroundColor: Colors.transparent,
                  // title: Text('Welcome to myRestaurant', style: TextStyle(fontFamily: 'Sriracha'),),
                  flexibleSpace: new FlexibleSpaceBar(
                    titlePadding: EdgeInsets.fromLTRB(0,80,0,30),
                    title: Text('Create an account', style: TextStyle(fontFamily: 'Balsamiq_Sans', fontWeight: FontWeight.bold)),
                    centerTitle: true,
                    collapseMode: CollapseMode.none,
                  ),
                  // bottom: PreferredSize(child: Icon(Icons.linear_scale,size: 60.0,), preferredSize: Size.fromHeight(50.0)),
                  expandedHeight: 200.0,
                ),
                SliverGroupBuilder(
                  padding: EdgeInsets.fromLTRB(15,40,15,0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
                  ),
                  child: SliverList(
                    delegate: new SliverChildListDelegate([
                      new Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              validator: (value) => value.isEmpty ? 'Restaurant Name can\'t be empty' : null,
                              onSaved: (value) => restaurantName = value,
                              style: TextStyle(fontFamily: 'Balsamiq_Sans'),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.restaurant),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                labelText: 'Restaurant name',
                                //hintText: 'Name of New Menu',
                                labelStyle: TextStyle(fontSize: 17),
                              ),
                            ),
                            (widget.userType == 'Branch')
                            // ? DropdownButton<String>(
                            //   value: selectedVal,
                            //   isExpanded: true,
                            //   icon: Icon(Icons.arrow_downward),
                            //   iconSize: 24,
                            //   elevation: 16,
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontSize: 17,
                            //   ),
                            //   underline: Container(
                            //     height: 2,
                            //     color: Colors.grey,
                            //   ),
                            //   items: organizationList.map<DropdownMenuItem<String>>((String value) {
                            //       return DropdownMenuItem<String>(
                            //         value: value,
                            //         child: Text(value),
                            //       );
                            //   }).toList(),
                            //   onChanged: (String str) {
                            //     setState(() {
                            //       selectedVal = str;
                            //     });
                            //   },
                            // )
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                GestureDetector(
                                  onTap: (){
                                    restaurantMasterSelection(context, organizationList);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    padding: EdgeInsets.fromLTRB(10,10,10,10),
                                    // child: Text('Select Restaurant Master', style: TextStyle(fontFamily: 'Balsamiq_Sans')),
                                    child: (restaurantMaster.length == 0) 
                                    ? Text('Select Restaurant Master', style: TextStyle(fontFamily: 'Balsamiq_Sans'))
                                    : Text('$restaurantMaster', style: TextStyle(fontFamily: 'Balsamiq_Sans')),
                                  ),
                                ),
                              ],
                            )
                            : Container(),
                            SizedBox(
                              height: spaceBetween,
                            ),
                            TextFormField(
                              validator: (value) => value.isEmpty ? 'Email can\'t be empty' : (value.indexOf('@') == -1 || value.indexOf('.com') == -1) ? 'Email is invalid': null,
                              onSaved: (value) => email = value,
                              style: TextStyle(fontFamily: 'Balsamiq_Sans'),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.alternate_email),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                labelText: 'Email',
                                //hintText: 'Name of New Menu',
                                labelStyle: TextStyle(fontSize: 17),
                              ),
                            ),
                            SizedBox(
                              height: spaceBetween
                            ),
                            TextFormField(
                              validator: (value) => value.isEmpty ? 'Password can\'t be empty' : value.length < 5 ? 'Your password is too short' : value.length < 8 ? 'Your password is short' : null,
                              onSaved: (value) => password = int.parse(value),
                              style: TextStyle(fontFamily: 'Balsamiq_Sans'),
                              obscureText: hidePassword,
                              maxLength: 10,
                              onChanged: (String str){
                                setState(() {
                                  tempPassword = int.parse(str);
                                });
                              },
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.remove_red_eye), 
                                  onPressed: (){
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  }
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                labelText: 'Password',
                                //hintText: 'Name of New Menu',
                                labelStyle: TextStyle(fontSize: 17),
                              ),
                            ),
                            SizedBox(
                              height: spaceBetween
                            ),
                            TextFormField(
                              validator: (value) => tempPassword == null? null : value.isEmpty ? 'Confrim Password can\'t be empty' : int.parse(value) != tempPassword ? 'Re-check your password' : null,
                              onSaved: (value) => confirmPassword = int.parse(value),
                              style: TextStyle(fontFamily: 'Balsamiq_Sans'),
                              obscureText: hidePassword,
                              maxLength: 10,
                              decoration: InputDecoration(
                                // prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                labelText: 'Confirm password',
                                labelStyle: TextStyle(fontSize: 17),
                              ),
                            ),
                            SizedBox(
                              height: spaceBetween
                            ),
                            TextFormField(
                              validator: (value) => value.isEmpty ? 'City can\'t be empty' : null,
                              onSaved: (value) => city = value,
                              style: TextStyle(fontFamily: 'Balsamiq_Sans'),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.location_city),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                labelText: 'City',
                                hintText: 'Ex: Medan',
                                labelStyle: TextStyle(fontSize: 17),
                              ),
                            ),
                            SizedBox(
                              height: spaceBetween
                            ),
                            new Row(
                              children: <Widget>[
                                Container(
                                  width: totWidth*6/8-10,
                                  child: TextFormField(
                                    validator: (value) => value.isEmpty ? 'Address can\'t be empty' : (value.indexOf('JL.') != -1 || value.indexOf('jL.') != -1 || value.indexOf('jl.') != -1) ? 'Correct to "Jl."' : value.indexOf('Jl. ') == -1 ? 'Put space after "Jl."': null,
                                    onSaved: (value) => address = value,
                                    style: TextStyle(fontFamily: 'Balsamiq_Sans'),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.location_on),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      labelText: 'Address',
                                      hintText: 'Ex: Jl. Sudirman',
                                      labelStyle: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10 
                                ),
                                Container(
                                  width: totWidth*2/8,
                                  child: TextFormField(
                                    validator: (value) => value.isEmpty ? 'Address No. can\'t be empty' : null,
                                    onSaved: (value) => addressNo = value,
                                    style: TextStyle(fontFamily: 'Balsamiq_Sans'),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      // prefixIcon: Icon(Icons.location_on),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      labelText: 'No.',
                                      hintText: 'Ex: 1',
                                      labelStyle: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: spaceBetween
                      ),
                      RaisedButton(
                        color: widget.bgColor,
                        elevation: 7,
                        child: Text('Create', style: TextStyle(fontFamily: 'Balsamiq_Sans', fontSize: 20,)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        onPressed: (){
                          FocusScope.of(context).requestFocus(new FocusNode());
                          // setState(() {
                          //   isLoading = true;
                          // });
                          validateAndSubmit();
                        },
                      ),
                      SizedBox(
                        height: 70,
                      ),
                    ]),
                  ),
                ),
                // SliverFillRemaining(
                //   hasScrollBody: false,
                //   // fillOverscroll: false,
                //   child: Container(
                //     height: 400,
                //     color: Colors.blue[100],
                //     child: Icon(
                //       Icons.sentiment_very_satisfied,
                //       size: 75,
                //       color: Colors.blue[900],
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}