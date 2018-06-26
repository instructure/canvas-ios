# iOS

### Apps
- Student
- Parent
- Teacher
- Polling
- Magic Marker

### How to connect to a local canvas instance
- Modify the contents of preload-account-info.plist (it's at the root of the repo)
  * See How To Generate a Developer Key section below
  * `client_id` is the `ID` of a generated Developer Key
  * `client_secret` is the `Key` of the generated Developer Key
- Build and run the app locally
- On the login page, your local canvas instance will appear in the top left corner of the screen

#### How to Generate a Developer Key
- Visit `web.canvas.docker/accounts/self/developer_keys` (replace `web.canvas.docker`
with your local instance
- Click `+ Developer Key`
- Give it a name and the following fields:
  * `Redirect URI (Legacy)`: `https://canvas/login`
  * `Redirect URIs` (separated by new lines):
    - https://canvas/login
    - canvas-courses://canvas/login
    - canvas-teacher://canvas/login
    - canvas-parent://canvas/login
