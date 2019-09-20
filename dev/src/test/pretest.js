#!/usr/bin/env node

/**
 * The purpose of this script is to install VS Code (without sudo),
 * so that we can install prerequisite extensions before running our tests in CI environments.
 */

const execFile = require('util').promisify(require('child_process').execFile);

// taken from node_modules/vscode/bin/test
const downloadAndUnzipVSCode = require('vscode-test').downloadAndUnzipVSCode;

async function main() {
    const executablePath = await downloadAndUnzipVSCode();
    const args = [ "--install-extension", "vscjava.vscode-java-debug", "--force" ];
    console.log(`Executing ${executablePath} ${args.join(" ")}`)

    const { stdout, stderr } = await execFile(executablePath, args);
    if (stdout) {
        console.log("Output", stdout);
    }
    if (stderr) {
        console.error("Stderr", stderr);
    }
}

main()
.then(() => console.log("Done"))
.catch((err) => {
    console.error("Failed:", err);
    process.exit(1)
});
