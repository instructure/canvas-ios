## MBL-19957 — Speed up courses widget unread announcement count load

### Problem

The courses widget fetched unread announcement counts by calling the REST announcements endpoint, downloading every announcement for every enrolled course, and filtering client-side. This was slow, fragile (required `context_codes` to be non-empty), and triggered a redundant refresh every time the dashboard appeared.

### Solution

#### GraphQL-based unread count fetch

Replaced the REST approach with a GraphQL query (`GetUnreadCourseAnnouncementCountRequest`) that asks the server directly which announcements are unread via the `participant { read }` field. Results are stored in a new CoreData entity, `CDUnreadCourseAnnouncementCount`, keyed by course ID and holding the set of unread announcement IDs (as a sorted comma-separated string for deterministic storage).

The widget interactor now reads counts directly from the CoreData relationship (`course.unreadAnnouncementCount`) rather than re-fetching on every refresh.

#### Pagination

The GraphQL query uses a two-phase strategy to handle per-course cursor pagination correctly:

- **Phase 1** — A single `allCourses` query (no cursor) fetches the first page for all courses simultaneously.
- **Phase 2** — For each course with `hasNextPage: true`, a targeted `courses(ids:)` query is fired with that course's own cursor. This avoids the problem of a single query-level `$cursor` variable being applied to all courses at once. Requests within each round are fired in parallel and the process recurses until no course has a next page.

Persistence uses a smart upsert: only entities absent from the new response are deleted, so existing badge counts are never briefly zeroed during a refresh.

#### Mark-as-read on open

When a user opens an announcement, `CDUnreadCourseAnnouncementCount.removeAnnouncementId` is called alongside the existing `DiscussionTopic.markAsRead`, keeping the badge count in sync without waiting for the next background refresh.

#### Double refresh fix

Changed `LearnerDashboardScreen` from `.onAppear` to `.onNonFirstAppear` (a new `View` modifier) for the soft-refresh triggered when returning from a pushed screen, eliminating the redundant refresh on initial appearance.

### Changes

- `CDUnreadCourseAnnouncementCount` — new CoreData entity; stores unread announcement IDs per course
- `GetUnreadCourseAnnouncementCountRequest` / `GetUnreadAnnouncementsCountPageRequest` — GraphQL requests for first and subsequent pages
- `GetUnreadCourseAnnouncementCountsUseCase` — orchestrates multi-page fetch and persistence
- `Course` — new `unreadAnnouncementCount` relationship wired on save
- `DiscussionsAssembly` — removes announcement ID from the count when opened
- `CoursesAndGroupsWidgetInteractor` — removed `getAnnouncements` flatMap chain; reads counts from CoreData directly
- `NonFirstAppearViewModifier` — fires on every appearance except the first
- `GetAnnouncementsForCourses` — deleted (replaced by GraphQL approach)
