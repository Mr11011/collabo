# Collaborative Workspace Application

A Flutter-based application for collaborative task management, enabling users to create workspaces, boards, and tasks with features like task assignment, status tracking, a Kanban board, and a simple Gantt chart for task timelines. Built with Firebase for backend and Firestore for database, leveraging Cubit and Bloc for state management.

## Features
- **User Authentication**: Sign up, log in, and manage user profiles.
- **Workspaces**: Create and manage workspaces with multiple members or join workspace by workspace ID.
- **Boards**: Organize tasks within boards under workspaces.
- **Tasks**: Create tasks with title, description, status (To-Do, In Progress, Done), and optional due date.
- **Task Assignment**: Assign tasks to workspace members and edit or add due date.
- **Kanban Board**: Drag tasks between status columns using `draggable and drag`.
- **Simple Gantt Chart**: Visualize task timelines based on creation and due dates.
- **Real-Time Updates**: Task changes sync instantly using Firestore streams.

## Setup Instructions

### Prerequisites
- Flutter SDK and a compatible IDE (e.g., VS Code, Android Studio).
- Firebase project with Authentication and Firestore enabled.
- An emulator or physical device for testing.

### Installation
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repo/collabo.git](https://github.com/Mr11011/collabo-workspace-app-MahmoudElrouby.git
   cd collabo
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```


3. **Set Up Firebase**:
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
   - Enable Authentication (Email/Password) and Firestore.
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to:
     - Android: `android/app/`
     - iOS: `ios/Runner/`
   - Initialize Firebase in `main.dart` using `Firebase.initializeApp()`.

4. **Run the App**:
   ```bash
   flutter run
   ```

### Testing
- **Sign Up/Login**: Create a user account.
- **Create Workspace**: Add members and boards.
- **Manage Tasks**: Create, assign, and drag tasks in the Kanban board.
- **View Gantt Chart**: Check task timelines in the Gantt chart screen.
- **Verify Real-Time**: Update tasks and confirm instant UI updates.
