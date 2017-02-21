fs = require("fs")
getFileName = ->
    configFolder = require('os').homedir()+"/.config"
    if !fs.existsSync(configFolder)
        fs.mkdirSync(configFolder)
    configFolder+"/mylyn.json"

loadState = ->
  try
    return JSON.parse(fs.readFileSync(getFileName(), 'utf8'));
  catch error


saveState = (state)->
      fs.writeFile(getFileName(), JSON.stringify(state) , 'utf-8',(e)->e);

module.exports =
    {saveState,loadState}
