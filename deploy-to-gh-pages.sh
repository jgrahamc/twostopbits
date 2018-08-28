#!/usr/bin/env bash

# We take the built `build-gh-pages` content from the `master` branch
# and deploy it as a commit to the `qh-pages` branch.

# This is adapted from
# <https://github.com/steveklabnik/automatically_update_github_pages_with_travis_example>.

# If there's an error during any command, exit the script. If any
# unset environment variable is used, exit the script.
set -o errexit -o nounset

# We only proceed if this deployment was initiated by a commit to
# `master`.
test "$TRAVIS_PULL_REQUEST" == "false" || exit 0
test "$TRAVIS_BRANCH" == "master" || exit 0

# We clone the `gh-pages` branch. If it doesn't exist yet, we create a
# new branch with an empty history.
git clone "https://$ROCKETNIABOT_GH_TOKEN@github.com/arclanguage/anarki.git" build-gh-pages/repo
cd build-gh-pages/repo
git checkout gh-pages || git checkout --orphan gh-pages

# We replace all the files with the contents of the
# build-gh-pages/site/ directory, plus a short readme. We stage all
# the files for a commit.
git rm -r .
cp -r ../site/* .
echo 'This branch is automatically generated and deployed. See the scripts .travis.yml and deploy-to-gh-pages.sh on the Anarki `master` branch.' > README.md
git add .

# We make a commit to the `gh-pages` branch that looks a lot like the
# latest commit to `master`.
git config user.name "$(git log -1 --pretty=%an master)"
git config user.email "$(git log -1 --pretty=%ae master)"
git commit -m "$(git log -1 --pretty=%B master)"

# We push this new commit to the `gh-pages` branch. We specify the
# remote branch as `refs/heads/gh-pages` so that we create the branch
# if it doesn't exist yet.
git push -q origin HEAD:refs/heads/gh-pages