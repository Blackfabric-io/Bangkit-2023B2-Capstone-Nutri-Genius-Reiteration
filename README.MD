# NutriGenius

> This repository is a proof-of-concept mockup from a Bangkit Academy Capstone Project (Team CH2-PR635). As a TensorFlow developer, I am primarily focused on implementing and showcasing the machine learning components. Due to data availability constraints:
> - We are using dummy data for development and testing
> - The project serves as a technical demonstration of capabilities
> 
> The goal is to showcase what's technically possible in addressing Indonesia's stunting crisis, while acknowledging the real-world implementation would require proper medical datasets and expert validation.

NutriGenius began as a capstone project aimed at addressing Indonesia's childhood stunting crisis, which affects approximately 27.7% of the country's toddler population. The original team reached ~65% completion, establishing foundations in machine learning, mobile development, and cloud infrastructure.

## Core Features

### Health Monitoring
- Growth tracking (weight, height, age metrics)
- Real-time nutritional status monitoring
- Visual progress reports and analytics
- Wearables integration for continuous monitoring

### Food Analysis
- AI-powered food scanning and recognition
- Detailed nutritional composition analysis
- Personalized dietary recommendations
- Smart menu planning and recipes

### Education & Support
- Expert consultation with nutrition specialists
- Educational articles and resources
- Telemedicine integration
- Offline learning materials

## Technical Architecture

### Machine Learning (TensorFlow)
- Food image classification models
- Growth prediction algorithms
- Personalized recommendation systems
- Real-time analysis pipeline

### Mobile Development (Flutter)
- Native Android implementation
- Firebase Realtime Database integration
- Room Database for offline capabilities
- Android Wear API integration
- Camera API for food scanning

### Cloud Infrastructure
- Private & External API endpoints
- MQTT communication protocol
- Cloud Storage & Cloud SQL
- Compute Engine with dedicated IP
- Monitoring dashboard
- Logging and analytics

## Project Structure

```
nutrigenius/
├── ml/                  # Machine Learning components
│   ├── models/          # TensorFlow model architectures
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
│   │   ├── private/     # Authentication & monitoring
│   │   └── external/    # Public endpoints
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
- Firebase CLI
- Android Studio

### Setup Instructions
1. Clone the repository
2. Set up Flutter environment and dependencies
3. Install Python requirements
4. Configure Firebase project
5. Set up Google Cloud services
6. Configure local development environment





## License
This project is licensed under the MIT License.