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

const { spawn, spawnSync } = require("child_process");
const express = require("express");
const app = express();
const port = 4567;

app.use(express.json());
const NETWORK_SERVICE_NAME_PATTERN = /^[^\0\r\n']{1,128}$/;

function parseAllowedCommand(command) {
    if (command === "networksetup -listallnetworkservices") {
        return {
            cmd: "networksetup",
            args: ["-listallnetworkservices"],
            ignoreExitCode: false,
        };
    }

    let match = command.match(/^networksetup -getnetworkserviceenabled '([^']+)'$/);
    if (match) {
        const service = match[1];

        if (!NETWORK_SERVICE_NAME_PATTERN.test(service)) {
            return null;
        }

        return {
            cmd: "networksetup",
            args: ["-getnetworkserviceenabled", service],
            ignoreExitCode: false,
        };
    }

    match = command.match(/^networksetup -setnetworkserviceenabled '([^']+)' (on|off) \|\| true$/);
    if (match) {
        const service = match[1];
        const state = match[2];

        if (!NETWORK_SERVICE_NAME_PATTERN.test(service)) {
            return null;
        }

        return {
            cmd: "networksetup",
            args: ["-setnetworkserviceenabled", service, state],
            ignoreExitCode: true,
        };
    }

    return null;
}


app.listen(port, function(err) {
    if (err) {
        console.log("Error starting terminal server.");
        return;
    }
    console.log("Terminal server started.");
});

app.post("/terminal", (req, res) => {
    const commandConfig = parseAllowedCommand(req.body.command);

    if (!commandConfig) {
        return res.status(403).send("Command is not allowed.");
    }

    const output = exec(commandConfig, req.query.async).toString("utf8").trim();
    res.send(output);
});

function exec(commandConfig, async) {
    if (async === "true") {
        const child = spawn(commandConfig.cmd, commandConfig.args, {
            shell: false,
            windowsHide: true,
            detached: true,
            stdio: "ignore",
        });

        child.unref();
        return Buffer.from("Command started.");
    }

    const result = spawnSync(commandConfig.cmd, commandConfig.args, {
        shell: false,
        windowsHide: true,
        encoding: "buffer",
    });

    if (result.error) {
        throw result.error;
    }

    if (result.status !== 0 && !commandConfig.ignoreExitCode) {
        return result.stderr;
    }

    return result.stdout;
}

