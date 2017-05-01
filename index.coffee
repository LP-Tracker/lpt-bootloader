# Start the application
bootloaderVersion = (require './package.json').version
updaterVersion = (require '../../updater/latest/package.json').version
applicationVersion = (require '../../application/latest/package.json').version
electron = require 'electron'
app = electron.app
github = require 'octonode'
cs = require 'compare-semver'
client = github.client()
app.once 'ready', ->
  if process.env.NODE_ENV is "development" then return require "../../application/latest/index"
  client.get '/repos/LP-Tracker/lpt-bootloader/releases/latest', {}, (err, status, body, headers) ->
    releaseVersion = body.tag_name.replace 'v', ''
    if cs.gt releaseVersion, [bootloaderVersion]
      console.log "New Bootloader Version Detected!"
      console.log "Current Version: #{bootloaderVersion}"
      console.log "New Version: #{releaseVersion}"
      return (require '../../updater/latest/index').updateBootloader body.tag_name
    else
      console.log "Bootloader up to date (v#{bootloaderVersion})"
      client.get '/repos/LP-Tracker/lpt-updater/releases/latest', {}, (err, status, body, headers) ->
        releaseVersion = body.tag_name.replace 'v', ''
        if cs.gt releaseVersion, [updaterVersion]
          console.log "New Updater Version Detected!"
          console.log "Current Version: #{updaterVersion}"
          console.log "New Version: #{releaseVersion}"
          return (require '../../updater/latest/index').updateUpdater body.tag_name
        else
          console.log "Updater up to date (v#{updaterVersion})"
          client.get '/repos/LP-Tracker/lpt-application/releases/latest', {}, (err, status, body, headers) ->
            releaseVersion = body.tag_name.replace 'v', ''
            if cs.gt releaseVersion, [applicationVersion]
              console.log "New Application Version Detected!"
              console.log "Current Version: #{applicationVersion}"
              console.log "New Version: #{releaseVersion}"
              return (require '../../updater/latest/index').updateApplication body.tag_name
            else
              console.log "Application up to date (v#{bootloaderVersion})"
              require "../../application/latest/index"
