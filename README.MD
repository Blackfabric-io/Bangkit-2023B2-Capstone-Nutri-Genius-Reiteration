# NutriGenius

NutriGenius is an intelligent mobile application designed to help monitor and prevent child stunting in Indonesia through advanced food recognition and growth tracking capabilities.

## Project Structure

```
nutrigenius/
├── ml/                  # Machine Learning components
│   ├── models/          # Model architectures
│   ├── data/            # Dataset management
│   └── training/        # Training scripts
├── mobile/              # Flutter application
│   ├── lib/             # Main Flutter code
│   │   ├── screens/     # UI Screens
│   │   ├── models/      # Data Models
│   │   ├── services/    # Business Logic
│   │   ├── widgets/     # Reusable Widgets
│   │   └── main.dart
│   ├── assets/          # Assets like images and models
│   ├── pubspec.yaml     # Flutter dependencies
│   └── test/            # Tests
├── cloud/               # Cloud components
│   ├── api/             # API endpoints
│   └── services/        # Cloud services configurations
├── docs/                # Documentation
└── README.md
```

## Getting Started

### Prerequisites
- Flutter SDK
- Python 3.8+
- TensorFlow 2.x
- Google Cloud SDK

### Setup Instructions
1. Clone the repository
2. Set up Flutter environment
3. Install Python dependencies
4. Configure cloud services

## Development

### Machine Learning
The ML component focuses on:
- Food image classification
- Growth prediction models
- Nutritional analysis

### Mobile Application
Flutter-based mobile app with features:
- Food recognition
- Growth tracking
- Nutritional recommendations

### Cloud Backend
Cloud infrastructure handling:
- API endpoints
- Data storage
- Model serving

## Contributing
Please read our contributing guidelines in the documentation.

## License
This project is licensed under the MIT License.