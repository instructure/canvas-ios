# File Submission Technical Overview
## Submission Sequence
The following sequence diagram illustrates interactions between various parts of the system during a file upload submission originating from the file share extension of the Student app.
```mermaid
sequenceDiagram
    actor User
    User->>Share Extension: Starts Submitting Selected Files
    loop For All Files
        Share Extension->>File System: Copy File
    end
    Share Extension->>CoreData: Creates File Submission Metadata
    loop For All Files
        Share Extension->>API: Request File Upload
        API-->>Share Extension: Provides Upload URL
    end
    Share Extension->>iOS: Start Background Session
    loop For All Files
        Share Extension->>iOS: Start File Upload
    end
    User->>Share Extension: Dismisses
    iOS->>Application: Starts In Background
    Application-->>CoreData: Loads Submission Metadata
    loop For All Files
        iOS->>Application: Reports Upload Progress
        Application-->>CoreData: Saves Upload State
    end
    User->>Application: Starts To Check Progress
    Application-->>User: Displays Upload Progress
    loop For All Files
        iOS->>Application: File Upload Finished
        Application-->>CoreData: Save File ID
    end
    Application->>API: Submit File IDs To Assignment
    API-->>Application: Confirms Successful Submission
    Application->>User: Sends Successful Submission Notification
```
