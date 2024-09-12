import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Model/TypesOfExpenseModel.dart';
import '../others/appbar.dart';
import 'package:path/path.dart' as p;
import '../services/UserApi.dart';
import '../utils/ShakeWidget.dart';

class AddExpenses extends StatefulWidget {
  const AddExpenses({super.key});

  @override
  State<AddExpenses> createState() => _AddExpensesState();
}

class _AddExpensesState extends State<AddExpenses> {
  final TextEditingController _expenseDescription = TextEditingController();
  final TextEditingController _expenseAmount = TextEditingController();
  final TextEditingController _expenseReason = TextEditingController();
  bool loading = false;
  bool is_submiting = false;
  bool isActive = true;
  bool _submit = false;
  String filename="";

  String? selectedKey;  // Key to be sent to the server
  String? selectedValue;
  String reason="";// Value to be displayed in the dropdown
  Map<String, String> optionsMap = {};

  FocusNode _focusAmount = FocusNode();
  FocusNode _focusReason = FocusNode();
  FocusNode _focusDescription = FocusNode();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    GetTypesOfExpenses();
    _expenseAmount.addListener(() {
      setState(() {
        _validateExpenseAmount = "";
      });
    });
    _expenseDescription.addListener(() {
      setState(() {
        _validateExpenseDescription = "";
      });
    });
  }

  @override
  void dispose() {
    _expenseAmount.dispose();
    _expenseReason.dispose();
    _expenseDescription.dispose();
    _focusAmount.dispose();
    _focusReason.dispose();
    _focusDescription.dispose();
    super.dispose();
  }

  List<Data> dataList =[];
  Future<void> GetTypesOfExpenses() async {
    final response = await Userapi.GetTypesOfExpensesApi();
    if (response != null) {
      setState(() {
        if (response.settings?.success == 1) {
          dataList=response.data??[];
          for (var data in dataList) {
            if (data.expenseName != null && data.uid != null) {
              optionsMap[data.uid!] = data.expenseName!;
            }
          }
        }
      });
    } else {

    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) return;

      final storageStatus = Platform.version.compareTo("10") >= 0
          ? await Permission.manageExternalStorage.status
          : await Permission.storage.status;

      if (!storageStatus.isGranted) {
        final status = Platform.version.compareTo("10") >= 0
            ? await Permission.manageExternalStorage.request()
            : await Permission.storage.request();

        if (!status.isGranted) return;
      }
    }
  }

  Future<void> _pickImageFromGallery(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source:source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        filename= p.basename(pickedFile.path!);
      });
    }
  }

  Future<void> _submitExpenses() async {
    if (_selectedImage == null) return;
    final myExpenses = await Userapi.AddExpenseApi(
      _expenseDescription.text,
      selectedValue!,
      _expenseAmount.text,
      _selectedImage!,
    );
    setState(() {
      if (myExpenses != null) {
        if( myExpenses.settings?.success==1){
          is_submiting=false;
          Navigator.pop(context,true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Expense Added successfully!",
              style: TextStyle(color: Color(0xff000000)),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFFF6821F),
          ));
        }else{
          is_submiting=false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              myExpenses?.settings?.message??"",
              style: TextStyle(color: Color(0xff000000)),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFFF6821F),
          ));
        }
      }
    });
  }

  String _validateExpenseDescription="";
  String _validateExpenseAmount="";
  String _validateExpenseReason="";
  String _validateimage="";
  void _validateFields() {
    String? validateExpenseDescription;
    String? validateExpenseAmount;
    String? validateExpenseReason;
    String? validateimage;
    if (_expenseDescription.text == null || _expenseDescription.text.isEmpty) {
      validateExpenseDescription = "Please enter the expense description";
    }

    if (_expenseAmount.text == null || _expenseAmount.text.isEmpty) {
      validateExpenseAmount = "Please enter the expense amount";
    } else {
      // Check if amount is a valid number
      final amount = double.tryParse(_expenseAmount.text);
      if (amount == null || amount <= 0) {
        validateExpenseAmount = "Please enter a valid expense amount";
      }
    }

    if (reason=="") {
      print("kbdvkbvksjbvskbvkbvk");
      validateExpenseReason = "Please select the reason for the expense";
    }

    if (_selectedImage == null) {
      validateimage = "Please select image of bill";
    }

    // Check if any validations failed
    if (validateExpenseDescription != null ||
        validateExpenseAmount != null ||
        validateimage != null ||
        validateExpenseReason != null) {
      setState(() {
        _validateExpenseDescription = validateExpenseDescription ?? "";
        _validateExpenseAmount = validateExpenseAmount ?? "";
        _validateExpenseReason = validateExpenseReason ?? "";
        _validateimage = validateimage ?? "";
        is_submiting=false;
      });
    } else {
      _submitExpenses();
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return
      WillPopScope(
        onWillPop: () async {
          Navigator.pop(context,true);
          return false; // Prevents the back navigation
        },
        child: Scaffold(
        appBar: CustomAppBar(
          title: "Add Expense",
        ),
        body: loading
            ? Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF6821F),
          ),
        )
            : SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildLabelText("Expense Description"),
              _buildTextField("Description", _expenseDescription, _focusDescription,TextInputType.text),
              if (_validateExpenseDescription.isNotEmpty) ...[
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 8,bottom: 10,top: 5),
                  width: screenWidth * 0.8,
                  child: ShakeWidget(
                    key: Key("value"),
                    duration: Duration(milliseconds: 700),
                    child: Text(
                      _validateExpenseDescription,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color:Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(
                  height: 18,
                ),
              ],
                Text(
                  "Reason",
                  style: TextStyle(
                    color: Color(0xFF32657B),
                    fontFamily: "Inter",
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              DropdownButtonFormField<String>(
                value: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                    selectedKey = optionsMap[value!]!;
                    reason = optionsMap[value!]!;
                    _validateExpenseReason="";
                  });
                  print('Selected key to send to server: $selectedValue');
                },
                items: optionsMap.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key, // The key is used as the value
                    child: Text(
                      entry.value, // The value is displayed as text
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0,
                        height: 1.2,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xffffffff),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(width: 1, color: Color(0xffCDE2FB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(width: 1, color: Color(0xffCDE2FB)),
                  ),
                ),
                hint: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Select type of expense",
                    style: TextStyle(
                      fontSize: 15,
                      letterSpacing: 0,
                      color: Color(0xffAFAFAF),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (_validateExpenseReason.isNotEmpty) ...[
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 8,bottom: 10,top: 5),
                  width: screenWidth * 0.8,
                  child: ShakeWidget(
                    key: Key("value"),
                    duration: Duration(milliseconds: 700),
                    child: Text(
                      _validateExpenseReason,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color:Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(
                  height: 18,
                ),
              ],
              _buildLabelText("Expense Amount"),
              _buildTextField("Amount", _expenseAmount, _focusAmount,TextInputType.number),
              if (_validateExpenseAmount.isNotEmpty) ...[
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 8,bottom: 10,top: 5),
                  width: screenWidth * 0.8,
                  child: ShakeWidget(
                    key: Key("value"),
                    duration: Duration(milliseconds: 700),
                    child: Text(
                      _validateExpenseAmount,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color:Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(
                  height: 18,
                ),
              ],
              _buildLabelText("Expense Bill"),
              _buildStyledContainer("Upload Bill", Icon(Icons.file_upload_outlined, color: Color(0xFFF6821F))),
              if (_validateimage.isNotEmpty) ...[
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 8,bottom: 10,top: 5),
                  width: screenWidth * 0.8,
                  child: ShakeWidget(
                    key: Key("value"),
                    duration: Duration(milliseconds: 700),
                    child: Text(
                      _validateimage,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color:Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(
                  height: 20,
                ),
              ],
              SizedBox(height: 100,),
              Center(
                child: InkWell(
                  onTap:(){
                    if(is_submiting){

                    }else{
                      setState(() {
                        is_submiting=true;
                        _validateFields();
                      });
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 250,
                    padding: EdgeInsets.only(left: 15,right: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFFF6821F),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: (is_submiting)?
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                     : Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
            ),
      );
  }

  Widget _buildLabelText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xFF32657B),
        fontFamily: "Inter",
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildStyledContainer(String label, [Widget? suffixIcon]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4),
        InkWell(
          onTap:(){
            setState(() {
              _validateimage="";
            });
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SafeArea(
                  child: Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text('Take a photo'),
                        onTap: () {
                          _pickImageFromGallery(ImageSource.camera);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Choose from gallery'),
                        onTap: () {
                          _pickImageFromGallery(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Color(0xffCDE2FB), width: 1),
            ),
            child: Row(
              children: [
                _selectedImage == null
                    ? Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xffAFAFAF),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                )
                    :
                Container(
                  width:MediaQuery.of(context).size.width*0.8,
                  child: Text("$filename",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily:"Inter",
                      fontSize: 13,
                    ),
                  ),
                ),
                Spacer(),
                if (suffixIcon != null && _selectedImage == null) suffixIcon,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, FocusNode focusNode,TextInputType keyboardType,[Widget? suffixIcon]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: "Enter $label",
            hintStyle: TextStyle(
              fontSize: 15,
              color: Color(0xffAFAFAF),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(width: 1, color: Color(0xffCDE2FB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(width: 1, color: Color(0xffCDE2FB)),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

}