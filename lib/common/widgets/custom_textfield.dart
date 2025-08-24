import 'package:flutter/material.dart';
import 'package:keepit/constants/global_variables.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;


  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: GlobalVariables.greyBackgroundCOlor),
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: TextStyle(
          color: Colors.white
        ),
        
      
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(252, 198, 79, 1))
        ),

        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Enter Your $hintText';
        }
        return null;
      },
    );
  }
}

class CustomPasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomPasswordTextField({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  @override
  State<CustomPasswordTextField> createState() => _CustomPasswordTextFieldState();
}

class _CustomPasswordTextFieldState extends State<CustomPasswordTextField> {
  bool _isObsecure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: GlobalVariables.greyBackgroundCOlor),
      obscureText: _isObsecure,
      enableSuggestions: false,
      autocorrect: false,
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.hintText,
        labelStyle: TextStyle(
          color: Colors.white
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(252, 198, 79, 1))
        ),

        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),

        suffixIcon: IconButton(
          onPressed: (){
            setState(() {
              _isObsecure = !_isObsecure;
            });
          },
          icon: Icon(_isObsecure ? Icons.visibility_off : Icons.visibility, color: Color.fromRGBO(252, 198, 79, 1)),
        ) 

      ),

      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Enter Your ${widget.hintText}';
        }
        return null;
      },
    );
  }
}
