import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';




class PickupScheduleForm extends StatefulWidget {

  @override
  _PickupScheduleFormState createState() => _PickupScheduleFormState();
}
class _PickupScheduleFormState extends State<PickupScheduleForm> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _dateController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();
  final pickupdateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();


  void _showDatePicker() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(Duration(days: 30)),
      onConfirm: (date) {
        setState(() {
          _selectedDate = date;
          _dateController.text = _selectedDate.toString();
        });
      },
      currentTime: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Pickup'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter your phone number',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter your address',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    hintText: 'Enter your city',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: stateController,
                  decoration: InputDecoration(
                    labelText: 'State',
                    hintText: 'Enter your state',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your state';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: zipController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Zip',
                    hintText: 'Enter your zip code',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your zip code';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select pickup date'),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitForm();
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime_picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null ? _selectedDate : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (DateTime_picked != null && DateTime_picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime_picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      _formKey.currentState!.save();
      final Map<String, dynamic> data = _formKey.currentState!.value;
      data['pickupdate'] = _selectedDate;
      await _db.collection('pickup_requests').add(data);
      final String emailBody =
          'Thank you for your donation! Your pickup is scheduled for ${_selectedDate.toString()}.';
      final Email email = Email(
        body: emailBody,
        subject: 'Donation Pickup',
        recipients: [data['email']],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
      /*final SmsSender sender = SmsSender();
      final SmsMessage message = SmsMessage(
        '${data['phone']}',
        'Thank you for your donation! Your pickup is scheduled for ${_pickupDate.toString()}.',
      );
      await sender.sendSms(message);

       */
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pickup scheduled!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a pickup date and fill out all fields.'),
        ),
      );
    }
  }

}

