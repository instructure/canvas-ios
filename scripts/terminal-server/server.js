//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// This script starts a local web server that listens for POST calls
// on the /terminal path and executes the body of the request
// as a command line statement.

const process = require("child_process");
const express = require("express");
const app = express();
const port = 4567;

app.use(express.json());

app.listen(port, function(err) {
    if (err) {
        console.log("Error starting terminal server.");
    }
    console.log("Terminal server started.");
});

app.post("/terminal", (req, res) => {
    const output = exec(req.body.command, req.query.async).toString("utf8").trim();
    res.send(output);
});

function exec(command, async) {
    if (async === "true") {
        return process.exec(command);
    } else {
        return process.execSync(command);
    }
}

