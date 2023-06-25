import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pharma/login.dart';
import 'package:pharma/salepage.dart';
import 'models/user.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


class _RegisterPageState   extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwor1dController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  bool _passwordsMatch = true;
  void register() {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwor1dController.text;
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      // Show an error message or handle empty fields
      return;
    }
    // Save user to Hive
    final userBox = Hive.box<User>('users');
    final user = User(
      username: username,
      email: email,
      password: password,
      isAdmin: true,
      isActive: true,
      createdAt: DateTime.now(),
      orgId: DateTime.now().millisecondsSinceEpoch,
    );
    userBox.add(user);
    print("Save");
     Navigator.of(context).pop();
    Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) =>  SalePage(user:user,),
      
    ),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        
        
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/pharma.jpg',height: 200, width: 200,),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _passwor1dController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    if (value == _password2Controller.text) {
                      setState(() {
                        _passwordsMatch=true;
                      });
                        
                      } else {
                        setState(() {
                          _passwordsMatch=false;
                        });
                        
                       }
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _password2Controller,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: true,
                  onChanged: (value) { 
                    if (value == _passwor1dController.text) {
                      setState(() {
                        _passwordsMatch=true;
                      });
                        
                      } else {
                        setState(() {
                          _passwordsMatch=false;
                        });
                       
                       }
                  },
                ),
                Text(
                    _passwordsMatch ? _passwor1dController.text==''|| _password2Controller.text=='' ?   '':'Passwords match' : 'Passwords do not match',
                    style: TextStyle(
                      color: _passwordsMatch ? _passwor1dController.text==''|| _password2Controller.text=='' ? Colors.red:Colors.green : Colors.red,
                    ),),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                  ElevatedButton(
                    onPressed: register,
                    child: Text('Register'),
                  ),
                  SizedBox(width: 20.0),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                        
                      ),);
                    },
                    child: Text('Login'),
                  ),
                ],),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}