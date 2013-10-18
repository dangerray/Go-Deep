# Get project directory
# $WORKSPACE_PATH is /.../XXX.xcworkspace
# so we strip off /XXX.xcworkspace with sed
project_dir=`echo "$WORKSPACE_PATH" | sed -e "s/\/[^\/]*$//"`

#if [ ${USER}="ios" ]; then
    # Modify the build number
    ruby "$project_dir/scripts/setCommitHashAsBundleVersion.rb"
# fi