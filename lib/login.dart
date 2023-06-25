import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pharma/register.dart';
import 'package:pharma/salepage.dart';
import 'models/user.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState   extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      // Show an error message or handle empty fields
      return;
    }
    // Save user to Hive
    final userBox = Hive.box<User>('users');
    bool success = false;
    
     for (var user in userBox.values.toList()) {
      
    if (user.username == username && user.password == password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login success'),
        ),
      );
      Navigator.of(context).pop();
      Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>  SalePage(user:user,),
        
      ),);
      success=true;
      break;
  }
     }
     if(!success){
      ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:  Text('Username or password is incorrect'),
            ),
        );
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage('assets/background_image.jpg'),
          //   fit: BoxFit.cover,
          // ),
        ),
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
                
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20.0),
                 Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                  ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                ),
                  SizedBox(width: 20.0),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                        
                      ),);
                    },
                    child: Text('Register'),
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