#!/usr/bin/env node

const program = require('commander')
const { spawn } = require('child_process')
const { createReadStream, readFileSync, writeFileSync } = require('fs')
const S3 = require('aws-sdk/clients/s3')
const projects = require('./projects.json')

program
  .version(require('./package.json').version)
  .option('-s, --skipPush', 'Skip pushing to S3')
  .option('-p, --project [name]', 'Import only a specific project')

program.on('--help', () => {
  console.log(`
  Environment Variables:

    AWS_ACCESS_KEY_ID      AWS key, required to sync to instructure-translations S3 bucket
    AWS_SECRET_ACCESS_KEY  AWS secret, required to sync to instructure-translations S3 bucket
  \n`)
})
program.parse(process.argv)

if (
  !program.skipPush &&
  (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY)
) {
  program.outputHelp()
  process.exit(1)
}

exportTranslations().catch(err => {
  console.error(err)
  process.exit(2)
})

function run(cmd, args, opts) {
  return new Promise((resolve, reject) => {
    const command = spawn(cmd, args, opts)
    command.on('error', reject)
    command.on('exit', code => (code === 0 ? resolve() : reject(code)))
  })
}

async function exportTranslations() {
  const toUpload = []
  for (const project of projects) {
    if (program.project && project.name !== program.project) continue

    if (project.location.endsWith('.xcodeproj')) {
      const outputPath = `translations/source/${project.name}/`
      console.log(`Exporting ${project.name} at ${project.location} to ${outputPath}`)
      await run('xcodebuild', [
        '-exportLocalizations',
        '-project',
        project.location,
        '-localizationPath',
        outputPath
      ], { cwd: '..' })

      const file = `../${outputPath}en.xliff`
      const xml = readFileSync(file, 'utf8')
        .replace(/<file[^>]*Info\.plist[\s\S]*?<\/file>\s*/g, '')
      writeFileSync(file, xml, 'utf8')
      toUpload.push({ from: file, to: `${project.name}.xliff` })
    } else {
      console.log(`Exporting ${project.name} at ${project.location}`)
      await run('yarn', ['extract-strings'], { cwd: `../${project.location}/../..` })
      toUpload.push({ from: `../${project.location}/en.json`, to: `${project.name}.json` })
    }
  }

  if (!program.skipPush) {
    const Bucket = 'instructure-translations'
    const s3 = new S3({ region: 'us-east-1' })
    await Promise.all(toUpload.map(({ from, to }) =>
      s3.putObject({ Bucket, Key: `canvas-ios/en/${to}`, Body: createReadStream(from) })
        .promise()
    ))
  }

  console.log('Finished!')
}
