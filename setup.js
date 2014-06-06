var exec = require('child_process').exec;
var sysPath = require('path');
var fs = require('fs');

var mode = process.argv[2];

var fsExists = fs.exists || sysPath.exists;

var execute = function(pathParts, params, callback) {
    if (callback == null) callback = function() {};
    var path = sysPath.join.apply(null, pathParts);
    var command = 'node ' + path + ' ' + params;
    console.log('Executing', command);
    exec(command, function(error, stdout, stderr) {
        if (error != null)
            return process.stderr.write(stderr.toString());
        console.log(stdout.toString());
    });
};

var coffee_path = ['node_modules', 'coffee-script', 'bin', 'coffee'];
var compile_coffee = '-o lib/ src/';

if (mode === 'prepublish') {
    execute(coffee_path, compile_coffee);
} else if (mode === 'postinstall') {
    fsExists(sysPath.join(__dirname, 'lib'), function(exists) {
        if (exists)
            return;
        execute(coffee_path, compile_coffee);
    });
}
