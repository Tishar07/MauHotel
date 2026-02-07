import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import '../accessibility/accessibility_state.dart';

class PaymentPage extends StatelessWidget {
  final Hotel hotel;
  final int rooms;
  final int nights;
  final String bedType;

  const PaymentPage({
    Key? key,
    required this.hotel,
    required this.rooms,
    required this.nights,
    required this.bedType,
  }) : super(key: key);

  double get totalPrice => hotel.pricePerNight * rooms * nights;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessibilityState.rebuild,
      builder: (context, _) {
        final highContrast = AccessibilityState.contrast.value >= 2;
        final textColor = highContrast ? Colors.white : Colors.black;
        final bgColor = highContrast ? Colors.black : Colors.white;
        final inputBg = highContrast ? Colors.black : Colors.white;
        final borderColor = highContrast ? Colors.white : Colors.grey;
        final buttonBg = highContrast ? Colors.white : Colors.red;
        final buttonText = highContrast ? Colors.black : Colors.white;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              AccessibilityState.t('Payment', 'Paiement'),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: bgColor,
            iconTheme: IconThemeData(color: textColor),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // Price Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: highContrast
                        ? Colors.black
                        : const Color.fromARGB(255, 137, 190, 244),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: highContrast
                          ? Colors.white
                          : const Color.fromARGB(255, 143, 189, 233),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AccessibilityState.t(
                          'Price Details',
                          'Détails du prix',
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: highContrast ? Colors.white : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${AccessibilityState.t('Hotel', 'Hôtel')}: ${hotel.name}',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      Text(
                        '${AccessibilityState.t('Duration', 'Durée')}: $nights ${AccessibilityState.t('Night', 'Nuit')}${nights > 1 ? 's' : ''} × $rooms ${AccessibilityState.t('Room', 'Chambre')}${rooms > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      Text(
                        '${AccessibilityState.t('Bed Type', 'Type de lit')}: ${AccessibilityState.t(bedType, bedType)}',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AccessibilityState.t('Total Cost', 'Coût total')}: Rs ${totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: highContrast ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // Guest Info
                Text(
                  AccessibilityState.t(
                    'Who\'s Checking In?',
                    'Qui s\'enregistre?',
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: highContrast ? Colors.white : Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: AccessibilityState.t('First Name', 'Prénom'),
                  textColor: textColor,
                  bgColor: inputBg,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: AccessibilityState.t('Last Name', 'Nom'),
                  textColor: textColor,
                  bgColor: inputBg,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: AccessibilityState.t('Email', 'Email'),
                  textColor: textColor,
                  bgColor: inputBg,
                  borderColor: borderColor,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: AccessibilityState.t(
                    'Phone Number',
                    'Numéro de téléphone',
                  ),
                  textColor: textColor,
                  bgColor: inputBg,
                  borderColor: borderColor,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 24),
                // Payment Info
                Text(
                  AccessibilityState.t(
                    'Payment Details',
                    'Détails du paiement',
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: highContrast ? Colors.white : Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: AccessibilityState.t(
                    'Name on Card',
                    'Nom sur la carte',
                  ),
                  textColor: textColor,
                  bgColor: inputBg,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: AccessibilityState.t('Card Number', 'Numéro de carte'),
                  textColor: textColor,
                  bgColor: inputBg,
                  borderColor: borderColor,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: AccessibilityState.t(
                    'Expiry Date (MM/YY)',
                    'Date d\'expiration (MM/AA)',
                  ),
                  textColor: textColor,
                  bgColor: inputBg,
                  borderColor: borderColor,
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: AccessibilityState.t(
                    'Security Code (CVV)',
                    'Code de sécurité (CVV)',
                  ),
                  textColor: textColor,
                  bgColor: inputBg,
                  borderColor: borderColor,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),
                Text(
                  '${AccessibilityState.t('Total', 'Total')}: Rs ${totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: highContrast ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AccessibilityState.t(
                            'Payment successful!',
                            'Paiement effectué !',
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: buttonText,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(
                    AccessibilityState.t('Pay Now', 'Payer maintenant'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor),
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
      ),
    );
  }
}
