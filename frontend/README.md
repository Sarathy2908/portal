# ML Hackathon Evaluation Platform - Frontend

Flutter Web application for submitting ML endpoints and viewing real-time leaderboard.

## Features

- **Endpoint Submission**: Easy form to submit your ML model endpoint
- **Queue Status**: Real-time status updates with auto-polling
- **Live Leaderboard**: Auto-refreshing rankings with visual highlights
- **Responsive Design**: Works on desktop and mobile browsers
- **Status Indicators**: Color-coded status badges (Queued/Evaluating/Completed/Failed)

## Project Structure

```
frontend/
├── lib/
│   ├── main.dart                           # App entry point
│   ├── core/
│   │   ├── api_service.dart                # HTTP API client
│   │   └── constants.dart                  # App constants
│   ├── models/
│   │   ├── team.dart                       # Team data model
│   │   ├── queue_status.dart               # Queue status model
│   │   └── leaderboard.dart                # Leaderboard entry model
│   ├── providers/
│   │   ├── team_provider.dart              # Team state management
│   │   └── leaderboard_provider.dart       # Leaderboard state management
│   ├── screens/
│   │   ├── submit_endpoint_screen.dart     # Endpoint submission screen
│   │   ├── queue_status_screen.dart        # Queue status screen
│   │   └── leaderboard_screen.dart         # Leaderboard screen
│   └── widgets/
│       ├── status_badge.dart               # Status indicator widget
│       ├── loading_indicator.dart          # Loading spinner widget
│       └── leaderboard_table.dart          # Leaderboard table widget
├── pubspec.yaml
└── README.md
```

## Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- Chrome or any modern web browser

### Setup

1. **Install Flutter**

Follow instructions at: https://flutter.dev/docs/get-started/install

2. **Enable Flutter Web**
```bash
flutter config --enable-web
```

3. **Navigate to frontend directory**
```bash
cd frontend
```

4. **Install dependencies**
```bash
flutter pub get
```

5. **Configure API endpoint**

Edit `lib/core/constants.dart`:
```dart
class AppConstants {
  static const String apiBaseUrl = 'http://localhost:8000';  // Change for production
  // ...
}
```

6. **Run the app**
```bash
flutter run -d chrome
```

Or for hot reload during development:
```bash
flutter run -d web-server --web-port 3000
```

## Building for Production

### Build Web App

```bash
flutter build web --release
```

Output will be in `build/web/` directory.

### Deploy to Firebase Hosting

1. **Install Firebase CLI**
```bash
npm install -g firebase-tools
```

2. **Login to Firebase**
```bash
firebase login
```

3. **Initialize Firebase**
```bash
firebase init hosting
```

Select `build/web` as public directory.

4. **Deploy**
```bash
flutter build web --release
firebase deploy
```

### Deploy to GitHub Pages

1. **Build the app**
```bash
flutter build web --release --base-href "/your-repo-name/"
```

2. **Copy build to docs folder**
```bash
cp -r build/web/* docs/
```

3. **Push to GitHub**
```bash
git add docs/
git commit -m "Deploy Flutter web app"
git push
```

4. **Enable GitHub Pages** in repository settings, select `docs/` folder.

### Deploy to Netlify

1. **Build the app**
```bash
flutter build web --release
```

2. **Install Netlify CLI**
```bash
npm install -g netlify-cli
```

3. **Deploy**
```bash
netlify deploy --dir=build/web --prod
```

## Screens Overview

### 1. Submit Endpoint Screen

First screen where teams submit their ML model endpoint.

**Fields:**
- Team ID (required)
- Team Name (required)
- Endpoint URL (required, must be HTTP/HTTPS)

**Validation:**
- All fields required
- URL format validation
- Endpoint reachability check (backend)

**On Success:**
- Navigates to Queue Status Screen
- Shows queue position

### 2. Queue Status Screen

Shows real-time status of team's evaluation.

**Features:**
- Auto-polls every 5 seconds
- Shows current status with color-coded badge
- Displays queue position
- Estimates wait time
- Shows failure reason if evaluation failed
- Auto-navigates to Leaderboard when completed

**Status Colors:**
- 🟡 **QUEUED** - Yellow (waiting in queue)
- 🔵 **EVALUATING** - Blue (currently evaluating)
- 🟢 **COMPLETED** - Green (evaluation finished)
- 🔴 **FAILED** - Red (evaluation failed)

### 3. Leaderboard Screen

Displays ranked list of all teams.

**Features:**
- Auto-refreshes every 5 seconds
- Sortable table with rankings
- Trophy icons for top 3 teams (🥇🥈🥉)
- Highlights current team in yellow
- Shows accuracy, F1 score, latency
- Manual refresh button

**Columns:**
- Rank
- Team Name
- Accuracy (%)
- F1 Score
- Latency (ms)

## State Management

Uses **Provider** package for state management.

### TeamProvider

Manages team submission and queue status.

**Methods:**
- `submitEndpoint(Team team)`: Submit endpoint for evaluation
- `fetchQueueStatus(String teamId)`: Get current queue status

**State:**
- `currentTeam`: Current team data
- `queueStatus`: Current queue status
- `isLoading`: Loading indicator
- `errorMessage`: Error message if any

### LeaderboardProvider

Manages leaderboard data.

**Methods:**
- `fetchLeaderboard()`: Fetch latest leaderboard

**State:**
- `leaderboard`: List of leaderboard entries
- `isLoading`: Loading indicator
- `errorMessage`: Error message if any

## API Integration

### API Service (`api_service.dart`)

Handles all HTTP requests to backend.

**Methods:**

```dart
// Submit endpoint
Future<Map<String, dynamic>> submitEndpoint(Team team)

// Get queue status
Future<QueueStatus> getQueueStatus(String teamId)

// Get leaderboard
Future<List<LeaderboardEntry>> getLeaderboard()

// Get team result
Future<Map<String, dynamic>> getTeamResult(String teamId)
```

## Customization

### Change Colors

Edit `lib/core/constants.dart`:

```dart
static const Map<String, int> statusColors = {
  'QUEUED': 0xFFFFA726,      // Orange
  'EVALUATING': 0xFF42A5F5,  // Blue
  'COMPLETED': 0xFF66BB6A,   // Green
  'FAILED': 0xFFEF5350,      // Red
};
```

### Change Polling Interval

Edit `lib/core/constants.dart`:

```dart
static const int pollInterval = 5;  // Seconds
```

### Change API Base URL

Edit `lib/core/constants.dart`:

```dart
static const String apiBaseUrl = 'https://your-api.com';
```

## Development Tips

### Hot Reload

Flutter supports hot reload for fast development:
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Debug Mode

Run with debug flag:
```bash
flutter run -d chrome --debug
```

### View Logs

```bash
flutter logs
```

### Clear Cache

```bash
flutter clean
flutter pub get
```

## Testing

### Run Tests

```bash
flutter test
```

### Widget Tests

Create test files in `test/` directory:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ml_hackathon_frontend/main.dart';

void main() {
  testWidgets('Submit button test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('Submit Endpoint'), findsOneWidget);
  });
}
```

## Troubleshooting

### Issue: CORS Error

If you see CORS errors in browser console:

**Solution**: Backend must allow CORS. Already configured in `backend/app/main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to specific domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Issue: Connection Refused

**Solution**: Ensure backend is running on correct port (8000 by default).

### Issue: Build Fails

**Solution**: 
```bash
flutter clean
flutter pub get
flutter build web
```

### Issue: Packages Not Found

**Solution**:
```bash
flutter pub cache repair
flutter pub get
```

## Browser Compatibility

Tested on:
- ✅ Chrome (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Edge

## Performance Optimization

### Reduce Bundle Size

```bash
flutter build web --release --web-renderer canvaskit
```

### Enable Caching

Add to `web/index.html`:
```html
<meta http-equiv="Cache-Control" content="max-age=31536000">
```

## Dependencies

- **http**: HTTP client for API calls
- **provider**: State management
- **intl**: Date/time formatting
- **fl_chart**: Charts and graphs (optional)

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## License

MIT License - Free for hackathon use
