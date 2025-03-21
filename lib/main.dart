import 'package:flutter/material.dart';

import 'api/shipping_api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Shipment',
      theme: ThemeData(
        primarySwatch: Colors.red,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: BookShipmentScreen(),
    );
  }
}

class BookShipmentScreen extends StatefulWidget {
  @override
  _BookShipmentScreenState createState() => _BookShipmentScreenState();
}

class _BookShipmentScreenState extends State<BookShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  String? pickupAddress;
  String? deliveryAddress;
  String? selectedCourier;
  double shippingPrice = 0.0;
  List<String> couriers = ['Delhivery', 'DTDC', 'Bluedart', 'FedEx'];
  final ShippingApi _shippingApi = ShippingApi();

  void _calculatePrice() async {
    if (selectedCourier == null ||
        pickupAddress == null ||
        deliveryAddress == null ||
        _weightController.text.isEmpty) {
      return;
    }

    double? weight = double.tryParse(_weightController.text);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid weight entered')),
      );
      return;
    }

    try {
      final price = await _shippingApi.getShippingRate(
        courier: selectedCourier!,
        pickup: pickupAddress!,
        delivery: deliveryAddress!,
        weight: weight,
      );
      setState(() => shippingPrice = price);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error calculating price: $e')),
      );
    }
  }

  void _submitShipment() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Confirm Payment'),
          content: Text('Pay ₹${shippingPrice.toStringAsFixed(2)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                // Handle payment integration
              },
              child: Text('Confirm Payment'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: AppBar(
            centerTitle: true,
            title: Text(
              'Book Shipment',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                letterSpacing: 1.6,
              ),
            ),
            backgroundColor: Colors.red.shade800,
            actions: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              _buildAddressField('Pickup Address', Icons.location_on,
                  (value) => pickupAddress = value),
              SizedBox(height: 20),
              _buildAddressField('Delivery Address', Icons.location_on,
                  (value) => deliveryAddress = value),
              SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Package Weight (kg)',
                  prefixIcon: Icon(Icons.scale),
                  suffix: Text('kg'),
                ),
                validator: (value) => value!.isEmpty ? 'Enter weight' : null,
                onChanged: (_) => _calculatePrice(),
              ),
              SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade800),
                ),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: DropdownButtonFormField<String>(
                  value: selectedCourier,
                  isExpanded: true,
                  hint: Text('Select Courier'),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.red.shade800),
                  items: couriers
                      .map((courier) => DropdownMenuItem(
                            value: courier,
                            child: Text(courier),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCourier = value);
                    _calculatePrice();
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text(
                      'Estimated Price',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '₹${shippingPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.payment),
                label: Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitShipment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField(
      String label, IconData icon, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red.shade800),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      maxLines: 2,
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
      onChanged: (value) {
        onChanged(value);
        _calculatePrice();
      },
    );
  }
}
