# Copy-CameraPhotos

A utility to transfer photos from removable media to a destination of choice.

This Powershell script makes it easy to transfer photos from your digital camera to a folder of your choice.

By default, it searches all removable media for a DCIM folder and copies all new photos within it. However, the script provides a multitude of useful options to facilitate your processing workflow, including:

* Automatic date-stamping of folders, with configurable date format

* Destination path

* Create a subfolder automatically, eg 'Export' for LightRoom exports

* Optionally add a suffix to each folder created

* Optionally do not mark the photos on removable media as copied, so they can be easily re-copied elsewhere / in future

* Eject the removable media automatically after the copy

# Examples

*Copy all new photos from all inserted removable media to the user's Pictures folder, separating photos by date in the format "YYYY_MM_DD", create a sub folder called "Export" within each folder, and eject (safe-remove) the media after completion:*

.\Copy-CameraPhotos.ps1


*As above, but add '_Wedding' to the end of the destination folder's name:*

.\Copy-CameraPhotos.ps1 -Suffix _Wedding

*Download photos to specific location, splitting folders into year-month format. Don't eject media after copy:*

.\Copy-CameraPhotos.ps1 -DestinationPath D:\Photos -DestinationFormat '{0:yyyy}-{0:MM}' -NoEject

*Note: the DestinationFormat parameter uses the standard Powershell formatting operator -f - see https://ss64.com/ps/syntax-f-operator.html*

