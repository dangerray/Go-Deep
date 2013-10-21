require 'pathname'

# ENV['WORKSPACE_PATH'] is something like "/Users/jonsibley/Dropbox/code/GoDeep/GoDeep.xcworkspace"
p = Pathname.new(ENV['WORKSPACE_PATH'])
project_dir = p.dirname.to_s

# Check for user "ios" to know if this is being run on our Xcode CI environment
# if ENV['USER'] == "ios"
    `ruby #{project_dir}/scripts/setCommitHashAsBundleVersion.rb`
# end
