// server.js

const process = require("child_process");
const express = require("express");
const app = express();
const port = 4567;

app.use(express.json());

app.listen(port);

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

