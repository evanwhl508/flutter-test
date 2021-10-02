import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base/base_view_model.dart';

class LoginViewModel extends BaseViewModel {
  bool _isValid = false;
  String _email = "";
  String _password = "";

  bool get isValid => _isValid;
  String get email => _email;
  String get password => _password;

  void setEmail(String text) {
    _email = text;
    checkValid();
    // notifyListeners();
  }

  void setPassword(String text) {
    _password = text;
    checkValid();
    // notifyListeners();
  }

  void checkValid() {
    _isValid = _email.isNotEmpty && _password.isNotEmpty;
    notifyListeners();
  }
}

// class Login extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return ChangeNotifierProvider(
//       create: (ctx) => LoginViewModel(),
//       child: Consumer<LoginViewModel>(builder: (ctx, vm, _) {
//         return Scaffold(
//           appBar: AppBar(
//             title: Text("Login"),
//           ),
//           body: SafeArea(
//               child: Center(
//             child: Column(children: [
//               TextField(
//                 onChanged: (text) {
//                   vm.setEmail(text);
//                 },
//                 decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Email',
//                     hintText: 'Enter your account name'),
//               ),
//               TextField(
//                 onChanged: (text) {
//                   vm.setPassword(text);
//                 },
//                 obscureText: true,
//                 decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Password',
//                     hintText: 'Enter your password :123456'),
//               ),
//               ElevatedButton(
//                   onPressed: () {},
//                   child: Text("Login"),
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateColor.resolveWith((states) => vm.isValid ? Colors.blueAccent : Colors.grey)
//                   )
//               ),
//               Text("${vm.email} + ${vm.password}")
//             ]),
//           )),
//         );
//       }),
//     );
//   }
// }
class Login extends StatefulWidget {

  @override
  LoginState createState() => LoginState();

}

class LoginState extends BaseMVVMState<Login, LoginViewModel> {

  @override
  Widget buildChild(ctx, vm) {
    // TODO: implement buildChild
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SafeArea(
          child: Center(
            child: Column(children: [
              TextField(
                onChanged: (text) {
                  vm.setEmail(text);
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter your account name'),
              ),
              TextField(
                onChanged: (text) {
                  vm.setPassword(text);
                },
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter your password :123456'),
              ),
              ElevatedButton(
                  onPressed: () {},
                  child: Text("Login"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith((states) => vm.isValid ? Colors.blueAccent : Colors.grey)
                  )
              ),
              Text("${vm.email} + ${vm.password}")
            ]),
          )),
    );
  }

  @override
  LoginViewModel buildViewModel() => LoginViewModel();
}
