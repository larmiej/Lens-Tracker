# 👁️ Contact Lenses Tracker

A simple, elegant iOS app to track your contact lens wear and never miss a replacement day again.

[![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue.svg)]()
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)]()
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green.svg)]()
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)]()

## 📱 Overview

Contact Lenses Tracker helps you monitor your contact lens wear cycle and alerts you when it's time to replace them. Perfect for bi-weekly lens wearers who need a simple way to track their usage without complicated features.

### Key Features

- ✅ **One-Tap Logging** - Quickly log when you wear your lenses with a single tap
- 📊 **Visual Progress** - Color-coded progress ring shows how close you are to replacement day
- 📅 **Calendar History** - View and manage your wear history by date
- ⚙️ **Flexible Settings** - Support for daily, bi-weekly, and monthly lenses
- 🔄 **Cycle Management** - Reset or change lens types without losing history
- 📝 **Edit History** - Add or remove entries for specific dates
- 🎨 **Status Indicators** - Clear color warnings as you approach replacement (green → yellow → orange → red)
- 📅 **Adjustable Start Date** - Change the start date of your current cycle if needed

## 🎯 Screenshots

> **Note**: Screenshots coming soon! Build and run the app to see it in action.

## 🛠️ Requirements

- **Xcode 16+** (for Swift 6 support)
- **iOS 16.0+** deployment target
- **macOS 14+** (for development)

## 🚀 Getting Started

### Installation

1. Clone the repository:
```bash
git clone git@github.com:larmiej/Lens-Tracker.git
cd Lens-Tracker
```

2. Open the project in Xcode:
```bash
open ContactLensesTracker.xcodeproj
```

3. Select your target device or simulator

4. Build and run (⌘R)

That's it! No dependencies, no CocoaPods, no package managers needed.

## 🏗️ Architecture

This app follows modern iOS development best practices:

### Design Pattern: MVVM
- **Models**: `LensCycle`, `LensType`, `CycleHistory`
- **ViewModels**: `LensTrackerViewModel` with `@Observable` (Swift 6)
- **Views**: SwiftUI views with clear separation of concerns
- **Services**: `DataManager` for data persistence

### Key Technologies
- **SwiftUI** - Modern declarative UI framework
- **Swift 6** - Latest language features with strict concurrency
- **@Observable** - Modern state management (not ObservableObject)
- **@MainActor** - Proper thread isolation for UI
- **UserDefaults** - Simple, efficient local data persistence
- **Codable** - JSON encoding/decoding for data storage

### Project Structure

```
ContactLensesTracker/
├── Models/              # Data models (LensCycle, LensType)
├── ViewModels/          # Business logic and state management
├── Services/            # Data persistence (DataManager)
├── Views/
│   ├── Dashboard/       # Main tracking interface
│   ├── Calendar/        # History and date management
│   └── Settings/        # Configuration and cycle management
└── Resources/           # Colors, typography, utilities
```

## 📚 Features in Detail

### Dashboard View
- **Progress Ring**: Visual indicator showing days worn vs. total cycle length
- **Status Messages**: Context-aware messages that update based on your progress
- **Quick Action Button**: Log today's wear with a single tap
- **Metadata Display**: See when you last wore your lenses and cycle start date

### Calendar History
- **Month View**: See all your wear dates at a glance
- **Add/Remove Entries**: Tap any date to add or remove a wear entry
- **Recent History**: Quick list of recent entries
- **Visual Indicators**: Green dots mark days you wore your lenses

### Settings
- **Lens Type Selection**: Choose from daily, bi-weekly, or monthly lenses
- **Cycle Information**: View current cycle stats (days worn, remaining)
- **Start Date Adjustment**: Change the start date of your current cycle
- **Reset Functionality**: Start a new cycle while preserving history

### Smart Features
- **History Preservation**: Changing lens types or resetting doesn't lose your data
- **Date Validation**: Can't log future dates or set invalid start dates
- **Automatic Calculations**: Days remaining, progress percentage, status all calculated automatically
- **Color-Coded Warnings**:
  - 🟢 Green (0-67%): Looking good!
  - 🟡 Yellow (67-81%): Getting close
  - 🟠 Orange (81-100%): Replace soon
  - 🔴 Red (100%+): Overdue - replace immediately

## 🎨 Design Philosophy

This app prioritizes **simplicity and speed** over feature bloat. The design focuses on:

- **Minimal Friction**: Log your wear in one tap
- **Clear Visual Hierarchy**: Most important info (current status) is most prominent
- **iOS Native Feel**: Follows Human Interface Guidelines
- **Performance**: Optimized for smooth animations and fast interactions
- **Accessibility**: Supports Dynamic Type, VoiceOver, and high contrast modes

## 🔧 Development

### Building from Source

```bash
# Clone the repository
git clone git@github.com:larmiej/Lens-Tracker.git
cd Lens-Tracker

# Open in Xcode
open ContactLensesTracker.xcodeproj

# Build
xcodebuild -scheme ContactLensesTracker -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Code Quality

- **Swift 6 Concurrency**: Full data race safety
- **No Force Unwraps**: Safe optional handling throughout
- **Comprehensive Documentation**: All public APIs documented
- **SwiftUI Previews**: Every view has preview configurations
- **Value Semantics**: Immutable models with functional updates

### Testing

> **Note**: Unit tests coming in future version. Current testing is manual via Xcode previews and simulator.

## 📖 Documentation

Additional documentation available:

- [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) - Detailed implementation notes and technical decisions
- [`ICON_DESIGN_SPEC.md`](ICON_DESIGN_SPEC.md) - App icon design specifications

## 🗺️ Roadmap

### Version 1.1 (Planned)
- [ ] Local notifications for replacement reminders
- [ ] Home Screen widgets
- [ ] Lock Screen widgets (iOS 16+)
- [ ] Data export (CSV/JSON)

### Version 2.0 (Future)
- [ ] iCloud sync across devices
- [ ] Apple Watch app and complications
- [ ] Multiple lens sets (left/right eye different schedules)
- [ ] Statistics and trends visualization
- [ ] Siri Shortcuts integration

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines

1. Follow existing code style and architecture patterns
2. Maintain Swift 6 concurrency safety
3. Add SwiftUI previews for new views
4. Document public APIs
5. Test on multiple iOS versions (16.0+)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with SwiftUI and Swift 6
- Design follows Apple's Human Interface Guidelines
- Color-coded status system inspired by iOS Activity rings
- Developed with assistance from Claude Code

## 📝 Changelog

### [1.1.0] - 2025-01-14
- Added ability to change cycle start date
- Improved settings interface with date picker
- Enhanced confirmation dialogs

### [1.0.1] - 2025-01-14
- Fixed history preservation bug in cycle resets
- Simplified DataManager architecture
- Performance improvements (cached DateFormatters)
- Fixed architecture violations and race conditions
- Aligned color thresholds with status messages

### [1.0.0] - 2025-01-14
- Initial release
- Core tracking functionality
- Dashboard with progress ring
- Calendar history view
- Settings and cycle management
- Support for daily, bi-weekly, and monthly lenses

---

**Made with ❤️ and SwiftUI**

⭐ Star this repo if you find it helpful!
