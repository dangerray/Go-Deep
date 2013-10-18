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

# Exit early if we're not running in the continuous integration environment
if ENV["USER"] != "iOS"
  exit
end

# Specify the path to your plist
info_file_path = "../Deep\\ Link\\ Helper/Deep\\ Link\\ Helper-Info.plist"

# `git describe` output is as follows:
#  	git_details[0] is the name of the most recent tag
#  	git_details[1] is the number of commits since the most recent tag
#  	git_details[2] is the partial hash of the most recent commit
git_details = `/usr/bin/env git describe --long`.chomp.split("-")
version_suffix = " (b#{git_details[1]} #{git_details[2]})"

# Get the current value of CFBundleShortVersionString from your info plist
version_prefix = `/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" #{info_file_path}`.chomp

# Update the CFBundleVersion in the info plist with our new version string
version = version_prefix + version_suffix
`/usr/libexec/PlistBuddy -c "Set :CFBundleVersion #{version}" #{info_file_path}`