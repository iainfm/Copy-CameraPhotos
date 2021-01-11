<#
.Synopsis
   Utility to transfer photos from removable media to a destination of choice.

.DESCRIPTION
    The utility recursively copies files from removable media to the destination, which can be customised, with an a subfolder (for example an 'export' folder) created automatically.

.EXAMPLE
    Copy-CameraPhotos
    Basic use - searches all removable media for DCIM folders and copies new files to the 'Pictures' folder in a subfolder based on the last modified time (YYYY_MM_DD). The Archive attibute is cleared after the file copy.

.EXAMPLE
    Copy-CameraPhotos -AllFiles -DestinationFormat '{0:yyyy}-{0:MM}' -NoExportFolder -NoEject -Suffix '_Wedding'
    Process all files on removable media (ignore Archive attribute, destination folder format YYYY-MM_Wedding, don't create an export folder within the destination folder, don't eject the removable media after processing.

.INPUTS
   None

.OUTPUTS
   None

.PARAMETER AllFiles
    Process all files, not just ones with the Archive attribute set

.PARAMETER DestinationFormat
    Specifies how the destination folder for each file is named. Default is YYYY_MM_DD

.PARAMETER DestinationPath
    Specifies the root folder for destination. Defaults to the Windows 'Pictures' folder

.PARAMETER DriveType
    Specify the drive type to process. Default is 2 (removable drives)

.PARAMETER ExportFolderName
    Specify the name of an optional folder to create under each destination. Useful for automatically creating an export folder for LightRoom etc. Default is 'Export'

.PARAMETER KeepArchiveAttribute
    Default processing will reset the Archive attribute on new files so they are not re-copied in future. Set to override this behaviour.

.PARAMETER NoEject
    Prevent the script automatically ejecting (unmounting) the removable media allowing it to be removed safely.
.PARAMETER OpenExplorer
    Open the destination folder in Explorer once processing is complete.

.PARAMETER Quiet
    Suppress all processing output.

.PARAMETER SourceDrive
    Specify the source drive to process (eg E:). Default is to process all removable (unless overridden with -DriveType) drives.

.PARAMETER Suffix
    Optional descriptive suffix to add to every subfolder created. Examples: '_Wedding', '_JobNumber1234' etc

.PARAMETER RootFolder
    Specify the name of the root source folder on the media. Defaults to DCIM. Only drives with this folder will be processed.

.NOTES
   DestinationFormat uses standard PowerShell formatting operator (-f). See https://ss64.com/ps/syntax-f-operator.html

.FUNCTIONALITY
   Workflow automation
#>

[CmdletBinding()]

param (
    [switch]$AllFiles = $false,
    [string]$DestinationFormat = '{0:yyyy}_{0:MM}_{0:dd}',
    [string]$DestinationPath = [Environment]::GetFolderPath('MyPictures'),
    [int]$DriveType = 2,
    [string]$ExportFolderName = 'Export',
    [switch]$KeepArchiveAttribute = $false,
    [switch]$NoEject,
    [switch]$NoExportFolder,
    [switch]$OpenExplorer, # TODO
    [switch]$Quiet = $false,
    [string]$SourceDrive,
    [string]$Suffix = "",
    [string]$RootFolder = "DCIM"
)

if (!$SourceDrive) {

    # Process all removable drives

    $drives = Get-CimInstance -className CIM_LogicalDisk

    }

    else {

    # Only process the removable drive requested

    $drives = Get-CimInstance -className CIM_LogicalDisk -Filter "DeviceID = '$SourceDrive'"

    }

# Create the destination root folder path if it doesn't exist

if (!(Test-Path -path $destinationPath)) { New-Item -Force $destinationPath -Type Directory | Out-Null }

# Initialise reporting stats

$totalFiles = 0; $totalSize = 0; $copied =0; $totalCopied = 0; $missed = 0;

# Process the drives

ForEach ($drive in $drives) {

    $removableDrives += 1

    # Check if the drive is the right type

	if ($drive.DriveType -eq $DriveType) {

		$driveLetter = $drive.DeviceID

        # And it has a DCIM (unless overridden) folder in the root

		if (Test-Path -Path "$driveLetter\$RootFolder" -PathType Container) {

            # Find all files with the required attributes

            if ($AllFiles) {

                # Build a list of all files

			    $newFiles = Get-ChildItem -Path "$driveLetter\$RootFolder" -Recurse

            }

            else {

                # Build a list of all files with the archive attribute set

                $newFiles = Get-ChildItem -Path "$driveLetter\$RootFolder" -Recurse -Attributes 'Archive'
                
            }    

            # Process each file

			ForEach ($newFile in $newFiles) {

                # Update the stats

                $totalFiles += 1; $totalSize  += $newFile.Length

                # Get the file date

				$fileDate = $newFile.LastWriteTime

                # Build the destination path

                $subFolder = "$DestinationFormat$Suffix" -f ($newFile.LastWriteTime)

				if (!$Quiet) { Write-Output "Copy $newFile to $destinationPath\$subFolder" }

                # Check if destination exists and create if not

				if (!(Test-Path -path "$destinationPath\$subFolder")) {

					New-Item "$destinationPath\$subFolder" -Type Directory -Force | Out-Null

                    # Create a subfolder if required

					if (!$NoExportFolder) { New-Item "$destinationPath\$subFolder\$ExportFolderName" -Type Directory | Out-Null }

					}

                try {

                    # Copy the file to the destination

				    Copy-Item -Path $newFile.FullName -Destination "$destinationPath\$subFolder"

                    # Update the stats

                    $copied += 1; $totalCopied += $newFile.Length

                    # Clear the Archive bit unless forbidden

                    if (!$KeepArchiveAttribute) { $newFile.Attributes -= 'Archive' }

                }

                # If any of this fails, update the missed count

                catch { $missed += 1 }

			}

		if (!$NoEject) {

            # Eject the media

			if (!$Quiet) { Write-Output "Ejecting $driveLetter" }
            
			$Eject = New-Object -ComObject Shell.Application

			$Eject.NameSpace(17).ParseName($driveLetter).InvokeVerb("Eject")

			}

		}

	}

}

if (!$Quiet) {

    if ($copied -eq 0) { Write-Warning "No files copied." }

    if ($copied -ne $totalFiles) { Write-Warning "Some files missed." }

    Write-Output ("Transferred {0} file(s) out of {1}, total {2:n2} Mb." -f $copied, $totalFiles, ($totalSize / 1MB))

}

exit
