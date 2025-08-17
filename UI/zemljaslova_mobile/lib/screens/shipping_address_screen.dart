import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../models/shipping_address.dart';
import '../widgets/zs_button.dart';
import 'payment_screen.dart';

class ShippingAddressScreen extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onAddressSubmitted;

  const ShippingAddressScreen({
    super.key,
    required this.totalAmount,
    required this.onAddressSubmitted,
  });

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informacije o dostavi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildAddressForm(),
              const SizedBox(height: 32),
              _buildPaymentSummary(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Adresa za dostavu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unesite informacije o adresi na koju želite da dostavimo vašu porudžbinu.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lične informacije',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: 'firstName',
                decoration: const InputDecoration(
                  labelText: 'Ime *',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Ime je obavezno'),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormBuilderTextField(
                name: 'lastName',
                decoration: const InputDecoration(
                  labelText: 'Prezime *',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Prezime je obavezno'),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Adresa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        FormBuilderTextField(
          name: 'addressLine1',
          decoration: const InputDecoration(
            labelText: 'Ulica i broj *',
            border: OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Adresa je obavezna'),
          ]),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'addressLine2',
          decoration: const InputDecoration(
            labelText: 'Dodatne informacije (opciono)',
            border: OutlineInputBorder(),
            hintText: 'Stan, sprat, dodatne napomene...',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: FormBuilderTextField(
                name: 'city',
                decoration: const InputDecoration(
                  labelText: 'Grad *',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Grad je obavezan'),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormBuilderTextField(
                name: 'postalCode',
                decoration: const InputDecoration(
                  labelText: 'Poštanski broj *',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Poštanski broj je obavezan'),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'country',
          decoration: const InputDecoration(
            labelText: 'Država *',
            border: OutlineInputBorder(),
          ),
          initialValue: 'Bosna i Hercegovina',
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Država je obavezna'),
          ]),
        ),
        const SizedBox(height: 24),
        const Text(
          'Kontakt informacije',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        FormBuilderTextField(
          name: 'phoneNumber',
          decoration: const InputDecoration(
            labelText: 'Broj telefona *',
            border: OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Broj telefona je obavezan'),
          ]),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'email',
          decoration: const InputDecoration(
            labelText: 'Email adresa (opciono)',
            border: OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.email(errorText: 'Unesite validnu email adresu'),
          ]),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pregled porudžbine',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ukupan iznos:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.totalAmount.toStringAsFixed(2)} BAM',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ZSButton(
        text: _isLoading ? 'Učitavanje...' : 'Nastavi na plaćanje',
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: _isLoading ? null : _handleSubmit,
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final formData = _formKey.currentState!.value;
        
        final shippingAddress = ShippingAddress(
          firstName: formData['firstName'],
          lastName: formData['lastName'],
          addressLine1: formData['addressLine1'],
          addressLine2: formData['addressLine2'],
          city: formData['city'],
          postalCode: formData['postalCode'],
          country: formData['country'],
          phoneNumber: formData['phoneNumber'],
          email: formData['email'],
        );

        // Call the callback with the shipping address
        widget.onAddressSubmitted();
        
        // Navigate to payment screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                totalAmount: widget.totalAmount,
                shippingAddress: shippingAddress,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}


