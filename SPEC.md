# Pickleball Scoring Application Specification

## Project Overview
- **Project Name**: Pickleball Scorekeeper
- **Type**: Mobile Application (Flutter)
- **Core Functionality**: A comprehensive pickleball scoring app that accurately implements official scoring rules for both singles and doubles play, with customizable game settings and proper serving logic.

## Technology Stack & Choices
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider (simple, efficient for this use case)
- **Architecture**: Clean Architecture (UI → Business Logic → Data/Models)

### Key Dependencies
- `provider` - State management
- `flutter_localizations` - Internationalization support (optional)

## Feature List

### 1. Game Setup Screen
- Match type selection (Singles/Doubles)
- Scoring system toggle (Traditional side-out / Rally scoring)
- Winning score presets (11, 15, 21) + custom input
- "Win by 2" toggle

### 2. Score Display
- Team A and Team B scores
- Current server indicator
- Server number (1 or 2 for doubles)
- Court position indicator (left/right)
- Score in proper format: ServerScore - ReceiverScore - ServerNumber

### 3. Game Controls
- Point for Team A button
- Point for Team B button
- Fault / Side Out button
- Undo Last Action button
- Reset Game button

### 4. Scoring & Serving Logic
- Official pickleball rules implementation
- First serve starts from right side
- Serve position based on score (even=right, odd=left)
- Doubles server rotation (Server 1 → Server 2 → side out)
- Traditional vs Rally scoring
- Win by 2 enforcement
- Game over detection

### 5. State Management
- Current server team tracking
- Server number for doubles
- Scores for both teams
- Serving side (left/right)
- History stack for undo

### 6. UI/UX
- Mobile-friendly responsive design
- Large, readable score display
- Visual indicators for serving team and court position
- Clean transitions

## UI/UX Design Direction

### Visual Style
- Material Design 3
- Clean, modern appearance
- High contrast for readability

### Color Scheme
- Primary: Deep Blue (#1565C0)
- Secondary: Amber (#FFA000)
- Team A: Blue
- Team B: Red/Orange
- Background: Light gray/white
- Serving indicator: Gold/Yellow accent

### Layout Approach
- Single page with sections:
  1. Header with game configuration
  2. Large score display (center)
  3. Serving indicators
  4. Control buttons at bottom

### Typography
- Large score numbers (72-96sp)
- Clear team labels
- Visible server indicators

## Scoring Logic Implementation

### Traditional Scoring (Side-Out)
- Only serving team can score
- Point for Team A: If serving team = A
- Point for Team B: If serving team = B
- Fault: Side out (serve transfers to receiving team)

### Rally Scoring
- Either team scores on every rally
- Point awarded to winner of rally

### Serving Position (Both Modes)
- Even score: Serve from right side
- Odd score: Serve from left side

### Doubles Server Rotation
1. Start: Server #2 on serving team
2. Server 1 loses → switch to Server 2
3. Server 2 loses → side out (other team serves)
4. After gaining point: Players switch sides

### Win by 2
- Must win by 2 or more points
- If tied at (winning_score - 1), continue playing