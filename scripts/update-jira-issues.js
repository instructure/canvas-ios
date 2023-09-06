#!/usr/bin/env node
//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

/*
yarn released <tag>
yarn released Student-6.8.2

Marks all closed MBL Jira issues with a particular fix version as released.

Requires env variables for Jira authentication:
- JIRA_USERNAME
- JIRA_API_TOKEN

Includes functions to tag the fixVersion of a group of issues too.
*/

const https = require('https')
const JiraClient = require('jira-client')
const client = new JiraClient({
  protocol: 'https',
  host: 'instructure.atlassian.net',
  username: process.env.JIRA_USERNAME,
  password: process.env.JIRA_API_TOKEN,
})

const getJSON = (url) => new Promise((resolve, reject) => {
  https.get(url, (response) => {
    let data = ''
    response.on('data', (chunk) => {
      data += chunk.toString()
    })
    response.on('end', () => {
      try { resolve(JSON.parse(data)) }
      catch (error) { reject(error) }
    })
  }).on('error', reject).end()
})

const cannonicalVersion = (version) => version.replace(/(\.0)+$/, '')

const fixVersionForAppVersion = async (app, version) => {
  console.log(`Looking up fixVersion for ${app} ${version}`)
  const cversion = cannonicalVersion(version)
  for (const version of await client.getVersions('MBL')) {
    const [ p, a = '', v = '' ] = version.name.split(/\s+/)
    if (p === 'iOS' && a === app && cannonicalVersion(v) === cversion) {
      return version.name
    }
  }
  throw new Error(`Could not find a fixVersion matching ${app} ${version}`)
}

exports.addFixVersion = async (tag, issueKeys) => {
  const fixVersionName = await fixVersionForAppVersion(...(tag.split('-')))
  console.log(`Adding fix version "${fixVersionName}"\n${issueKeys.join('\n')}`)
  await Promise.allSettled(issueKeys.map(issueKey => client.updateIssue(issueKey, {
    update: { fixVersions: [ { add: { name: fixVersionName } } ] },
  })))
}

exports.appIDs = {
  Parent: "1097996698",
  Student: "480883488",
  Teacher: "1257834464",
}

exports.commands = {
  "label-released": async () => {
    for (const app of Object.keys(exports.appIDs)) {
      console.log(`Looking up current version of ${app} on the App Store`)
      const response = await getJSON(`https://itunes.apple.com/lookup?id=${exports.appIDs[app]}`)
      const version = response.results[0].version
      const count = await exports.commands.released(app, version)
      if (count == 0) {
        console.log(`There are no ${app} ${version} issues that need to be labelled`)
      }
      console.log('')
    }
  },

  "released": async (app, version) => {
    if (![ 'Student', 'Teacher', 'Parent' ].includes(app) || !version) {
      console.error(`yarn ${arguments.callee.name} <app> <version>`)
      console.error(`node update-jira-issues.js ${arguments.callee.name} <app> <version>`)
      console.error(`app must be one of "Student", "Teacher", "Parent"`)
      process.exit(1)
    }

    const fixVersionName = await fixVersionForAppVersion(app, version)
    const releasedLabel = `released-appstore-${app.toLowerCase()}`
    console.log(`Adding label "${releasedLabel}" to closed MBL issues with fix version "${fixVersionName}"`)

    let startAt = 0
    let total = 0
    do {
      let results = await client.searchJira(`
        project = "MBL" AND
        fixVersion = "${fixVersionName}" AND
        status = Closed AND
        NOT (labels = "${releasedLabel}")
      `, {
        startAt,
        maxResults: 10,
        fields: [ 'id', 'key', 'labels', 'summary' ],
      })

      await Promise.all(results.issues.map(issue => {
        const labels = [ { add: releasedLabel } ]
        issue.fields.labels.push(releasedLabel) // to simplify tests below
        console.log(issue.key, issue.fields.summary)
        if (
          (!/^[^|]*(Parent|All)\s*[|]/i.test(issue.fields.summary)
          || issue.fields.labels.includes('released-appstore-parent')) &&
          (!/^[^|]*(Student|All)\s*[|]/i.test(issue.fields.summary)
          || issue.fields.labels.includes('released-appstore-student')) &&
          (!/^[^|]*(Teacher|All)\s*[|]/i.test(issue.fields.summary)
          || issue.fields.labels.includes('released-appstore-teacher'))
        ) { // affected apps have been released
          labels.push({ add: 'deployed-production' })
        }
        return client.updateIssue(issue.id, { update: { labels } })
      }))

      startAt += results.issues.length
      total = results.total
    } while (startAt < total)
    return total
  },
}

if (require.main === module) {
  const [ , , command, ...args ] = process.argv
  const commands = Object.keys(exports.commands)
  if (!commands.includes(command)) {
    console.error(`node update-jira-issues.js <command> [...args]`)
    console.error(`command "${command}" must be one of: ${commands.join(', ')}`)
    return process.exit(1)
  }

  if (!process.env.JIRA_USERNAME || !process.env.JIRA_API_TOKEN) {
    console.error(`node update-jira-issues.js <command> [...args]`)
    console.error(`env vars JIRA_USERNAME and JIRA_API_TOKEN are required`)
    return process.exit(1)
  }

  exports.commands[command](...args).catch((error) => {
    console.error(error)
    return process.exit(2)
  })
}
