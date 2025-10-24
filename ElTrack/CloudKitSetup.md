//
//  CloudKitSetup.md
//  ElTrack - CloudKit Setup Instructions
//
//  Created by Daniel Karlin on 10/23/25.
//

# CloudKit Setup Instructions for ElTrack

## Step 1: Enable CloudKit Capability

1. **Open your project in Xcode**
2. **Select your project** in the Project Navigator (top item)
3. **Select your app target** (ElTrack)
4. **Click on "Signing & Capabilities" tab**
5. **Click the "+ Capability" button**
6. **Search for and add "CloudKit"**
7. **Make sure "Use CloudKit" is checked**
8. **Xcode will automatically create a CloudKit container**

## Step 2: Configure CloudKit Container (Optional)

If you want to customize your CloudKit container:

1. **Click on the container name** in the CloudKit capability
2. **You can rename it** (optional) - default is usually fine
3. **Make sure it's enabled**

## Step 3: CloudKit Dashboard (Optional Setup)

You can optionally configure the CloudKit schema:

1. **Go to** [CloudKit Dashboard](https://icloud.developer.apple.com/)
2. **Sign in** with your Apple Developer account
3. **Select your app's container**
4. **The app will automatically create the "ElevatorEntry" record type** when first used

## Step 4: Test CloudKit Integration

1. **Build and run your app**
2. **Make sure you're signed into iCloud** on your device/simulator
3. **Add some elevator rides**
4. **Check the status icon** in the History tab:
   - 🔵 Blue cloud = iCloud syncing working
   - 🟠 Orange cloud with slash = No iCloud account
   - ⚫ Gray question mark = Checking status

## Step 5: Test Multi-Device Sync

1. **Install the app on another device** (or simulator)
2. **Sign in with the same Apple ID**
3. **Your elevator rides should sync** between devices
4. **Use the refresh button** (↻) in History to manually sync

## Features Added:

✅ **Automatic iCloud Sync**: Elevator rides sync across all your devices
✅ **Offline Support**: Works without internet, syncs when reconnected
✅ **Local Backup**: Uses UserDefaults as backup when iCloud unavailable  
✅ **Status Indicator**: Shows iCloud sync status in History tab
✅ **Manual Sync**: Refresh button to force sync
✅ **Seamless Migration**: Existing local data will be uploaded to iCloud

## Troubleshooting:

**Q: My data isn't syncing**
- Make sure you're signed into iCloud on both devices
- Check that CloudKit capability is properly added
- Try the manual sync button (↻)

**Q: I see "No iCloud account"**
- Sign into iCloud in Settings > [Your Name] > iCloud
- Make sure iCloud Drive is enabled

**Q: App crashes when adding entries**
- Check that CloudKit capability was added correctly
- Make sure your Apple Developer account has CloudKit access

## What Happens Behind the Scenes:

1. **When you add an elevator ride**: Saves locally + uploads to iCloud
2. **When you open the app**: Loads local data first, then syncs from iCloud
3. **When iCloud is unavailable**: Works normally with local storage
4. **When iCloud comes back**: Automatically syncs missed changes

Your elevator ride data is now preserved forever and syncs across all your Apple devices! 🎉