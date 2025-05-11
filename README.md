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




## Decision-Making Report for Collaborative Workspace Application

## 1. Backend Choice
**Choice**: Firebase Cloud Functions  
**Reason**: I chose Firebase Cloud Functions for their seamless integration with Flutter and Firestore and, my experience in building serverless Flutter apps. They are ideal for small to medium-sized apps like this collaborative workspace app, offering a free tier and a mature ecosystem compared to Supabase. Firestore’s NoSQL structure enables fast read operations, critical for real-time task updates.

**Factors Influencing Decision**: 
 
**Integration Speed**: Firebase’s native Flutter SDKs and Firestore integration minimize setup time, unlike Laravel API or Flask, which require custom server setups.
  
- **Cost**: Firebase’s free tier supports small to medium apps, making it cost-effective initially. However, costs can rise with high request volumes, unlike the other backend choices which has a predictable server costs.

- **Scaling**: Firebase auto-scales to handle traffic spikes, but scaling costs can be higher than fixed-server solutions like Flask or others. For this app’s scope, auto-scaling meets needs efficiently.  

- **Flexibility**: Firebase’s maturity and Flutter ecosystem support.

## 2. Database Choice
**Choice**: Firebase Firestore  
**Reason**: Firestore’s NoSQL structure aligns with the app’s hierarchical data model (workspaces > boards > tasks), and my previous experience with Firestore in Flutter projects ensured fast implementation. Its real-time streams support instant task updates, enhancing collaboration.  
**Comparison**:  
- **Supabase (PostgreSQL)**: Relational, ideal for complex queries, but requires more setup for real-time features compared to Firestore’s native streams.  
- **MySQL**: Structured but less suited for nested data and lacks built-in real-time sync.  
- **Firestore**: Simplifies subcollection queries (e.g., `workspaces/{id}/boards/{id}/tasks`) and scales automatically.   


## 3. Storage (for Attachments)
**Choice**: Firebase Storage
   1- I’d use Firebase Storage to store task attachments (e.g., images, documents) at attachments/{workspaceId}/{boardId}/{taskId}/{fileId} using Flutter’s firebase_storage package, with          file metadata in Firestore’s tasks/{taskId}

   2- Firebase Storage integrates easily with my Firebase-based app (Firestore, Authentication) and Flutter, and my experience for quick setup. Its free tier suits small apps and medium          apps, and security rules ensure only workspace members access their files.


**Comparison**:

   - **Firebase Storage**: Simple, free, ideal for small/medium apps, but costlier at scale.
   - **Amazon S3** Known for scalability and cost-efficiency in large-scale apps, which might make it seem like a safer choice for the report. Overkill for a small/medium apps with limited       attachment needs, as its complexity and setup time.
   - **Supabase Storage** Less mature than firebase storage Flutter support than Firebase but it will be a good option for the open source option. but misaligning with my Firebase stack.


**4. Implementation Plan**  
**Database Structure**:  
- **Firestore**:  
  - `users/{uid}`: Stores `username`, `email`.  
  - `workspaces/{workspaceId}`: Stores `name`, `description`, `memberIds`, `ownerId`.  
  - `workspaces/{workspaceId}/boards/{boardId}`: Stores `boardName`, `createdAt`.  
  - `workspaces/{workspaceId}/boards/{boardId}/tasks/{taskId}`: Stores `title`, `description`, `status`, `dueDate`, `assignedUserIds`.  

**Storage Structure**:  
- Files stored in **Firebase Storage** at `attachments/{workspaceId}/{boardId}/{taskId}/{fileId}`, with metadata in Firestore’s `tasks/{taskId}`.  

- Use: `cloud_firestore`, `firebase_auth`, `firebase_storage`  
  






