import 'package:flutter/material.dart';
import 'package:flutter_group_sliver/flutter_group_sliver.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class BounceScrollBehavior extends ScrollBehavior {
  @override
  getScrollPhysics(_) => const BouncingScrollPhysics();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  @override
  Widget build(BuildContext context) {
    double spaceBetween = 20.0;
    Color sliverColor = Colors.yellow[600];
    return MaterialApp(
      home: ScrollConfiguration(
        behavior: BounceScrollBehavior(), 
        child: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            backgroundColor: sliverColor,
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  leading: IconButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  floating: true,
                  pinned: true,
                  snap: false,
                  backgroundColor: sliverColor,
                  title: Text('Welcome to myRestaurant', style: TextStyle(fontFamily: 'Sriracha'),),
                  flexibleSpace: new FlexibleSpaceBar(
                    titlePadding: EdgeInsets.fromLTRB(0,80,0,30),
                    title: Text('Create an account'),
                    centerTitle: true,
                    collapseMode: CollapseMode.none,
                  ),
                  // bottom: PreferredSize(child: Icon(Icons.linear_scale,size: 60.0,), preferredSize: Size.fromHeight(50.0)),
                  expandedHeight: 200.0,
                ),
                SliverGroupBuilder(
                  padding: EdgeInsets.fromLTRB(15,30,15,0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                      // border: Border.all(color: Color.fromRGBO(238, 237, 238, 1))
                  ),
                  child: SliverList(
                    delegate: new SliverChildListDelegate([
                      TextField(
                        onChanged: (String str){
                          setState(() {
                            
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.restaurant),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          labelText: 'Organization name',
                          //hintText: 'Name of New Menu',
                          labelStyle: TextStyle(fontSize: 17),
                        ),
                      ),
                      SizedBox(
                        height: spaceBetween,
                      ),
                      TextField(
                        onChanged: (String str){
                          setState(() {
                            
                          });
                        },
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
                      TextField(
                        onChanged: (String str){
                          setState(() {
                            
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          labelText: 'Password',
                          //hintText: 'Name of New Menu',
                          labelStyle: TextStyle(fontSize: 17),
                        ),
                      ),
                      SizedBox(
                        height: spaceBetween
                      ),
                      TextField(
                        onChanged: (String str){
                          setState(() {
                            
                          });
                        },
                        decoration: InputDecoration(
                          // prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          labelText: 'Re-enter password',
                          //hintText: 'Name of New Menu',
                          labelStyle: TextStyle(fontSize: 17),
                        ),
                      ),
                      SizedBox(
                        height: spaceBetween
                      ),
                      TextField(
                        onChanged: (String str){
                          setState(() {
                            
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          labelText: 'City',
                          //hintText: 'Name of New Menu',
                          labelStyle: TextStyle(fontSize: 17),
                        ),
                      ),
                      SizedBox(
                        height: spaceBetween
                      ),
                      TextField(
                        onChanged: (String str){
                          setState(() {
                            
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          labelText: 'Address',
                          //hintText: 'Name of New Menu',
                          labelStyle: TextStyle(fontSize: 17),
                        ),
                      ),
                      SizedBox(
                        height: spaceBetween
                      ),
                      RaisedButton(
                        color: Colors.blue[300],
                        child: Text('Login', style: TextStyle(fontSize: 20,)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        onPressed: (){
                          FocusScope.of(context).requestFocus(new FocusNode());
                          // setState(() {
                          //   isLoading = true;
                          // });
                          // validateAndSubmit();
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ]),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: Container(
                    color: Colors.blue[100],
                    child: Icon(
                      Icons.sentiment_very_satisfied,
                      size: 75,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}