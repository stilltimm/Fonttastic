import ProjectDescription

extension TargetScript {

    public static func tuistLint() -> TargetScript {
        return .post(
            script: """
            if command -v tuist &> /dev/null
            then
              echo "Tuist found, will lint project"
              tuist lint code
            else
              echo "Tuist could not be found, will skip linting project"
            fi
            """,
            name: "Tuist Lint If Available",
            runForInstallBuildsOnly: true
        )
    }

    public static func fixSPM() -> TargetScript {
        return .pre(
            script: """
            if [ ${CONFIGURATION} != "Release" ] && [ ${CONFIGURATION} != "Debug" ]
            then
              if [ -d "${SYMROOT}/Release${EFFECTIVE_PLATFORM_NAME}/" ]
              then
                cp -f -R "${SYMROOT}/Release${EFFECTIVE_PLATFORM_NAME}/" "${SYMROOT}/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}/"
                echo "Successfully copied 'Release' config products for '${CONFIGURATION}' config"
              else
                echo "'Release${EFFECTIVE_PLATFORM_NAME}' products not found"
              fi
            else
              echo "Building for '${CONFIGURATION}' config which is considered Debug or Release, no need to fix SPM"
            fi
            """,
            name: "Fix SPM",
            runForInstallBuildsOnly: false
        )
    }
}
