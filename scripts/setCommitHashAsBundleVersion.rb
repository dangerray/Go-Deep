#!/usr/bin/env ruby

# Xcode auto-versioning script for git by Jonathan Sibley
#   This script will set your CFBundleVersion number to the value of CFBundleShortVersionString
#   and include the current commit's distance from that tag and sha1 hash

# With CFBundleShortVersionString "1.0", and two commits since then, the build will be:
#   1.0 (b2 h12345)

# based on the script by Andre Arko (https://github.com/indirect/xcode-git-build-scripts), which was
# based on the ruby script by Abizern, which was
# based on the git script by Marcus S. Zarra and Matt Long, which was
# based on the Subversion script by Axel Andersson

require 'pathname'

# ENV['WORKSPACE_PATH'] is something like "/Users/jonsibley/Dropbox/code/GoDeep/GoDeep.xcworkspace"
p = Pathname.new(ENV['WORKSPACE_PATH'])
project_dir = p.dirname.to_s

# Specify the path to your plist
info_file_path = "#{project_dir}/Deep\\ Link\\ Helper/Deep\\ Link\\ Helper-Info.plist"

# `git describe` output is as follows:
#  	git_details[0] is the name of the most recent tag
#  	git_details[1] is the number of commits since the most recent tag
#  	git_details[2] is the partial hash of the most recent commit
git_details = `/usr/bin/env git --git-dir #{project_dir}/.git describe --long`.chomp.split("-")
version = "#{git_details[2]}"

# Update the CFBundleVersion in the info plist with our new version string
`/usr/libexec/PlistBuddy -c "Set :CFBundleVersion #{version}" #{info_file_path}`
