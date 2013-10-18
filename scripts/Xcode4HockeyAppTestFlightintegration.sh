#!/bin/bash
#
# (Above line comes out when placing in Xcode scheme)
#
# Inspired by original script by incanus:
# https://gist.github.com/1186990
#
# Rewritten by martijnthe:
# https://gist.github.com/1379127
#
# Rewritten by c0diq:
# https://gist.github.com/2213571
#
# - Using Xcode's environment variables instead of 'guessing' what archive we need to upload
# - AppleScript dialogs for basic user interaction (upload yes/no, select code signing identity, enter release notes, )
# - Supports both HockeyApp & TestFlight
#
#
# =====================================================================================================================
# ***  BASIC CONFIGURATION:
#
# Find your API_TOKEN at: https://testflightapp.com/account/
TESTFLIGHT_API_TOKEN="87a148ccbc68458c6b18e8dd3f9215bf_MTU0NzI1MjAxMS0wOS0xMyAxNToxODowMi45NjIzNzI"
#
# Find your TEAM_TOKEN at: https://testflightapp.com/dashboard/team/edit/
TESTFLIGHT_TEAM_TOKEN="15bf22d30e610f8023e948b3d328dabc_MjM2NzY2MjAxMy0wNi0xNCAxNTowOToyOS4xNjgwODY"
#
# Find your API_TOKEN at: https://rink.hockeyapp.net/manage/auth_tokens
HOCKEYAPP_API_TOKEN="xxxx"
#
# Distribution List names, comma separated (quoted) string, e.g. "DevTeam,Clients,BetaTesters":
DISTRIBUTION_LISTS="DevTeam,QA,BetaTesters,Investors,Press"
#
# Default selection of Distribution List(s), e.g. "DevTeam,Clients":
DISTRIBUTION_LISTS_DEFAULT_SELECTION="DevTeam,QA"
#
# Default selection for the Notify team members dialog ("True" -> Notify team members, "False" -> Don't notify):
DEFAULT_NOTIFY_VALUE="FALSE"
#
# Upload service ("HockeyApp" or "TestFlight")
UPLOAD_SERVICE="TestFlight"
#
# =====================================================================================================================
# ***  OPTIONAL CONFIGURATION:
#
# Uncomment this line to skip the resigning / re-provisioning steps:
# The application is expected to be already provisioned and signed.
#
SKIP_RESIGNING_AND_REPROVISIONING="YES"
#
# Uncomment this line to skip the Release Notes input step and to set a default value:
#
DEFAULT_RELEASE_NOTES="Just another test version."
#
# Uncomment this line to skip the Distribution Lists input step and to use the default value:
#
SKIP_DISTRIBUTION_LISTS="YES"
#
# Uncomment this line to skip the Notify? input step and to use the default value:
#
SKIP_NOTIFY="YES"
#
# Uncomment this line to enable loading Console.app
#
SHOW_DEBUG_CONSOLE="YES"
#
# Uncomment this line to disable opening the browser with the TestFlight dashboard at the end of the ride
#
#DISABLE_OPEN_DASHBOARD="YES"
#
# =====================================================================================================================

# Setup logging stuff...
LOG="/tmp/package.log"
/bin/rm -f $LOG
echo "Starting Upload Process" > $LOG
if [ "$SHOW_DEBUG_CONSOLE" = "YES" ]; then
    /usr/bin/open -a /Applications/Utilities/Console.app $LOG
fi

echo >> $LOG

echo "CODE_SIGN_IDENTITY: $CODE_SIGN_IDENTITY" >> $LOG
echo "WRAPPER_NAME: $WRAPPER_NAME" >> $LOG
echo "ARCHIVE_DSYMS_PATH: $ARCHIVE_DSYMS_PATH" >> $LOG
echo "ARCHIVE_PRODUCTS_PATH: $ARCHIVE_PRODUCTS_PATH" >> $LOG
echo "DWARF_DSYM_FILE_NAME: $DWARF_DSYM_FILE_NAME" >> $LOG
echo "INSTALL_PATH: $INSTALL_PATH" >> $LOG
echo "PRODUCT_NAME: $PRODUCT_NAME" >> $LOG

# Do some existence checks for the build settings that this script depends on:
if [ "$CODE_SIGN_IDENTITY" = "" -o "$WRAPPER_NAME" = "" -o "$ARCHIVE_DSYMS_PATH" = "" -o "$ARCHIVE_PRODUCTS_PATH" = "" -o "$DWARF_DSYM_FILE_NAME" = "" -o "$INSTALL_PATH" = "" ]; then
    osascript -e "tell application \"Xcode\"" -e "display dialog \"It looks like we're missing build settings.\n\nYou can fix this by editing your scheme's Run Script action and selecting the appropriate target from the 'Provide build settings from...' drop down menu.\" buttons {\"OK\"} default button \"OK\" with icon stop" -e "end tell"
    exit 1
fi

# Build paths from build settings environment vars:
DSYM_PATH="$ARCHIVE_DSYMS_PATH"
APP="$ARCHIVE_PRODUCTS_PATH/$INSTALL_PATH/$WRAPPER_NAME"

# Ask if we need to proceed to upload to TestFlight using an AppleScript dialog in Xcode:
SHOULD_UPLOAD=`osascript -e "tell application \"Xcode\"" -e "set noButton to \"No, Thanks\"" -e "set yesButton to \"Yes!\"" -e "set upload_dialog to display dialog \"Do you want to upload this build to $UPLOAD_SERVICE?\" buttons {noButton, yesButton} default button yesButton with icon 1" -e "set button to button returned of upload_dialog" -e "if button is equal to yesButton then" -e "return 1" -e "else" -e "return 0" -e "end if" -e "end tell"`

# Exit this script if the user indicated we shouldn't upload:
if [ "$SHOULD_UPLOAD" = "0" ]; then
    echo "User indicated not to upload this archive. Quitting." >> $LOG
    exit 0
fi #SHOULD_UPLOAD


# Now onto selecting signing identity and provisioning profiles...
if [ "$SKIP_RESIGNING_AND_REPROVISIONING" != "YES" ]; then
    echo >> $LOG
    echo "Finding signing identities..." >> $LOG

    # Get all the user's code signing identities. Filter the response to get a neat list of quoted strings:
    SIGNING_IDENTITIES_LIST=`security find-identity -v -p codesigning | egrep -oE '"[^"]+"'`
    echo >> $LOG
    echo "Found identities:" >> $LOG
    echo "$SIGNING_IDENTITIES_LIST" >> $LOG

    # Replace the newline characters in the list with commas and remove the last comma:
    SIGNING_IDENTITIES_COMMA_SEPARATED_LIST=`echo "$SIGNING_IDENTITIES_LIST" | tr '\n' ',' | sed 's/,$//'`
    # Present dialog with list of code signing identites and let the user pick one. The identity that from the build settings is selected by default.
    CODE_SIGN_IDENTITY=`osascript -e "tell application \"Xcode\"" -e "set selected_identity to {choose from list {$SIGNING_IDENTITIES_COMMA_SEPARATED_LIST} with prompt \"Choose code signing identity:\" default items {\"$CODE_SIGN_IDENTITY\"}}" -e "end tell" -e "return selected_identity"`

    echo >> $LOG
    if [ "$CODE_SIGN_IDENTITY" = "false" ]; then
        echo "User cancelled." >> $LOG
        exit 0
    fi

    echo "Selected code signing identity:" >> $LOG
    echo "$CODE_SIGN_IDENTITY" >> $LOG

    # Now onto the provisioning profiles...
    TEMP_MOBILEPROVISION_PLIST_PATH=/tmp/mobileprovision.plist
    TEMP_CERTIFICATE_PATH=/tmp/certificate.cer
    MOBILEDEVICE_PROVISIONING_PROFILES_FOLDER="${HOME}/Library/MobileDevice/Provisioning Profiles"
    MATCHING_PROFILES_LIST=""
    MATCHING_NAMES_LIST=""
    cd "$MOBILEDEVICE_PROVISIONING_PROFILES_FOLDER"
    for MOBILEPROVISION_FILENAME in *.mobileprovision
    do
        # Use sed to rid the signature data that is padding the plist and store clean plist to temp file:
        sed -n '/<!DOCTYPE plist/,/<\/plist>/ p' \
            < "$MOBILEPROVISION_FILENAME" \
            > "$TEMP_MOBILEPROVISION_PLIST_PATH"
        # The plist root dict contains an array called 'DeveloperCertificates'. It seems to contain one element with the certificate data. Dump to temp file:
        /usr/libexec/PlistBuddy -c 'Print DeveloperCertificates:0' $TEMP_MOBILEPROVISION_PLIST_PATH > $TEMP_CERTIFICATE_PATH
        # Get the common name (CN) from the certificate (regex capture between 'CN=' and '/OU'):
        MOBILEPROVISION_IDENTITY_NAME=`openssl x509 -inform DER -in $TEMP_CERTIFICATE_PATH -subject -noout | perl -n -e '/CN=(.+)\/OU/ && print "$1"'`

        if [ "$CODE_SIGN_IDENTITY" = "$MOBILEPROVISION_IDENTITY_NAME" ]; then
            # Yay, this mobile provisioning profile matches up with the selected signing identity, let's continue...
            # Get the name of the provisioning profile:
            MOBILEPROVISION_PROFILE_NAME=`/usr/libexec/PlistBuddy -c 'Print Name' $TEMP_MOBILEPROVISION_PLIST_PATH`			
            MATCHING_PROFILES_LIST=`echo "$MATCHING_PROFILES_LIST\"$MOBILEPROVISION_PROFILE_NAME\"|\"$MOBILEPROVISION_FILENAME\","`
            MATCHING_NAMES_LIST=`echo "$MATCHING_NAMES_LIST\"$MOBILEPROVISION_PROFILE_NAME\","`
        fi
    done
    # Remove last comma:
    MATCHING_NAMES_LIST=`echo "$MATCHING_NAMES_LIST" | sed 's/,$//'`
    # Remove last pipe:
    MATCHING_PROFILES_LIST=`echo "$MATCHING_PROFILES_LIST" | sed 's/,$//'`

    echo >> $LOG
    echo "Matching provisioning profiles:" >> $LOG
    echo "$MATCHING_PROFILES_LIST" >> $LOG

    # Add the (default) value for using the existing embedded.mobileprovision:
    USE_EXISTING_PROFILE="\"Don't overwrite the current provisioning profile\""
    MATCHING_NAMES_LIST=`echo "$USE_EXISTING_PROFILE,$MATCHING_NAMES_LIST"`
    # Present dialog with list of matching provisioning profiles and let the user pick one.
    SELECTED_PROFILE_NAME=`osascript -e "tell application \"Xcode\"" -e "set selected_profile to {choose from list {$MATCHING_NAMES_LIST} with prompt \"Choose provisioning profile:\" default items {$USE_EXISTING_PROFILE}}" -e "end tell" -e "return selected_profile"`
    if [ "$SELECTED_PROFILE_NAME" = "false" ]; then
        echo "User cancelled." >> $LOG
        exit 0
    fi

    SELECTED_PROFILE_FILE=`echo "$MATCHING_PROFILES_LIST" | tr "," "\n" | grep "$SELECTED_PROFILE_NAME" | tr "|" "\n" | sed -n 2p`

    echo >> $LOG
    echo "Selected provisioning profile:" >> $LOG
    if [ "$SELECTED_PROFILE_FILE" != "" ]; then
        # Remove quotes (needed before for AppleScript): 
        SELECTED_PROFILE_FILE=`echo "$SELECTED_PROFILE_FILE" | tr -d "\""`
        EMBED_PROFILE="$MOBILEDEVICE_PROVISIONING_PROFILES_FOLDER/$SELECTED_PROFILE_FILE"
        echo "$SELECTED_PROFILE_FILE : $SELECTED_PROFILE_NAME" >> $LOG
        echo "$EMBED_PROFILE" >> $LOG
    else
        EMBED_PROFILE="$APP/embedded.mobileprovision"
        echo "None selected. Keeping existing embedded.mobileprovision file:" >> $LOG
        echo "$EMBED_PROFILE" >> $LOG
    fi

fi #SKIP_RESIGNING_AND_REPROVISIONING

# Now onto the Release Notes...
if [ "$DEFAULT_RELEASE_NOTES" = "" ]; then
    # Bring up an AppleScript dialog in Xcode to enter the Release Notes for this (beta) build:
    NOTES=`osascript -e "tell application \"Xcode\"" -e "set notes_dialog to display dialog \"Please provide some release notes:\nHint: use Ctrl-J for New Line.\" default answer \"\" buttons {\"Next\"} default button \"Next\" with icon 1" -e "set notes to text returned of notes_dialog" -e "end tell" -e "return notes"`
else
    NOTES="$DEFAULT_RELEASE_NOTES"
fi #DEFAULT_RELEASE_NOTES

# add default if user entered nothing otherwise it will fail 
if [ "$NOTES" = "" ]; then
    NOTES="Just another test"
fi

echo "Added release notes:" >> $LOG
echo "$NOTES" >> $LOG

# Now onto selecting the Distribution Lists...
if [ "$SKIP_DISTRIBUTION_LISTS" != "YES" ]; then
    DISTRIBUTION_LISTS_QUOTED=`echo "$DISTRIBUTION_LISTS" | tr "," "\n" | sed 's/$/"/' | sed 's/^/"/' | tr "\n" "," | sed 's/,$//'`	
    DISTRIBUTION_LISTS_DEFAULT_SELECTION_QUOTED=`echo "$DISTRIBUTION_LISTS_DEFAULT_SELECTION" | tr "," "\n" | sed 's/$/"/' | sed 's/^/"/' | tr "\n" "," | sed 's/,$//'`	
    SELECTED_DISTRIBUTION_LISTS_QUOTED=`osascript -e "tell application \"Xcode\"" -e "set selected_profile to {choose from list {$DISTRIBUTION_LISTS_QUOTED} with prompt \"Choose Distribution List(s):\" default items {$DISTRIBUTION_LISTS_DEFAULT_SELECTION_QUOTED} with multiple selections allowed}" -e "end tell" -e "return selected_profile"`
    if [ "$SELECTED_DISTRIBUTION_LISTS_QUOTED" = "false" ]; then
        echo "User cancelled." >> $LOG
        exit 0
    fi

    SELECTED_DISTRIBUTION_LISTS=`echo "$SELECTED_DISTRIBUTION_LISTS_QUOTED" | sed 's/, /,/'`
else
    SELECTED_DISTRIBUTION_LISTS="$DISTRIBUTION_LISTS_DEFAULT_SELECTION"
fi #SKIP_DISTRIBUTION_LISTS

echo >> $LOG
echo "Selected Distribution Lists: '$SELECTED_DISTRIBUTION_LISTS'" >> $LOG


if [ "$SKIP_NOTIFY" != "YES" ]; then
    # Ask if we need to notify the permitted team members of the new build:
    if [ "$DEFAULT_NOTIFY_VALUE" = "True" ]; then
        SELECTED_NOTIFY_BUTTON="Yes, Please!"
    else
        SELECTED_NOTIFY_BUTTON="No, Thanks"
    fi
    SHOULD_NOTIFY=`osascript -e "tell application \"Xcode\"" -e "set noButton to \"No, Thanks\"" -e "set yesButton to \"Yes, Please!\"" -e "set upload_dialog to display dialog \"Do you want to have your team members notified by TestFlight about this new version?\" buttons {noButton, yesButton} default button yesButton with icon 1" -e "set button to button returned of upload_dialog" -e "if button is equal to yesButton then" -e "return \"True\"" -e "else" -e "return \"False\"" -e "end if" -e "end tell"`
else
    SHOULD_NOTIFY="$DEFAULT_NOTIFY_VALUE"
fi

echo >> $LOG
echo "Notify: $SHOULD_NOTIFY" >> $LOG

# Now onto creating the IPA...
echo >> $LOG
echo "Creating IPA at /tmp/$PRODUCT_NAME.ipa ..." >> $LOG
/bin/rm -f /tmp/app.ipa >> $LOG 2>&1
if [ "$SKIP_RESIGNING_AND_REPROVISIONING" != "YES" ]; then
    /usr/bin/xcrun -sdk iphoneos PackageApplication "${APP}" -o "/tmp/$PRODUCT_NAME.ipa" --embed "$EMBED_PROFILE" --sign "${CODE_SIGN_IDENTITY}" >> $LOG 2>&1
else
    /usr/bin/xcrun -sdk iphoneos PackageApplication "${APP}" -o "/tmp/$PRODUCT_NAME.ipa" >> $LOG 2>&1
fi #SKIP_RESIGNING_AND_REPROVISIONING

if [ "$?" -ne 0 ]; then
    echo "There were errors creating IPA." >> $LOG
    osascript -e "tell application \"Xcode\"" -e "display dialog \"There were errors creating IPA... Check $LOG\" buttons {\"OK\"} with icon stop" -e "end tell"
    /usr/bin/open -a /Applications/Utilities/Console.app $LOG
    exit 1
fi 
echo "Done creating IPA ..." >> $LOG

# Now onto creating the zipped .dSYM debugging symbols
echo >> $LOG
echo "Zipping $DSYM_PATH ($DWARF_DSYM_FILE_NAME) to /tmp/$DWARF_DSYM_FILE_NAME.zip..." >> $LOG
/bin/rm -f "/tmp/$DWARF_DSYM_FILE_NAME.zip"
pushd "$DSYM_PATH"
/usr/bin/zip -r "/tmp/$DWARF_DSYM_FILE_NAME.zip" "$DWARF_DSYM_FILE_NAME"
popd
echo "Done zipping ..." >> $LOG

# Now onto the upload itself
echo >> $LOG
echo "Uploading ... " >> $LOG

pushd "/tmp"

if [ "$UPLOAD_SERVICE" = "HockeyApp" ]; then
    /usr/bin/curl "https://rink.hockeyapp.net/api/2/apps" \
        -F status="2" \
        -F notify="$SHOULD_NOTIFY" \
        -F notes="$NOTES" \
        -F ipa=@"$PRODUCT_NAME.ipa" \
        -F dsym=@"$DWARF_DSYM_FILE_NAME.zip" \
        -H "X-HockeyAppToken: $HOCKEYAPP_API_TOKEN" >> $LOG 2>&1
else
    /usr/bin/curl "https://testflightapp.com/api/builds.json" \
        -F file=@"$PRODUCT_NAME.ipa" \
        -F dsym=@"$DWARF_DSYM_FILE_NAME.zip" \
        -F api_token="$TESTFLIGHT_API_TOKEN" \
        -F team_token="$TESTFLIGHT_TEAM_TOKEN" \
        -F replace=True \
        -F notify="$SHOULD_NOTIFY" \
        -F distribution_lists="$SELECTED_DISTRIBUTION_LISTS" \
        -F notes="$NOTES" >> $LOG 2>&1
fi

popd
if [ "$?" -ne 0 ]; then
    echo "There were errors uploading." >> $LOG
    osascript -e "tell application \"Xcode\"" -e "display dialog \"There were errors uploading... Check $LOG\" buttons {\"OK\"} with icon stop" -e "end tell"
    /usr/bin/open -a /Applications/Utilities/Console.app $LOG
    exit 1
fi

echo >> $LOG
echo "Uploaded to TestFlight!" >> $LOG
osascript -e "tell application \"Xcode\"" -e "display dialog \"Upload to $UPLOAD_SERVICE done!\" buttons {\"OK\"} default button \"OK\"" -e "end tell"

if [ "$DISABLE_OPEN_DASHBOARD" != "YES" ]; then
    echo >> $LOG

    if [ "$UPLOAD_SERVICE" = "HockeyApp" ]; then
        echo "Opening https://rink.hockeyapp.net/manage/dashboard now..." >> $LOG
        /usr/bin/open "https://rink.hockeyapp.net/manage/dashboard"
    else
        echo "Opening https://testflightapp.com/dashboard/builds/ now..." >> $LOG
        /usr/bin/open "https://testflightapp.com/dashboard/builds/"
    fi
fi