# Copy-CameraPhotos

A utility to transfer photos from removable media with useful workflow options.

This Powershell script makes it easy to transfer photos from your digital camera to a folder of your choice.

By default, it searches all removable media for a DCIM folder and copies all new photos within it. However, the script provides a multitude of useful options to facilitate your processing workflow, including:

* Automatic date-stamping of folders, with configurable date format

* Destination path

* Create a subfolder automatically, eg 'Export' for LightRoom exports

* Optionally add a suffix to each folder created

* Optionally do not mark the photos on removable media as copied, so they can be easily re-copied elsewhere / in future

* Eject the removable media automatically after the copy

# Installation / use

**Basic use/testing**
Download Copy-CameraPhotos.ps1 to a location of your choice.
Open Powershell
Navigate to download location
Run the script with .\Copy-CameraPhotos.ps1

**Installation**
Download Copy-CameraPhotos.ps1 and copy it to a folder in the user's path, eg C:\Users\<username>\Documents\WindowsPowerShell
Then run the script from a powershell session with Copy-CameraPhotos.ps1

**Running automatially on device insertion**
I've not tried this, but customising the script to the user's requirements, then converting to an exe with a suitable utility *should* work

# Examples

**Copy all new photos from all inserted removable media to the user's Pictures folder, separating photos by date in the format "YYYY_MM_DD", create a sub folder called "Export" within each folder, and eject (safe-remove) the media after completion:**

.\Copy-CameraPhotos.ps1


**As above, but add '_Wedding' to the end of the destination folder's name:**

.\Copy-CameraPhotos.ps1 -Suffix _Wedding

**Download photos to specific location, splitting folders into year-month format. Don't eject media after copy:**

.\Copy-CameraPhotos.ps1 -DestinationPath D:\Photos -DestinationFormat '{0:yyyy}-{0:MM}' -NoEject

**Note: the DestinationFormat parameter uses the standard Powershell formatting operator -f - see [here](https://ss64.com/ps/syntax-f-operator.html)**

