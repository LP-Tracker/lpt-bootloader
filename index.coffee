# Start the application
bootloaderVersion = (require './package.json').version
updaterVersion = (require '../../updater/latest/package.json').version
applicationVersion = (require '../../application/latest/package.json').version
electron = require 'electron'
app = electron.app
cs = require 'compare-semver'
client = require 'request'
app.once 'ready', ->
  if process.env.NODE_ENV is "development" then return require "../../application/latest/index"
  checkBootloader ->
    checkUpdater ->
      checkApplication ->
        return require "../../application/latest/index"

checkBootloader = (cb) ->
  client.get 'http://lptracker-updates.cluster.arm1stice.com/repos/LP-Tracker/lpt-bootloader/releases/latest', (err, status, body) ->
    if body isnt undefined
      body = JSON.parse body
      releaseVersion = body.tag_name.replace 'v', ''
      if cs.gt releaseVersion, [bootloaderVersion]
        console.log "New Bootloader Version Detected!"
        console.log "Current Version: #{bootloaderVersion}"
        console.log "New Version: #{releaseVersion}"
        return (require '../../updater/latest/index').updateBootloader body.tag_name
      else
        console.log "Bootloader up to date (v#{bootloaderVersion})"
        cb()
    else
      console.log "Unable to get bootloader release version info, skipping...."
      cb()
checkUpdater = (cb) ->
  client.get 'http://lptracker-updates.cluster.arm1stice.com/repos/LP-Tracker/lpt-updater/releases/latest', (err, status, body) ->
    if body isnt undefined
      body = JSON.parse body
      releaseVersion = body.tag_name.replace 'v', ''
      if cs.gt releaseVersion, [updaterVersion]
        console.log "New Updater Version Detected!"
        console.log "Current Version: #{updaterVersion}"
        console.log "New Version: #{releaseVersion}"
        return (require '../../updater/latest/index').updateUpdater body.tag_name
      else
        console.log "Updater up to date (v#{updaterVersion})"
        cb()
    else
      console.log "Unable to get updater release version info, skipping...."
      cb()
checkApplication = (cb) ->
  client.get 'http://lptracker-updates.cluster.arm1stice.com/repos/LP-Tracker/lpt-application/releases/latest', (err, status, body) ->
    if body isnt undefined
      body = JSON.parse body
      releaseVersion = body.tag_name.replace 'v', ''
      if cs.gt releaseVersion, [applicationVersion]
        console.log "New Application Version Detected!"
        console.log "Current Version: #{applicationVersion}"
        console.log "New Version: #{releaseVersion}"
        return (require '../../updater/latest/index').updateApplication body.tag_name
      else
        console.log "Application up to date (v#{applicationVersion})"
        app.on 'window-all-closed', ->
          app.quit()
        cb()
    else
      console.log "Unable to get application release version info, skipping...."
      cb()
