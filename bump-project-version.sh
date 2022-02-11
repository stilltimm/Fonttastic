CURRENT_VERSION_PATH=./.current-project-version

# Get version
version=$( cat $CURRENT_VERSION_PATH )
echo "Current project version is '$version'"

# Bump & Save version
version=$((version+1))
printf $version > $CURRENT_VERSION_PATH
echo "Bumped & saved project version, so it is '$version' now"