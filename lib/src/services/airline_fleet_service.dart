class AirlineFleetService {
  /// Returns a list of aircraft types (ICAO codes) common for the given airline.
  static List<String> getSuggestedAircraft(String airlineCode) {
    // Normalize to upper case
    final code = airlineCode.toUpperCase();

    // Check our static database
    if (_fleets.containsKey(code)) {
      return _fleets[code]!;
    }

    // Default fallback groups if specific airline not found
    // This is hard to guess, so maybe return empty or a generic set?
    // User asked for "Increase precision", so random guessing isn't good.
    // We return empty if we don't know the airline, letting other fallbacks handle it.
    return [];
  }

  static final Map<String, List<String>> _fleets = {
    // --- EUROPE ---
    'RYR': ['B738', 'B38M'], // Ryanair
    'EZY': ['A319', 'A320', 'A321', 'A20N', 'A21N'], // EasyJet
    'DLH': [
      'A319',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A333',
      'A343',
      'A346',
      'A359',
      'B744',
      'B748',
    ], // Lufthansa
    'BAW': [
      'A319',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A35K',
      'A388',
      'B772',
      'B77W',
      'B788',
      'B789',
      'B78X',
    ], // British Airways
    'AFR': [
      'A318',
      'A319',
      'A320',
      'A321',
      'A223',
      'A332',
      'A359',
      'B772',
      'B77W',
      'B789',
    ], // Air France
    'KLM': [
      'B737',
      'B738',
      'B739',
      'B772',
      'B77W',
      'B789',
      'B78X',
      'A332',
      'A333',
    ], // KLM
    'IBE': [
      'A319',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A332',
      'A333',
      'A359',
    ], // Iberia
    'TAP': [
      'A319',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A332',
      'A339',
    ], // TAP Air Portugal
    'SAS': [
      'A319',
      'A320',
      'A20N',
      'A321',
      'A333',
      'A359',
      'CRJ9',
      'AT76',
    ], // SAS
    'WZZ': ['A320', 'A321', 'A20N', 'A21N'], // Wizz Air
    'NAX': ['B738', 'B38M'], // Norwegian
    'VLG': ['A319', 'A320', 'A321', 'A20N', 'A21N'], // Vueling
    'THY': [
      'A319',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A332',
      'A333',
      'A359',
      'B738',
      'B739',
      'B38M',
      'B77W',
      'B789',
    ], // Turkish Airlines
    'SWR': [
      'A221',
      'A223',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A333',
      'A343',
      'B77W',
    ], // Swiss
    'FIN': ['A319', 'A320', 'A321', 'A333', 'A359', 'AT72', 'E190'], // Finnair
    'AZA': ['A319', 'A320', 'A332', 'B772'], // Alitalia (Old) - Kept for legacy
    'ITY': ['A319', 'A320', 'A20N', 'A339', 'A359'], // ITA Airways
    'AEE': ['A320', 'A321', 'A20N', 'A21N', 'DH8D', 'AT76'], // Aegean
    // --- NORTH AMERICA ---
    'AAL': [
      'A319',
      'A320',
      'A321',
      'A21N',
      'B738',
      'B38M',
      'B772',
      'B77W',
      'B788',
      'B789',
    ], // American Airlines
    'DAL': [
      'A221',
      'A223',
      'A319',
      'A320',
      'A321',
      'A21N',
      'A332',
      'A333',
      'A339',
      'A359',
      'B712',
      'B738',
      'B739',
      'B752',
      'B763',
      'B764',
    ], // Delta
    'UAL': [
      'A319',
      'A320',
      'A321',
      'A21N',
      'B737',
      'B738',
      'B739',
      'B38M',
      'B39M',
      'B752',
      'B753',
      'B763',
      'B764',
      'B772',
      'B77W',
      'B788',
      'B789',
      'B78X',
    ], // United
    'SWA': ['B737', 'B738', 'B38M'], // Southwest
    'JBU': ['A320', 'A321', 'A20N', 'A21N', 'A223', 'E190'], // JetBlue
    'ASA': ['B737', 'B738', 'B739', 'B39M', 'E175'], // Alaska
    'ACA': [
      'A223',
      'A319',
      'A320',
      'A321',
      'A333',
      'B738',
      'B38M',
      'B77L',
      'B77W',
      'B788',
      'B789',
    ], // Air Canada
    'WJA': ['B737', 'B738', 'B739', 'B38M', 'B789'], // WestJet
    'AMX': [
      'B737',
      'B738',
      'B38M',
      'B39M',
      'B788',
      'B789',
      'E190',
    ], // Aeromexico
    'VOI': ['A319', 'A320', 'A321', 'A20N', 'A21N'], // Volaris
    'FFT': ['A320', 'A321', 'A20N', 'A21N'], // Frontier
    'NKS': ['A319', 'A320', 'A321', 'A20N', 'A21N'], // Spirit
    // --- ASIA ---
    'JAL': [
      'A359',
      'A35K',
      'B738',
      'B763',
      'B772',
      'B77W',
      'B788',
      'B789',
    ], // Japan Airlines
    'ANA': [
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A388',
      'B738',
      'B763',
      'B772',
      'B77W',
      'B788',
      'B789',
      'B78X',
    ], // ANA
    'CCA': [
      'A319',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A332',
      'A333',
      'A359',
      'B737',
      'B738',
      'B38M',
      'B748',
      'B772',
      'B77W',
      'B789',
    ], // Air China
    'CSN': [
      'A319',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A332',
      'A333',
      'A359',
      'B737',
      'B738',
      'B38M',
      'B77W',
      'B788',
      'B789',
    ], // China Southern
    'CES': [
      'A319',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A332',
      'A333',
      'A359',
      'B737',
      'B738',
      'B38M',
      'B77W',
      'B789',
    ], // China Eastern
    'CPA': [
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A333',
      'A359',
      'A35K',
      'B773',
      'B77W',
    ], // Cathay Pacific
    'SIA': [
      'A359',
      'A35K',
      'A388',
      'B738',
      'B38M',
      'B77W',
      'B78X',
    ], // Singapore Airlines
    'KAL': [
      'A223',
      'A321',
      'A21N',
      'A332',
      'A333',
      'A388',
      'B738',
      'B739',
      'B38M',
      'B748',
      'B772',
      'B77W',
      'B789',
    ], // Korean Air
    'THA': ['A320', 'A359', 'B77W', 'B788', 'B789'], // Thai Airways
    'MAS': [
      'A332',
      'A333',
      'A359',
      'A388',
      'B738',
      'B38M',
    ], // Malaysia Airlines
    'GIA': ['A332', 'A333', 'A339', 'B738', 'B77W'], // Garuda Indonesia
    'VJC': ['A320', 'A321', 'A21N'], // VietJet
    'HVN': ['A321', 'A21N', 'A359', 'B789', 'B78X'], // Vietnam Airlines
    'IGO': ['A320', 'A321', 'A20N', 'A21N', 'AT76'], // IndiGo
    'AIC': [
      'A319',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'B772',
      'B77W',
      'B788',
    ], // Air India
    // --- MIDDLE EAST ---
    'UAE': ['A388', 'B77W', 'B77L'], // Emirates
    'QTR': [
      'A320',
      'A332',
      'A333',
      'A359',
      'A35K',
      'A388',
      'B738',
      'B38M',
      'B772',
      'B77W',
      'B77L',
      'B788',
      'B789',
    ], // Qatar Airways
    'ETD': ['A320', 'A321', 'A35K', 'A388', 'B77W', 'B789', 'B78X'], // Etihad
    'SVA': ['A320', 'A321', 'A21N', 'A333', 'B77W', 'B789', 'B78X'], // Saudia
    'FDB': ['B738', 'B38M'], // Flydubai
    // --- OCEANIA ---
    'QFA': ['A332', 'A333', 'A388', 'B738', 'B789', 'DH8D', 'F100'], // Qantas
    'VOZ': ['B737', 'B738', 'B38M', 'A320', 'F100'], // Virgin Australia
    'ANZ': [
      'A320',
      'A321',
      'A20N',
      'A21N',
      'B77W',
      'B789',
      'AT76',
      'DH8C',
    ], // Air New Zealand
    'JST': ['A320', 'A321', 'A20N', 'A21N', 'B788'], // Jetstar
    // --- LATIN AMERICA ---
    'TAM': [
      'A319',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'B763',
      'B77W',
      'B789',
    ], // LATAM
    'GLO': ['B737', 'B738', 'B38M'], // GOL
    'AVA': ['A319', 'A320', 'A321', 'A20N', 'B788'], // Avianca
    'CMP': ['B737', 'B738', 'B39M'], // Copa Airlines
    'AZU': [
      'A320',
      'A20N',
      'A332',
      'A339',
      'E190',
      'E195',
      'E295',
      'AT76',
    ], // Azul
    // --- AFRICA ---
    'ETH': [
      'A359',
      'B737',
      'B738',
      'B38M',
      'B763',
      'B772',
      'B77W',
      'B77L',
      'B788',
      'B789',
      'DH8D',
    ], // Ethiopian
    'RAM': ['B738', 'B38M', 'B788', 'B789', 'E190', 'AT76'], // Royal Air Maroc
    'MSR': [
      'A223',
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A332',
      'A333',
      'B738',
      'B77W',
      'B789',
    ], // EgyptAir
    'SAA': ['A319', 'A320', 'A333', 'A343', 'A346'], // South African Airways
    'KQA': ['B738', 'B788', 'E190'], // Kenya Airways
    // --- OTHERS & CARGO ---
    'FDX': ['A306', 'B752', 'B763', 'B77L', 'MD11'], // FedEx
    'UPS': ['A306', 'B744', 'B748', 'B752', 'B763', 'MD11'], // UPS
    'CLX': ['B744', 'B748'], // Cargolux
    'GTI': ['B744', 'B748', 'B763', 'B77L'], // Atlas Air
    // --- SMALLER/REGIONAL EXAMPLES ---
    'BEL': ['A319', 'A320', 'A20N', 'A333'], // Brussels Airlines
    'LOT': [
      'B738',
      'B38M',
      'B788',
      'B789',
      'E170',
      'E175',
      'E190',
      'E195',
    ], // LOT Polish
    'EIN': [
      'A320',
      'A321',
      'A20N',
      'A21N',
      'A332',
      'A333',
    ], // Aer Lingus (EIN/EI)
    'OST': ['A320', 'A321', 'A20N', 'B763', 'B772'], // Austrian
    'VOE': ['A319', 'A320'], // Volotea
  };
}
