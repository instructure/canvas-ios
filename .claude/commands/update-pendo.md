Update the Pendo SDK to a new version. Usage: /update-pendo <version> (e.g. /update-pendo 3.12.0)

The target version is: $ARGUMENTS

Steps:

1. Look up the git tag revision for the target version by running:
```bash
git ls-remote https://github.com/pendo-io/pendo-mobile-sdk refs/tags/<version>
```
Fail early with a clear message if the tag does not exist.

2. Update `exactVersion` for Pendo in all 8 project.yml files (replacing whatever the current version is):
- Core/project.yml
- Horizon/project.yml
- Student/project.yml
- Student/project-ci.yml
- Teacher/project.yml
- Teacher/project-ci.yml
- Parent/project.yml
- Parent/project-ci.yml

3. Run `make sync` to regenerate Xcode project files.

4. Build the project using the BuildProject MCP tool so that `Canvas.xcworkspace/xcshareddata/swiftpm/Package.resolved` is updated with the new revision and version.

5. Extract the ticket number from the current branch name (format: `chore/MBL-XXXXX-...` → `MBL-XXXXX`).

6. Commit all changed files with this message format (matching the project convention):
```
[<TICKET>][S/T/P] Pendo - Update Pendo SDK to <version>

refs: <TICKET>
builds: Student, Teacher, Parent
affects: Student, Teacher, Parent
release note: none
```
