#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2019 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v20.html
#
# Contributors:
#     IBM Corporation - initial API and implementation
#*******************************************************************************

if [[ "$skip_tests" == "true" ]]; then
    echo "skip_tests is true, skipping tests";
    exit 0
fi

echo "Running as user $(whoami)"

# Working directory must be dev/ (since this is where package.json is for npm test)
cd "$(dirname $0)/../dev"

# Install vs code and test prereqs
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --delete-prefix --lts

set -ex

# Compile and npm i
npm run vscode:prepublish
src/test/pretest.js

if [[ -z $CODE_TESTS_WORKSPACE ]]; then
    export CODE_TESTS_WORKSPACE="${HOME}/codewind-workspace/"
fi

# Make codewind workspace and create a file which will trigger the extension's activation
# If the tests are run before the extension is activated, it will fail with a TypeError, something like "path must be of type string, received undefined"
mkdir -p $CODE_TESTS_WORKSPACE
touch "$CODE_TESTS_WORKSPACE/.cw-settings"

# Run virtual framebuffer (installed above) https://code.visualstudio.com/api/working-with-extensions/continuous-integration#travis-ci
export DISPLAY=':99.0'
/usr/bin/Xvfb :99 -screen 0 1024x768x24 > /dev/null &

set +e

$(which npm) test --verbose
result=$?

rm -rf "$CODE_TESTS_WORKSPACE"

cd -

exit $result
