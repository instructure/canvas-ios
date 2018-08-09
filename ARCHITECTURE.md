## iOS Architecture

### Models

Models represent the data that comes from the Canvas API.

A typical model looks something like this:

```
public struct GroupModel: Codable, Context {
     public var concluded = false
     public var id = ""
     public var name = ""
     public var is_public = false
     public var course_id: String?
     public var tabs: [GroupTabModel]?
     
     public var type: ContextType {
         return .group
     }
 }
```

Models must:

- Be a swift struct
- Conform to Codable
- Have property names that match exactly what the API returns
- Contains as much business logic as possible
- Be completely covered by unit tests

