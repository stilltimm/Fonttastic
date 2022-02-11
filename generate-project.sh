# Fetch Dependencies
./.tuist-bin/tuist dependencies fetch

# Generate Project
TUIST_PROJECT_VERSION=$( cat ./.current-project-version ) ./.tuist-bin/tuist generate