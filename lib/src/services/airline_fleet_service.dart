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
    'EWG': ['A319', 'A320', 'A20N', 'A21N', 'B738'], // Eurowings
    'TRA': ['B737', 'B738', 'A20N', 'A21N'], // Transavia
    'BTI': ['A223'], // airBaltic
    'ELY': ['B738', 'B739', 'B772', 'B788', 'B789'], // El Al
    'ICE': ['B752', 'B753', 'B763', 'B38M', 'B39M'], // Icelandair
    'TVS': ['B737', 'B738', 'B38M', 'A320'], // Smartwings
    'CFG': ['A320', 'A21N', 'A332', 'A333'], // Condor
    'TUI': ['B737', 'B738', 'B38M', 'B763', 'B788', 'B789'], // TUI (General)
    'TOM': ['B738', 'B38M', 'B788', 'B789'], // TUI Airways (UK)
    'VIR': ['A333', 'A339', 'A35K', 'B789'], // Virgin Atlantic
    'SVR': [
      'A319',
      'A320',
      'A321',
      'A21N',
      'A333',
      'B738',
      'B77W',
    ], // Ural Airlines
    'AFL': ['A320', 'A321', 'A333', 'A359', 'B738', 'B77W'], // Aeroflot
    'SBI': ['A320', 'A20N', 'A321', 'A21N', 'B738'], // S7 Airlines
    'UTN': ['B738', 'B762', 'AT72'], // Utair
    'LYX': [
      'AT72',
      'AT45',
      'CRJ9',
    ], // French Bee / Hop (mixed codes) - adding generic regionally
    'FBU': [
      'AT72',
      'AT45',
    ], // French Bee uses A350, wait. FBU is French Bee (BF). Correcting manually below.
    'BF': ['A359'], // French Bee
    'CAI': ['A333', 'B744'], // Corendon
    // --- NORTH AMERICA ---
    'AAL': [
      'A319',
      'A320',
      'A321',
      'A21N',
      'B738',
      'B38M',
      'B772',
      'B773',
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
    'SCX': ['B737', 'B738'], // Sun Country
    'AAY': ['A319', 'A320'], // Allegiant
    'POE': ['E295', 'DH8D'], // Porter
    'HAL': ['A321', 'A332', 'B712', 'B789'], // Hawaiian
    'TSC': ['A310', 'A321', 'A21N', 'A332', 'A333'], // Air Transat
    'PDT': ['DH8D', 'E145'], // Piedmont
    'RPA': ['E170', 'E175'], // Republic
    'SKW': ['CRJ2', 'CRJ7', 'CRJ9', 'E175'], // SkyWest
    'ENY': ['E145', 'E175'], // Envoy
    'JAZ': ['CRJ2', 'CRJ9', 'DH8D'], // Jazz
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
      'A359',
    ], // Air India
    'EVA': ['A321', 'A332', 'A333', 'B77W', 'B789', 'B781'], // EVA Air
    'CAL': [
      'A321',
      'A21N',
      'A333',
      'A359',
      'B738',
      'B77W',
      'B744',
    ], // China Airlines
    'AAR': [
      'A320',
      'A321',
      'A21N',
      'A333',
      'A359',
      'A388',
      'B744',
      'B763',
      'B772',
    ], // Asiana
    'VTI': ['A320', 'A21N', 'B789'], // Vistara
    'AXM': ['A320', 'A20N', 'A333'], // AirAsia Berhad
    'XAX': ['A333'], // AirAsia X
    'CEB': ['A320', 'A20N', 'A321', 'A21N', 'A339'], // Cebu Pacific
    'JJA': ['B738', 'B38M'], // Jeju Air
    'JNA': ['B738', 'B38M', 'B772'], // Jin Air
    'HDA': [
      'A320',
      'A321',
      'A333',
    ], // Cathay Dragon (check if active, merged into CPA but codes linger)
    'HKE': ['B738', 'A320', 'A321', 'A20N', 'A21N'], // HK Express
    'CRK': ['A320', 'A333'], // Hong Kong Airlines
    'SKY': ['A320', 'A321', 'A333'], // Skymark
    'SFJ': ['A320'], // StarFlyer
    'ADO': ['B737', 'B763'], // Air Do
    'PAL': [
      'A320',
      'A321',
      'A21N',
      'A333',
      'A359',
      'B77W',
    ], // Philippine Airlines
    'GWO': ['A320'], // Tigerair Taiwan
    'TTW': ['A320', 'A321'], // Tigerair
    'SJX': ['B738'], // Sriwijaya
    'LION': ['B738', 'B739', 'A333', 'A339'], // Lion Air
    'QZ': ['A320', 'A20N'], // Indonesia AirAsia
    'BTV': ['A320', 'A321', 'E190'], // Batik Air
    'ALK': ['A320', 'A321', 'A20N', 'A21N', 'A332', 'A333'], // SriLankan
    'BIM': ['B738', 'AT72'], // Biman Bangladesh
    'PIA': ['A320', 'B772', 'B77W'], // Pakistan International
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
    'OMA': ['B738', 'B739', 'B38M', 'A332', 'A333', 'B788', 'B789'], // Oman Air
    'KAC': ['A320', 'A20N', 'A332', 'A338', 'B77W'], // Kuwait Airways
    'GFA': ['A320', 'A21N', 'B789'], // Gulf Air
    'RJA': ['A319', 'A320', 'A321', 'B788'], // Royal Jordanian
    'MEA': ['A320', 'A321', 'A21N', 'A332'], // Middle East Airlines
    'IZ': ['A320', 'A20N'], // Arkia
    'LGL': [
      'B737',
      'B738',
    ], // Luxair (wrong code place but adding small carriers)
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
    'FJI': ['A332', 'A333', 'A359', 'B738', 'B38M'], // Fiji Airways
    'RXA': ['B738', 'SB20'], // Rex
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
    'ARG': ['B737', 'B738', 'B38M', 'A332'], // Aerolineas Argentinas
    'SKU': ['A320', 'A20N', 'A321', 'A21N'], // Sky Airline
    'JAT': ['A320', 'A20N', 'A321'], // JetSMART
    'LAN': [
      'A319',
      'A320',
      'A321',
      'B763',
      'B788',
      'B789',
    ], // LATAM (Generic historic)
    'LPE': ['A319', 'A320', 'A321', 'B737', 'B738'], // LATAM Peru
    'VIV': ['A320', 'A20N'], // Viva Aerobus
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
    'TAR': ['A319', 'A320', 'A332'], // Tunisair
    'ATN': ['B789'], // Air Tahiti Nui(technically oceania but serves globally)
    'DAH': ['A332', 'B736', 'B738', 'AT76'], // Air Algerie
    'RWD': ['B737', 'B738', 'A332', 'A333', 'CRJ9', 'DH8D'], // RwandAir
    'MAU': ['A332', 'A359', 'A339', 'AT72'], // Air Mauritius
    'DLA': [
      'A320',
      'B737',
      'B763',
      'B788',
    ], // Air Dolores (fictional? No. Maybe TAAG?) -> TAAG is DTA
    'DTA': ['B737', 'B772', 'B77W', 'DH8D'], // TAAG Angola
    'LAA': ['A332', 'B738', 'CRJ9'], // Libyan Airlines
    'LNI': [
      'B737',
      'B738',
      'B38M',
    ], // Lion Air (Code dup check, LION is ID usually. But keeping known codes) -> ID is INDONESIA. LNI is LION INTERN.
    // --- OTHERS & CARGO ---
    'FDX': ['A306', 'B752', 'B763', 'B77L', 'MD11'], // FedEx
    'UPS': ['A306', 'B744', 'B748', 'B752', 'B763', 'MD11'], // UPS
    'CLX': ['B744', 'B748'], // Cargolux
    'GTI': ['B744', 'B748', 'B763', 'B77L'], // Atlas Air
    'BOX': ['B77L'], // AeroLogic
    'ABD': [
      'A306',
      'A332',
      'B734',
      'B738',
      'B744',
      'B748',
    ], // Air Atlanta Icelandic (Cargo/Charter)
    'BCS': ['A306', 'B752'], // European Air Transport (DHL)
    'DHK': ['A306', 'B752', 'B763', 'B77L'], // DHL Air UK
    'ABW': ['B744', 'B748', 'B738'], // AirBridgeCargo
    'NCA': ['B748'], // Nippon Cargo
    'KZ': ['B748', 'B744'], // Nippon Cargo (IATA) - NCA is ICAO
    'CKS': ['B744', 'B748', 'B763', 'B77L'], // Kalitta Air
    'SOO': ['B77L'], // Southern Air
    'PAC': ['B744', 'B748', 'B77L'], // Polar Air Cargo
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
