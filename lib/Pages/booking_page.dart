import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import 'Pay_Page.dart';
import '../accessibility/accessibility_state.dart';

class BookingPage extends StatefulWidget {
  final Hotel hotel;

  const BookingPage({Key? key, required this.hotel}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int rooms = 1;
  int nights = 1;
  String bedType = 'Single';

  double get totalPrice => widget.hotel.pricePerNight * rooms * nights;

  final List<Map<String, String>> bedOptions = [
    {'en': 'Single', 'fr': 'Simple'},
    {'en': 'Double', 'fr': 'Double'},
    {'en': 'Queen', 'fr': 'Reine'},
    {'en': 'King', 'fr': 'Roi'},
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessibilityState.rebuild,
      builder: (context, _) {
        final highContrast = AccessibilityState.contrast.value >= 2;
        final textColor = highContrast ? Colors.white : Colors.black;
        final bgColor = highContrast ? Colors.black : Colors.white;
        final buttonBg = highContrast
            ? Colors.white
            : const Color.fromARGB(198, 240, 9, 9);
        final buttonText = highContrast ? Colors.black : Colors.white;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              AccessibilityState.t('Book Your Stay', 'Réservez votre séjour'),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: bgColor,
            iconTheme: IconThemeData(color: textColor),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Name
                Text(
                  widget.hotel.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: highContrast
                        ? Colors.white
                        : const Color.fromARGB(255, 13, 32, 248),
                  ),
                ),
                const SizedBox(height: 16),

                // Rooms
                _buildDropdownRow<int>(
                  label: AccessibilityState.t('Rooms', 'Chambres'),
                  value: rooms,
                  options: List.generate(5, (i) => i + 1),
                  onChanged: (val) => setState(() => rooms = val!),
                  highContrast: highContrast,
                ),

                // Nights
                _buildDropdownRow<int>(
                  label: AccessibilityState.t('Nights', 'Nuits'),
                  value: nights,
                  options: List.generate(14, (i) => i + 1),
                  onChanged: (val) => setState(() => nights = val!),
                  highContrast: highContrast,
                ),

                // Bed Type
                _buildDropdownRow<String>(
                  label: AccessibilityState.t('Bed Type', 'Type de lit'),
                  value: bedType,
                  options: bedOptions.map((b) => b['en']!).toList(),
                  onChanged: (val) => setState(() => bedType = val!),
                  highContrast: highContrast,
                  mapLabel: (val) {
                    final match = bedOptions.firstWhere((b) => b['en'] == val);
                    return AccessibilityState.t(match['en']!, match['fr']!);
                  },
                ),

                const SizedBox(height: 20),

                // Total Price
                Text(
                  '${AccessibilityState.t('Total Price', 'Prix total')}: Rs ${totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: highContrast ? Colors.white : Colors.red,
                  ),
                ),

                const Spacer(),

                // Pay Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          hotel: widget.hotel,
                          rooms: rooms,
                          nights: nights,
                          bedType: bedType,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: Text(
                    AccessibilityState.t('Pay Now', 'Payer maintenant'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: buttonText,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Generic dropdown row builder
  Widget _buildDropdownRow<T>({
    required String label,
    required T value,
    required List<T> options,
    required ValueChanged<T?> onChanged,
    required bool highContrast,
    String Function(T val)? mapLabel,
  }) {
    final textColor = highContrast ? Colors.white : Colors.black;
    final dropdownBg = highContrast ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor)),
          DropdownButton<T>(
            value: value,
            dropdownColor: dropdownBg,
            items: options
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      mapLabel != null ? mapLabel(e) : e.toString(),
                      style: TextStyle(color: textColor),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
