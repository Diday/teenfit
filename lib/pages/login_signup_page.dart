import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:teenfit/models/user.dart';
import 'package:teenfit/services/authentication.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginSignupPage extends StatefulWidget {

  LoginSignupPage({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();

}

class _LoginSignupPageState extends State<LoginSignupPage>{

  final _formKey = new GlobalKey<FormState>();

  String _name;
  String _email;
  String _errorMessage;

  bool _isLoginForm;
  bool _isLoading;
  bool _isTOUChecked;

  int _selectedPendidikan = 0;
  
  List<DropdownMenuItem<int>> _pendidikanList = [];
  List<User> _userList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _birthDate = new TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _retypePassword = TextEditingController();

  void loadPendiikanList() {
    _pendidikanList = [];
    _pendidikanList.add(new DropdownMenuItem(
      child: new Text('SLTP'),
      value: 0,
    ));
    _pendidikanList.add(new DropdownMenuItem(
      child: new Text('SLTA'),
      value: 1,
    ));
    _pendidikanList.add(new DropdownMenuItem(
      child: new Text('SMK'),
      value: 2,
    ));
  }

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now) ? initialDate : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime.now());

    if (result == null) return;

    setState(() {
      _birthDate.text = new DateFormat.yMd().format(result);
    });
  }

  DateTime convertToDate(String input) {
    try 
    {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }    
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    _isTOUChecked = false;
    super.initState();
    loadPendiikanList();

    _userList = new List();
  }

  onEntryAdded(Event event) {
    setState(() {
      _userList.add(User.fromSnapshot(event.snapshot));
    });
  }

  addNewUser(String userId) {
    if (userId.length > 0) {
      User user = new User(userId, _name, _birthDate.text, _selectedPendidikan);
      _database.reference().child("user").push().set(user.toJson());
    }
  }

  // reset empty form
  void resetForm() {
    _formKey.currentState.reset();
    _birthDate.clear();
    _password.clear();
    _retypePassword.clear();
    _errorMessage = "";
  }

  // toggle form mode
  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
      _isLoading = false;
      _isTOUChecked = false;
    });
  }

  void toggleTOUChecked(){
    setState(() {
      _isTOUChecked = !_isTOUChecked;
    });
  }

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    else{
      _isLoading = false;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        if (_isLoginForm) {
          userId = await widget.auth.signIn(_email, _password.text);
          print('Signed in: $userId');
        } else {
          if (_isTOUChecked)
          {
            userId = await widget.auth.signUp(_email, _password.text);
            addNewUser(userId);
            // widget.auth.sendEmailVerification();
            _showVerifyEmailSentDialog();
            print('Signed up user: $userId');
          }
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null && _isLoginForm) {
          widget.loginCallback();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  //-------------------------- extended function ----------------------------

  @override
  Widget build(BuildContext context) {
    if(_isLoginForm) {
      return new Scaffold(
        body: Stack(
          children: <Widget>[
            _showLoginForm(),
            _showCircularProgress(),
          ],
        )
      );
    }
    else {
      return new Scaffold(
        body: Stack(
          children: <Widget>[
            _showSignupForm(),
            _showCircularProgress(),
          ],
        )
      );
    }
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showLoginForm() {
    return new Container(
      padding: EdgeInsets.all(25.0),
      child: new Form(
        key: _formKey,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            showLogo(),
            showEmailInput(),
            showPasswordInput(),
            showPrimaryButton(),
            showSecondaryButton(),
            showErrorMessage(),
          ],
        ),
      )
    );
  }

  Widget _showSignupForm() {
    return new Container(
      padding: EdgeInsets.all(25.0),
      child: new Form(
        key: _formKey,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            showLogo(),
            showNameInput(),
            showBirthDateInput(),
            showPendidikanInput(),
            showEmailInput(),
            showPasswordInput(),
            showRetypePasswordInput(),
            showCheckBox(),
            showPrimaryButton(),
            showSecondaryButton(),
            showErrorMessage(),
          ],
        ),
      )
    );
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: Image.asset('assets/teenfit-icon.png'),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Email',
          icon: new Icon(
            Icons.mail,
            color: Colors.grey,
          )
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Password harus diisi';
          }
          if (!EmailValidator.validate(value)) {
            return 'Email tidak dikenali';
          }
          return null;
        },
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        controller: _password,
        decoration: new InputDecoration(
          hintText: 'Password',
          icon: new Icon(
            Icons.lock,
            color: Colors.grey,
          )
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Password harus diisi';
          }
          if (value.length < 8) {
            return 'Minimal 8 karakter';
          }
          return null;
        },
        onSaved: (value) => _password.text = value.trim(),
      ),
    );
  }

  Widget showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Nama Lengkap',
          icon: new Icon(
            Icons.account_box,
            color: Colors.grey,
          )
        ),
        validator: (value) => value.isEmpty ? 'Nama harus diisi' : null,
        onSaved: (value) => _name = value,
      ),
    );
  }

  Widget showBirthDateInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new Row(children: <Widget>[
        new Expanded(
          child: new TextFormField(
            decoration: new InputDecoration(
              icon: const Icon(Icons.calendar_today),
              hintText: 'mm/dd/yyyy',
              labelText: 'Tanggal Lahir',
            ),
            controller: _birthDate,
            keyboardType: TextInputType.datetime,
            autofocus: false,
            onSaved: (value) => _birthDate.text = value,
        )),
        new IconButton(
          icon: new Icon(Icons.event),
          tooltip: 'Pilih Tanggal',
          onPressed: (() {
            _chooseDate(context, _birthDate.text);
          }),
        )
      ]),
    );
  }

  Widget showPendidikanInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: InputDecorator(
        decoration: InputDecoration(
          icon: const Icon(Icons.school),
        ),
        child: new DropdownButtonHideUnderline(
          child: new DropdownButton(
            isDense: true,
            autofocus: false,
            items: _pendidikanList,
            value: _selectedPendidikan,
            onChanged: (value) {
              setState(() {
                _selectedPendidikan = value;
              });
            },
            isExpanded: true,
          )
        )
      )
    );
  }

  Widget showRetypePasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Ulangi Password',
          icon: new Icon(
            Icons.lock,
            color: Colors.grey,
          )
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Password harus diisi';
          }
          if (value != _password.text) {
            return 'Ulangi password harus sama';
          }
          return null;
        },
        onSaved: (value) => _retypePassword.text = value.trim(),
      ),
    );
  }

  Widget showCheckBox(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new Checkbox(
            value: _isTOUChecked,
            onChanged: (value){toggleTOUChecked();},
            activeColor: Colors.blue,
            checkColor: Colors.white,
            tristate: false,
          ),
          Container(
            width: 250,
            child: new Text(
            'Menyetujui ketentuan penggunaan TeenFit',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: new TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300)),
          ),
        ],
      ),
    );
  }

  Widget showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          color: Colors.blue,
          child: new Text(_isLoginForm ? 'Login' : 'Buat Akun',
              style: new TextStyle(fontSize: 16.0, color: Colors.white)),
          onPressed: validateAndSubmit,
        ),
      )
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
      padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
      child: new Text(
          _isLoginForm ? 'Belum memiliki Akun? Daftar' : 'Sudah memiliki Akun? Login',
          style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.blue)),
      onPressed: toggleFormMode);
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 12.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Akun berhasil dibuat",
            style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300)
          ),
          content:
              new Text("Silahkan cek email dan segera lakukan verifikasi, kemudian coba login kembali",
              style: new TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300)
            ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                toggleFormMode();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
