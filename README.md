# Auto OFP ✈️

A modern web tool designed to streamline your flight simulation workflow. **Auto OFP** automatically fetches real-world flight data and aircraft equipment to generate a SimBrief Operational Flight Plan (OFP) in seconds.

<div align="center">
  <a href="https://buymeacoffee.com/bongio94" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" >
  </a>
</div>

## 🚀 Features

- **Flight Details**: Extracts route and schedule information (Origin, Destination, Callsign) directly from the **FlightAware** link you provide.
- **Smart Aircraft Detection**: Uses **OpenSky Network** live api combined with a comprehensive local aircraft database (provided by OpenSky) to identify the specific aircraft type used for the flight, ensuring your SimBrief profile matches reality.
- **One-Click SimBrief Dispatch**: Pre-fills the SimBrief dispatch page with all retrieved data.
- **Manual Override**: Option to manually select an aircraft if the detected one isn't what you want.
- **Modern UI**: A sleek, dark-themed interface built with Flutter.

## 🛠️ Tech Stack

- **Framework**: Flutter (Web)
- **Aircraft Data**: [OpenSky Network](https://opensky-network.org)
- **Planning Engine**: [SimBrief](https://www.simbrief.com)

## 🔧 Usage

1. **Paste a FlightAware Link**: Copy the URL of a specific flight history (e.g., specific date) from FlightAware.
2. **Search**: Click "Generate Plan". The app will contact OpenSky to find the specific airframe details.
3. **Select Aircraft**: Choose the detected aircraft type from the grid.
4. **Dispatch**: You will be redirected to SimBrief with all flight details pre-populated.

## 🤝 Credits

- **Aircraft Data**: Provided by [The OpenSky Network](https://opensky-network.org).
- **Flight Planning**: Powered by **SimBrief**.

---

*Made with ❤️ by [bongio94](https://github.com/bongio94)*
