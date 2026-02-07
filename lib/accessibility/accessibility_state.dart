import 'package:flutter/material.dart';

class AccessibilityState {
  // =========================
  // 🔹 ACCESSIBILITY STATES
  // =========================
  static final ValueNotifier<int> contrast = ValueNotifier(1);
  static final ValueNotifier<int> textSize = ValueNotifier(1);
  static final ValueNotifier<int> spacing = ValueNotifier(1);
  static final ValueNotifier<String> language = ValueNotifier('en');

  // =========================
  // 🔹 LANGUAGE
  // =========================
  static void toggleLanguage() {
    language.value = language.value == 'en' ? 'fr' : 'en';
  }

  // =========================
  // 🔹 GENERIC CYCLER
  // =========================
  static void cycle(ValueNotifier<int> notifier, int max) {
    notifier.value = notifier.value % max + 1;
  }

  // =========================
  // 🔹 RESET
  // =========================
  static void reset() {
    contrast.value = 1;
    textSize.value = 1;
    spacing.value = 1;
    language.value = 'en';
  }

  // =========================
  // 🔹 SPACING HELPERS
  // =========================
  static double spacingScale() {
    switch (spacing.value) {
      case 2:
        return 1.25; // comfortable
      case 3:
        return 1.5; // spacious
      default:
        return 1.0; // normal
    }
  }

  static EdgeInsets padding(double base) {
    return EdgeInsets.all(base * spacingScale());
  }

  static double gap(double base) {
    return base * spacingScale();
  }

  static String t(String en, String fr) {
    return language.value == 'fr' ? fr : en;
  }

  static String translateDescription(String text) {
    if (language.value == 'en') return text;

    final map = {
      // 1
      'Luxury beachfront resort with overwater villas and fine dining.':
          'Complexe de luxe en bord de mer avec villas sur pilotis et gastronomie raffinée.',

      // 2
      'Stylish beach resort with spa, lagoon pools, and fine restaurants.':
          'Complexe balnéaire élégant avec spa, piscines lagon et restaurants raffinés.',

      // 3
      'Romantic adults-only hotel with sea views and charming decor.':
          'Hôtel romantique réservé aux adultes avec vue sur la mer et décoration charmante.',

      // 4
      'Elegant beachfront resort offering spa and water sports.':
          'Complexe élégant en bord de mer proposant spa et sports nautiques.',

      // 5
      'Authentic Mauritian experience with island-style architecture.':
          'Expérience mauricienne authentique avec architecture de style insulaire.',

      // 6
      'Private pool villas with butler service and ocean views.':
          'Villas avec piscine privée, service de majordome et vue sur l’océan.',

      // 7
      'Tropical resort with multiple restaurants and riverside setting.':
          'Complexe tropical avec plusieurs restaurants et cadre en bord de rivière.',

      // 8
      'Golf course boutique hotel with access to dolphin tours.':
          'Hôtel boutique avec parcours de golf et accès aux excursions avec dauphins.',

      // 10
      'Eco-conscious adults-only resort with local art and cuisine.':
          'Complexe écoresponsable réservé aux adultes avec art et cuisine locale.',

      // 11
      'Modern business hotel near the harbor with rooftop pool.':
          'Hôtel d’affaires moderne près du port avec piscine sur le toit.',

      // 12
      'Wellness resort with yoga, spa treatments, and fine dining.':
          'Complexe bien-être avec yoga, soins spa et gastronomie raffinée.',

      // 13
      'Charming coastal resort with water activities and local cuisine.':
          'Charmant complexe côtier avec activités nautiques et cuisine locale.',

      // 14
      'Award-winning family-friendly resort with tropical gardens.':
          'Complexe primé adapté aux familles avec jardins tropicaux.',

      // 15
      'Mountain eco-lodge surrounded by nature and hiking trails.':
          'Écolodge de montagne entouré de nature et sentiers de randonnée.',

      // 16
      'All-inclusive resort perfect for beach lovers and honeymooners.':
          'Complexe tout compris parfait pour les amoureux de la plage et les jeunes mariés.',

      // 17
      'Adults-only resort with live music and ocean-view dining.':
          'Complexe réservé aux adultes avec musique live et restaurant vue mer.',

      // 18
      'Eco-friendly resort with snorkeling and local experiences.':
          'Complexe écologique avec snorkeling et expériences locales.',

      // 19
      'Iconic luxury resort with private beach and top-class service.':
          'Complexe de luxe emblématique avec plage privée et service haut de gamme.',

      // 20
      'Trendy beachside boutique hotel for young travelers.':
          'Hôtel boutique branché en bord de mer pour jeunes voyageurs.',
    };

    return map[text] ?? text;
  }

  //animities in french
  static String translateAmenity(String amenity) {
    if (language.value == 'en') return amenity;

    final map = {
      'wifi': 'Wi-Fi',
      'free wifi': 'Wi-Fi gratuit',
      'pool': 'Piscine',
      'infinity pool': 'Piscine à débordement',
      'private pool': 'Piscine privée',
      'spa': 'Spa',
      'restaurant': 'Restaurant',
      'organic restaurant': 'Restaurant bio',
      'gym': 'Salle de sport',
      'golf course': 'Parcours de golf',
      'snorkeling': 'Plongée en apnée',
      'kids club': 'Club enfants',
      'bar': 'Bar',
      'rooftop bar': 'Bar sur le toit',
      'tennis courts': 'Terrains de tennis',
      'private beach': 'Plage privée',
      'beach access': 'Accès à la plage',
      'room service': 'Service en chambre',
      'hiking trails': 'Sentiers de randonnée',
      'nature view': 'Vue sur la nature',
      'eco tours': 'Excursions écologiques',
      'boat excursions': 'Excursions en bateau',
      'water sports': 'Sports nautiques',
      'all-inclusive': 'Tout compris',
      'butler service': 'Service de majordome',
      'yoga classes': 'Cours de yoga',
      'yoga pavilion': 'Pavillon de yoga',
    };

    return map[amenity.toLowerCase()] ?? amenity;
  }

  // =========================
  // 🔹 GLOBAL REBUILD TRIGGER
  // =========================
  static final Listenable rebuild = Listenable.merge([
    contrast,
    spacing,
    language,
  ]);
}
