class LocationService {
  // Mock location data - in production, this would come from backend API
  static const List<String> districts = [
    'Chennai',
    'Coimbatore',
    'Madurai',
    'Tiruchirappalli',
    'Salem',
    'Tirunelveli',
    'Erode',
    'Vellore',
    'Thoothukudi',
    'Dindigul',
  ];

  static const Map<String, List<String>> panchayats = {
    'Chennai': [
      'Tambaram',
      'Pallavaram',
      'Chromepet',
      'Alandur',
      'Madipakkam',
    ],
    'Coimbatore': [
      'Pollachi',
      'Mettupalayam',
      'Sulur',
      'Annur',
      'Madukkarai',
    ],
    'Madurai': [
      'Melur',
      'Vadipatti',
      'Thirumangalam',
      'Usilampatti',
      'Kalligudi',
    ],
  };

  static const Map<String, Map<String, List<String>>> villages = {
    'Chennai': {
      'Tambaram': [
        'Perungalathur',
        'Chitlapakkam',
        'Selaiyur',
        'Medavakkam',
        'Sembakkam',
      ],
      'Pallavaram': [
        'Pallavaram',
        'Tirusulam',
        'Pammal',
        'Anakaputhur',
        'Cowl Bazaar',
      ],
    },
    'Coimbatore': {
      'Pollachi': [
        'Pollachi',
        'Kinathukadavu',
        'Anaimalai',
        'Valparai',
        'Udumalaipettai',
      ],
    },
  };

  static const Map<String, Map<String, Map<String, List<String>>>> wards = {
    'Chennai': {
      'Tambaram': {
        'Perungalathur': [
          'Ward 1',
          'Ward 2',
          'Ward 3',
          'Ward 4',
          'Ward 5',
        ],
        'Chitlapakkam': [
          'Ward 1',
          'Ward 2',
          'Ward 3',
        ],
      },
    },
  };

  static List<String> getPanchayats(String district) {
    return panchayats[district] ?? [];
  }

  static List<String> getVillages(String district, String panchayat) {
    return villages[district]?[panchayat] ?? [];
  }

  static List<String> getWards(String district, String panchayat, String village) {
    return wards[district]?[panchayat]?[village] ?? ['Ward 1', 'Ward 2', 'Ward 3'];
  }
}