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
   git clone https://github.com/Mr11011/collabo-workspace-app-MahmoudElrouby.git
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


---------------------------------------------------------------------------

# Decision-Making Report for Collaborative Workspace Application

## 1. Backend Choice
**Choice**: Firebase Cloud Functions  
**Reason**: I chose Firebase Cloud Functions because they work well with Flutter and Firestore, and I’ve used them before in serverless Flutter apps. They suit small to medium apps like this one, with a free tier and a strong ecosystem compared to Supabase. Firestore’s NoSQL structure supports fast reads, which helps with real-time task updates.

**Factors Influencing Decision**:  
- **Integration Speed**: Firebase’s Flutter tools and Firestore make setup quick, unlike Laravel or Flask, which need custom servers.  
- **Cost**: Firebase’s free tier fits small to medium apps, though costs can grow with heavy use compared to predictable server costs elsewhere.  
- **Scaling**: Firebase handles traffic spikes automatically, but scaling can get pricey compared to fixed-server options like Flask. It works for this app’s needs.  
- **Flexibility**: Firebase’s maturity and Flutter support made it a solid pick.

## 2. Database Choice
**Choice**: Firebase Firestore  
**Reason**: Firestore’s NoSQL setup matches the app’s data structure (workspaces > boards > tasks), and my past work with it in Flutter projects sped things up. Its real-time streams keep task updates instant for collaboration.  
**Comparison**:  
- **Supabase (PostgreSQL)**: Good for complex queries but needs extra work for real-time compared to Firestore’s built-in streams.  
- **MySQL**: Structured, but not great for nested data and lacks real-time sync.  
- **Firestore**: Makes nested queries easy and scales on its own.

## 3. Storage (for Attachments)
**Choice**: Firebase Storage  
**How**: I’d store task attachments (e.g., images, documents) in Firebase Storage at `attachments/{workspaceId}/{boardId}/{taskId}/{fileId}` using Flutter’s `firebase_storage` package, with metadata in Firestore’s `tasks/{taskId}`.  
**Why**: Firebase Storage fits smoothly with my Firebase setup (Firestore, Authentication) and Flutter. Its free tier works for small to medium apps, and security rules limit access to workspace members.  
**Comparison**:  
- **Firebase Storage**: Simple, free tier, good for small/medium apps, but costs more at scale.  
- **Amazon S3**: Great for big apps with scalability, but too complex for this project.  
- **Supabase Storage**: Less developed than Firebase and doesn’t match my Firebase stack.

## 4. Implementation Plan
**Database Structure**:  
- **Firestore**:  
  - `users/{uid}`: Stores `username`, `email`.  
  - `workspaces/{workspaceId}`: Stores `name`, `description`, `memberIds`, `ownerId`.  
  - `workspaces/{workspaceId}/boards/{boardId}`: Stores `boardName`, `createdAt`.  
  - `workspaces/{workspaceId}/boards/{boardId}/tasks/{taskId}`: Stores `title`, `description`, `status`, `dueDate`, `assignedUserIds`.  

**Storage Structure**:  
- Files stored in **Firebase Storage** at `attachments/{workspaceId}/{boardId}/{taskId}/{fileId}`, with metadata in Firestore’s `tasks/{taskId}`.  

**App Connection**:  
- Uses `cloud_firestore`, `firebase_auth`, `firebase_storage`.



----------------------------------------------------------------------------------------------------------------------------------------------------



# Technical Questions for Collaborative Workspace Application

## 1. Backend Architecture
**How to scale backend services for 1 million users?**  
To scale a backend for 1 million users, I’d use these simple strategies:  
- **Break into Small Services**: Split the backend into parts (e.g., one for login, one for tasks) to manage and grow each separately.  
- **Use a Fast Database**: Pick a database that handles lots of users, like NoSQL for quick reads or SQL with indexes.  
- **Add Caching**: Store common data (e.g., user names) in a cache to speed things up.  
- **Balance Traffic**: Use a load balancer to spread requests across servers.  
- **Monitor Performance**: Track server usage to fix slow spots.  

## 2. Authentication Strategy
**Securing authentication in a mobile/web app**:  
- Use **Firebase Authentication** with:  
  - **Email/Password**: Users sign up with email and password, with **email verification** to confirm identity.  
  - **OTP**: Allow login with one-time passwords for extra security.  
- Protect data with **Firestore security rules** (e.g., only users in `workspaces/{id}.memberIds` can access tasks).  

**Token expiration and refresh flows**:  
- Firebase provides **ID tokens** (expire in 1 hour) and **refresh tokens**.  
- The `firebase_auth` package refreshes ID tokens automatically to keep users logged in.  
- Store refresh tokens safely (e.g., `flutter_secure_storage`).  
- If a token fails, ask users to sign in again.  

## 3. Database Modeling
**Designing relationships between Users, Workspaces, Boards, and Tasks**:  
- **Users**: `users/{uid}` with `username`, `email`.  
- **Workspaces**: `workspaces/{workspaceId}` with `name`, `description`, `memberIds`, `ownerId`.  
- **Boards**: `workspaces/{workspaceId}/boards/{boardId}` with `boardName`, `createdAt`.  
- **Tasks**: `workspaces/{workspaceId}/boards/{boardId}/tasks/{taskId}` with `title`, `description`, `status`, `dueDate`, `assignedUserIds`.  
**Relationships**:  
- **Users ↔ Workspaces**: `memberIds` links users to workspaces; `ownerId` is the creator.  
- **Workspaces ↔ Boards**: Boards are under workspaces.  
- **Boards ↔ Tasks**: Tasks are under boards, with `assignedUserIds` linking to users.  

## 4. State Management (Frontend)
**Comparing Provider, Riverpod, and BLoC (Flutter)**:  
- **Provider**: Simple for basic state.  
- **Riverpod**: Better for type safety and reactive updates.  
- **BLoC**: Good for complex apps, separates UI from logic.  

**Preference**: **BLoC/Cubit**  
- **Why**: Cubit simplifies state management for my app’s needs (e.g., real-time updates, Kanban).

## 5. Offline Handling
**Allowing offline use and synchronization**:  
- Enable Firestore’s offline mode to cache data locally.  
- Sync changes when internet returns via Firestore.  
- Use UI feedback like toast message or snack bar to show offline status and sync confirmation or, making a connectivity listner for the internet connectivity of the device and if it detects the signal is lost, show 'No Interenet Connection' Screen.
- For attachments, cache uploads locally and sync when online.






