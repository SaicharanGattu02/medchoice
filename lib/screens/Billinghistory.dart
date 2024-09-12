import 'package:fieldsenses/Model/BillingHistoryModel.dart';
import 'package:flutter/material.dart';
import 'package:fieldsenses/services/UserApi.dart';
import 'package:lottie/lottie.dart';
import '../others/appbar.dart';

class BillHistory extends StatefulWidget {
  const BillHistory({super.key});

  @override
  State<BillHistory> createState() => _BillHistoryState();
}

class _BillHistoryState extends State<BillHistory> {
  bool allBills = true;
  bool today = false;
  bool recent = false;
  bool _loading = true;


  String status="all";

  @override
  void initState() {
    super.initState();
    _getBilling();
  }



  List<Data> billhistory = [];
  Future<void> _getBilling() async{
    final data= await Userapi.GetBillingApi();
    if(data!=null){
      setState(() {
        if(data.settings?.success==1){
          _loading = false;
          billhistory=data.data??[];
        }
      });
    }
    else{
      print("data is Not Fetching");
      _loading = false;
    }

  }

  Future<void> _refreshData() async {
    setState(() {
      _loading = true;
    });
    await _getBilling();
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF4F5FA),
      appBar: CustomAppBar(
        title: "Billings",
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF6821F),
        ),
      )
          : RefreshIndicator(
        color: Color(0xffF6821F),
        onRefresh: _refreshData,  // Make sure _refreshData returns a Future
        child:
        Padding(
          padding: const EdgeInsets.only(top:20.0),
          child: ( billhistory.length!=0)?
          ListView.builder(
            itemCount: billhistory.length,
            itemBuilder: (context, index) {
              final bill = billhistory[index];
              return Container(
                margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFE1E7FD),
                      blurRadius: 2.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${bill.patient}",
                          style: const TextStyle(
                            color: Color(0xFF294DB8),
                            fontSize: 20,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹${bill.totalAmount}",
                          style: const TextStyle(
                            color: Color(0xFF359A39),
                            fontSize: 16,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Reason: ${bill.treatment}",
                        style: const TextStyle(
                          color: Color(0xFF465761),
                          fontSize: 14,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Payment Method: ${bill.paymentMethod}",
                        style: const TextStyle(
                          color: Color(0xFF465761),
                          fontSize: 14,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: Color(0xFFF6821F)),
                        const SizedBox(width: 5),
                        Text(
                          "${bill.time}",
                          style: const TextStyle(
                            color: Color(0xFF359A39),
                            fontSize: 15,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 10,),
                        const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFFF6821F)),
                        const SizedBox(width: 5),
                        Text(
                          "${bill.createdAt}",
                          style: const TextStyle(
                            color: Color(0xFF359A39),
                            fontSize: 15,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 10,),
                        if(bill.image!=null)...[
                          const Icon(Icons.view_compact_alt_outlined, size: 18, color: Color(0xFF294DB8)),
                          SizedBox(width: 10,),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.5),
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 500,
                                          child: InteractiveViewer(
                                            child: Container(
                                              child: Image.network("${bill.image}"),
                                            ),
                                            maxScale: 5,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: Icon(Icons.cancel, color: Colors.orange, size: 30),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(
                              "View Bill",
                              style: const TextStyle(
                                color: Color(0xFF294DB8),
                                fontSize: 16,
                                fontFamily: "Inter",
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF294DB8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ):
          Center(
            child: Lottie.asset(
              'assets/animations/nodata1.json',
              height: 360,
              width: 360,
            ),
          ),
        ),
      ),
    );

  }

// Widget _buildFilterButton(String label, bool isActive, VoidCallback onPressed) {
//   return InkWell(
//     onTap: onPressed,
//     child: Text(
//       label,
//       style: TextStyle(
//         color: isActive ? const Color(0xFFF6821F) : const Color(0xFF000000),
//         fontFamily: "Inter",
//         fontSize: isActive ? 20 : 18,
//         decoration: TextDecoration.underline,
//         decorationColor: isActive ? const Color(0xFFF6821F) : Colors.white,
//         fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//       ),
//     ),
//   );
// }
}