#!/usr/bin/env node

const program = require('commander')
const { spawn } = require('child_process')
const { createReadStream, readFileSync, writeFileSync, readdir } = require('fs')
const mkdirp = require('mkdirp')
const path = require('path')
const S3 = require('aws-sdk/clients/s3')
const projects = require('./projects.json')

program
  .version(require('./package.json').version)
  .option('-s, --skipPull', 'Skip pulling from S3')
  .option('-p, --project [name]', 'Import only a specific project')
  .option('-l, --list', 'List projects that can be imported')

program.on('--help', () => {
  console.log(`
  Environment Variables:

    AWS_ACCESS_KEY_ID      AWS key, required to sync to instructure-translations S3 bucket
    AWS_SECRET_ACCESS_KEY  AWS secret, required to sync to instructure-translations S3 bucket
  \n`)
})
program.parse(process.argv)

if (program.list) {
  console.log(projects.map(({ name }) => name).join('\n'))
  process.exit(0)
}

if (
  !program.skipPull &&
  (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY)
) {
  program.outputHelp()
  process.exit(1)
}

importTranslations().catch(err => {
  console.error(err)
  process.exit(2)
})

function run(cmd, args, opts) {
  return new Promise((resolve, reject) => {
    const command = spawn(cmd, args, opts)
    command.on('error', reject)
    command.on('exit', code => {
      if (code === 0) return resolve()
      console.error(command.stderr.toString())
      reject(`${cmd} failed with code ${code}.`)
    })
  })
}

async function importTranslations() {
  if (!program.skipPull) {
    const Bucket = 'instructure-translations'
    const s3 = new S3({ region: 'us-east-1' })
    const listObjects = await s3.listObjectsV2({ Bucket, Prefix: `canvas-ios/` }).promise()
    const keys = listObjects.Contents.map(({ Key }) => Key)
      .filter(key => !key.includes('/en/'))
      .filter(key => !program.project || key.includes(`/${program.project}.`))

    for (const key of keys) {
      const [ , locale, basename ] = key.split('/')
      const [ projectName, ext ] = basename.split('.')
      const filename = `imports/${projectName}/${locale}.${ext}`
      console.log(`Pulling s3://instructure-translations/${key} to ${filename}`)
      const { Body } = await s3.getObject({ Bucket, Key: key }).promise()
      mkdirp.sync(path.dirname(filename))
      writeFileSync(filename, Body.toString().replace(/^\uFEFF/, ''), 'utf8') // Strip BOM
    }
  }

  for (const project of projects) {
    if (program.project && project.name !== program.project) continue
    const folder = `imports/${project.name}`
    const files = await new Promise(resolve =>
      readdir(folder, (err, files) => resolve(files || []))
    )
    for (const file of files) {
      if (file.startsWith('.')) continue
      console.log(`Importing ${file} into ${project.location}`)
      if (project.location.endsWith('.xcodeproj')) {
        await run('xcodebuild', [
          '-importLocalizations',
          '-localizationPath',
          `translations/${folder}/${file}`,
          '-project',
          project.location
        ], { cwd: '..' })
      } else {
        await run('cp', [
          `${folder}/${file}`,
          `../${project.location}/${file}`
        ])
      }
    }
  }
}
