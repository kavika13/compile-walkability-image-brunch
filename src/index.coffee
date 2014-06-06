Png = require('pngjs').PNG
fs = require 'fs'

module.exports = class WalkabilityImageCompiler
    brunchPlugin: yes
    type: 'javascript'

    processImage: (path, callback) ->
        # reading in again since framework always reads w/ utf-8
        fs.createReadStream(path)
            .pipe(new Png {filterType: 4})
            .on 'parsed', () ->
                output = 'exports.width = ' + this.width + ';\n'
                output += 'exports.height = ' + this.height + ';\n'

                output += 'exports.contents = [\n'
                mapCell =
                    walkable: 0
                    unwalkable: 1
                    door: 2
                pixelToWalkabilityMap =
                    '255255255': mapCell.walkable
                    '000': mapCell.unwalkable
                    '25500': mapCell.door

                getPixelString = (x, y) =>
                    idx = (this.width * y + x) << 2
                    pixelString = '' + this.data[idx] + this.data[idx + 1] +
                        this.data[idx + 2]
                    if pixelString not of pixelToWalkabilityMap
                        callback 'failed to extract pixel: ' + pixelString
                        return
                    return pixelToWalkabilityMap[pixelString]

                for y in [0 ... this.height]
                    output += '    '
                    for x in [0 ... this.width]
                        pixelString = getPixelString x, y
                        output += pixelString
                        if not (y == this.height - 1 and x == this.width - 1)
                            output += ', '
                    output += '\n'

                output += ']'

                callback null, {data: output}

    constructor: (@config) ->
        @pattern = @config.plugins?.walkabilityImages?.pattern ?
            /^app[\\/]walkabilityimages[\\/].*\.png/

    compile: (data, path, callback) ->
        @processImage path, callback
