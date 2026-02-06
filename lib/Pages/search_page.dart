import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';
import 'hotel_details_page.dart';
import '../theme/app_theme.dart';
import '../accessibility/accessibility_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  DateTimeRange? _selectedDates;
  String _selectedType = 'Any';
  String _selectedSort = 'price_low_to_high';
  Map<String, String> _selectedFilters = {};

  bool _isLoading = false;
  List<Hotel> _hotels = [];

  // --------------------- FETCH HOTELS ---------------------
  Future<void> _fetchHotels() async {
    setState(() => _isLoading = true);

    try {
      dynamic query = supabase.from('hotels').select();

      final destination = _destinationController.text.trim();
      final budget = _budgetController.text.trim();

      // Destination filter
      if (destination.isNotEmpty) {
        query = query.ilike('location', '%$destination%');
      }

      // Type filter
      if (_selectedType != 'Any') {
        query = query.eq('type', _selectedType);
      }

      // Budget filter
      if (budget.isNotEmpty) {
        final maxBudget = double.tryParse(budget);
        if (maxBudget != null) {
          query = query.lte('price_per_night', maxBudget);
        }
      }

      // Date range filter
      if (_selectedDates != null) {
        final start = _selectedDates!.start.toIso8601String();
        final end = _selectedDates!.end.toIso8601String();
        query = query.lte('available_from', end);
        query = query.gte('available_to', start);
      }

      // Category & Amenity filters
      final category = _selectedFilters['category'];
      final amenity = _selectedFilters['amenity'];
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }
      if (amenity != null && amenity.isNotEmpty) {
        query = query.contains('amenities', [amenity]);
      }

      // Sorting
      switch (_selectedSort) {
        case 'price_low_to_high':
          query = query.order('price_per_night', ascending: true);
          break;
        case 'price_high_to_low':
          query = query.order('price_per_night', ascending: false);
          break;
        case 'rating_high_to_low':
          query = query.order('rating_avg', ascending: false);
          break;
        case 'rating_low_to_high':
          query = query.order('rating_avg', ascending: true);
          break;
      }

      final data = await query;
      final hotels = (data as List).map((e) => Hotel.fromJson(e)).toList();

      setState(() => _hotels = hotels);
    } catch (e, st) {
      debugPrint('Fetch error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AccessibilityState.language.value == 1
                ? 'Erreur lors de la récupération des hôtels'
                : 'Error fetching hotels',
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --------------------- DATE PICKER ---------------------
  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDates = picked);
    }
  }

  // --------------------- SORT DIALOG ---------------------
  void _showSortDialog() async {
    final isFrench = AccessibilityState.language.value == 1;

    final result = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(isFrench ? 'Trier par' : 'Sort By'),
        children: [
          _sortOption(
            isFrench ? 'Prix : Croissant' : 'Price: Low to High',
            'price_low_to_high',
          ),
          _sortOption(
            isFrench ? 'Prix : Décroissant' : 'Price: High to Low',
            'price_high_to_low',
          ),
          _sortOption(
            isFrench ? 'Note : Décroissante' : 'Rating: High to Low',
            'rating_high_to_low',
          ),
          _sortOption(
            isFrench ? 'Note : Croissante' : 'Rating: Low to High',
            'rating_low_to_high',
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => _selectedSort = result);
      _fetchHotels();
    }
  }

  SimpleDialogOption _sortOption(String title, String value) =>
      SimpleDialogOption(
        child: Text(title),
        onPressed: () => Navigator.pop(context, value),
      );

  // --------------------- FILTER DIALOG ---------------------
  void _showFilterDialog() async {
    final isFrench = AccessibilityState.language.value == 1;
    String? category;
    String? amenity;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isFrench ? 'Filtrer les hôtels' : 'Filter Hotels'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: isFrench ? 'Catégorie' : 'Category',
                ),
                items: const [
                  DropdownMenuItem(value: 'Luxury', child: Text('Luxury')),
                  DropdownMenuItem(
                    value: 'Budget-Friendly',
                    child: Text('Budget-Friendly'),
                  ),
                  DropdownMenuItem(
                    value: 'Adventure',
                    child: Text('Adventure'),
                  ),
                  DropdownMenuItem(value: 'Resort', child: Text('Resort')),
                ],
                onChanged: (v) => category = v,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: isFrench ? 'Équipement' : 'Amenity',
                ),
                items: const [
                  DropdownMenuItem(value: 'WiFi', child: Text('Wi-Fi')),
                  DropdownMenuItem(value: 'Pool', child: Text('Pool')),
                  DropdownMenuItem(value: 'Spa', child: Text('Spa')),
                  DropdownMenuItem(
                    value: 'Restaurant',
                    child: Text('Restaurant'),
                  ),
                ],
                onChanged: (v) => amenity = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isFrench ? 'Annuler' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'category': category ?? '',
                'amenity': amenity ?? '',
              });
            },
            child: Text(isFrench ? 'Appliquer' : 'Apply'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _selectedFilters = result);
      _fetchHotels();
    }
  }

  // --------------------- UI ---------------------
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessibilityState.rebuild,
      builder: (context, _) {
        final highContrast = AccessibilityState.contrast.value >= 2;
        final isFrench = AccessibilityState.language.value == 1;

        return Scaffold(
          backgroundColor: highContrast ? Colors.black : Colors.white,
          appBar: AppBar(
            title: Text(isFrench ? 'Rechercher des hôtels' : 'Search Hotels'),
            backgroundColor: highContrast ? Colors.black : AppTheme.primaryBlue,
            foregroundColor: highContrast ? Colors.white : Colors.white,
            actions: [
              IconButton(
                onPressed: _showFilterDialog,
                icon: Icon(
                  Icons.filter_list,
                  color: highContrast ? Colors.white : Colors.white,
                ),
              ),
              IconButton(
                onPressed: _showSortDialog,
                icon: Icon(
                  Icons.sort,
                  color: highContrast ? Colors.white : Colors.white,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Destination
                TextField(
                  controller: _destinationController,
                  style: TextStyle(
                    color: highContrast ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: isFrench ? 'Destination' : 'Destination',
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: highContrast ? Colors.white : null,
                    ),
                    filled: true,
                    fillColor: highContrast
                        ? Colors.grey[850]
                        : AppTheme.lightBlue,
                  ),
                ),
                const SizedBox(height: 10),

                // Date range
                ListTile(
                  onTap: _selectDateRange,
                  tileColor: highContrast
                      ? Colors.grey[850]
                      : AppTheme.lightBlue,
                  leading: Icon(
                    Icons.calendar_today,
                    color: highContrast ? Colors.white : null,
                  ),
                  title: Text(
                    _selectedDates == null
                        ? (isFrench ? 'Sélectionner les dates' : 'Select dates')
                        : '${_selectedDates!.start.toLocal().toString().split(" ")[0]} - ${_selectedDates!.end.toLocal().toString().split(" ")[0]}',
                    style: TextStyle(
                      color: highContrast ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Budget
                TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: highContrast ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: isFrench
                        ? 'Budget maximum (Rs)'
                        : 'Max Budget (Rs)',
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: highContrast ? Colors.white : null,
                    ),
                    filled: true,
                    fillColor: highContrast
                        ? Colors.grey[850]
                        : AppTheme.lightBlue,
                  ),
                ),
                const SizedBox(height: 10),

                // Hotel Type
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  style: TextStyle(
                    color: highContrast ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: isFrench ? 'Type d’hôtel' : 'Hotel Type',
                    prefixIcon: Icon(
                      Icons.hotel,
                      color: highContrast ? Colors.white : null,
                    ),
                    filled: true,
                    fillColor: highContrast
                        ? Colors.grey[850]
                        : AppTheme.lightBlue,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Any', child: Text('Any')),
                    DropdownMenuItem(value: 'Resort', child: Text('Resort')),
                    DropdownMenuItem(value: 'Villa', child: Text('Villa')),
                    DropdownMenuItem(
                      value: 'Business',
                      child: Text('Business'),
                    ),
                    DropdownMenuItem(
                      value: 'Eco-Resort',
                      child: Text('Eco-Resort'),
                    ),
                    DropdownMenuItem(value: 'Lodge', child: Text('Lodge')),
                    DropdownMenuItem(
                      value: 'Boutique',
                      child: Text('Boutique'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
                const SizedBox(height: 20),

                // Search Button
                ElevatedButton(
                  onPressed: _fetchHotels,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    isFrench ? 'Rechercher' : 'Search',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Results
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_hotels.isEmpty)
                  Text(
                    isFrench ? 'Aucun hôtel trouvé.' : 'No hotels found.',
                    style: TextStyle(
                      color: highContrast ? Colors.white : Colors.black,
                    ),
                  )
                else
                  Column(
                    children: _hotels.map((hotel) {
                      return Card(
                        color: highContrast ? Colors.white : null,
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HotelDetailsPage(hotel: hotel),
                            ),
                          ),
                          leading: Image.network(
                            hotel.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            hotel.name,
                            style: TextStyle(
                              color: highContrast ? Colors.black : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            '${hotel.location}\nRs ${hotel.pricePerNight} / night • ${hotel.type}',
                            style: TextStyle(
                              color: highContrast
                                  ? Colors.black87
                                  : Colors.black54,
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
