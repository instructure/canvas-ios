# File Submission Technical Overview
## Submission Sequence
The following sequence diagram illustrates interactions between various parts of the system during a file upload submission originating from the file share extension of the Student app.
```mermaid
sequenceDiagram
    actor User
    participant Share Extension
    participant File System
    participant CoreData
    participant Canvas API
    participant iOS
    participant Application
    User->>Share Extension: Starts Submitting Selected Files
    loop For All Files
        Share Extension->>+File System: Copy File
        File System-->>-Share Extension: Copy Finished
    end
    activate Share Extension
    Share Extension->>+CoreData: Creates File Submission Metadata
    deactivate Share Extension
    CoreData-->>-Share Extension: Confirms Database Update
    
    loop For All Files
        Share Extension->>+Canvas API: Request File Upload
        Canvas API-->>-Share Extension: Provide Upload URL
    end
    activate Share Extension
    Share Extension->>iOS: Starts Background Session
    deactivate Share Extension
    activate iOS
    loop For All Files
        Share Extension->>iOS: Start File Upload
    end
    User->>Share Extension: Dismisses
    iOS->>+Application: Starts In Background
    
    Application-->>CoreData: Loads Submission Metadata
    loop For All Files
        iOS->>Application: Report Upload Progress
        Application-->>CoreData: Save Upload State
    end
    User->>Application: Starts To Check Progress
    Application-->>User: Displays Upload Progress
    loop For All Files
        iOS->>Application: File Upload Finished
        Application-->>CoreData: Save File ID
    end
    deactivate iOS
    Application->>+Canvas API: Submits File IDs To Assignment
    Canvas API-->>-Application: Confirms Successful Submission
    Application->>User: Sends Successful Submission Notification
    deactivate Application
```
## Class Diagram Of Involved Entities
```mermaid
classDiagram
    direction TB
    class FileSubmissionAssembly
    class BackgroundURLSessionProvider
    class FileSubmissionComposer{
        <<Step 0>>
    }
    class FileUploadTargetRequester {
        <<Step 1>>
    }
    class FileUploadProgressObserver {
        <<Step 2>>
    }
    class FileSubmissionSubmitter {
        <<Step 3>>
    }
    class FileSubmission{
        <<CoreData>>
    }
    class FileUploadItem{
        <<CoreData>>
    }
    class URLSession
    
    FileSubmissionAssembly o-- FileSubmissionComposer: Stores
    FileSubmissionAssembly o-- BackgroundURLSessionProvider: Stores
    FileSubmissionComposer --> FileSubmission: Creates/Updates
    FileSubmission "1" *-- "1..*" FileUploadItem: Contains
    FileUploadTargetRequester --> FileUploadItem: Updates
    FileUploadProgressObserver --> FileUploadItem: Updates
    BackgroundURLSessionProvider --> URLSession: Provides
    URLSession --> FileUploadProgressObserver: Notifies
    FileSubmissionSubmitter --> FileSubmission: Updates
```
