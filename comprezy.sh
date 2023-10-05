#!/bin/bash

#Function to check if a package is installed and install it if not
checkPackage() {

	local packageName="$1"
	
	if ! command -v "$packageName" &>/dev/null; then
		echo "$packageName is not installed. Attempting to install..."

		#Check the package manager and install accordingly
		if command -v dnf &>/dev/null; then
			sudo dnf install -y "$packageName"

		elif command -v yum &>/dev/null; then
			sudo yum install -y "$packageName"

		elif command -v apt-get &>/dev/null; then
			sudo apt-get install -y "$packageName"
			
		else
			echo "Unsupported package manager. Please install $packageName manually."
            exit 1
        fi
    fi
}

#Function to compress files/directories using tar and gzip
compressWith_gz() {

    checkPackage "tar"
    checkPackage "gzip"
    
    read -p "Enter the path to the file/directory: " sourcePath
    read -p "Enter the desired name for the compressed file: " compressedName
    
    # Add .tar.gz extension to the user's input
    compressedName="${compressedName}.tar.gz"
    
    # Create the compressed file
    tar -czvf "$compressedName" "$sourcePath"
    
    read -p "Do you want to delete the original files (y/n)? " deleteOriginal
	
    if [ "$deleteOriginal" == "y" ]; then
	
		rm -r "$sourcePath"
		
    fi
}

# Function to compress files/directories using tar and xz
compressWith_xz() {

    checkPackage "tar"
    checkPackage "xz"
    
    read -p "Enter the path to the file/directory: " sourcePath
    read -p "Enter the desired name for the compressed file: " compressedName
    
    # Add .tar.xz extension to the user's input
    compressedName="${compressedName}.tar.xz"
    
    # Create the compressed file
    tar -cvf - "$sourcePath" | xz -zv > "$compressedName"
    
    read -p "Do you want to delete the original files (y/n)? " deleteOriginal
	
    if [ "$deleteOriginal" == "y" ]; then
	
        rm -r "$sourcePath"
		
    fi
}

# Function to create a tar archive
archiveWith_tar() {

    checkPackage "tar"
    
    read -p "Enter the path to the file/directory: " sourcePath
    read -p "Enter the desired name for the archive: " archiveName
    
    # Add .tar extension to the user's input
    archiveName="${archiveName}.tar"
    
    # Create the tar archive
    tar -cvf "$archiveName" "$sourcePath"
    
    read -p "Do you want to delete the original files (y/n)? " deleteOriginal
	
    if [ "$deleteOriginal" == "y" ]; then
	
        rm -r "$sourcePath"
		
    fi
}

# Function to set the default directory in Settings for compressed files 
setDefaultDirectory() {

	read -p "Enter the default directory path: " default_dir
	echo "DEFAULT_DIR=\"$default_dir\"" > settings.conf
	echo "Default directory is set to: $default_dir"
	read -p "Press Enter to continue..."

}

# Function to update xz and gzip packages
updatePackages() {

	checkPackage "xz"
    	checkPackage "gzip"
    	echo "xz and gzip packages are up to date."
    	read -p "Press Enter to continue..."

}

# Load Settings in from settings.conf if it exists
if [ -e settings.conf  ]; then

	source settings.conf

else

	DEFAULT_DIR=""

fi

# Main menu
while true; do

    clear
    echo "-=-=-=- Comprezy: Azzy's Archive Tool -=-=-=-"
    echo " "
    echo "1. Compress using gz"
    echo "2. Compress using xz"
    echo "3. Archive with Tar"
    echo "4. Settings"
    echo "5. Exit"
    echo " "
		
    read -p "Choose an Option:" choice
	
    case $choice in
	
        1) compressWith_gz ;;
        2) compressWith_xz ;;
        3) archiveWith_tar ;;
        4) 

		clear
            	echo "-=-=-=- Settings -=-=-=-"
		echo " "
            	echo "1. Set Default Directory"
            	echo "2. Update Packages"
            	echo "3. Back"
		echo " "
            	read -p "Enter your choice: " settings_choice
            	case $settings_choice in
                	1) setDefaultDirectory ;;
                	2) updatePackages ;;
                	3) ;;
                	*) echo "Invalid choice. Please select a valid option." ;;
            	esac ;;
        5) exit 0 ;;
        *) echo "Invalid choice. Please select a valid option." ;;
		
    esac
	
    read -p "Press Enter to continue..."
	
    done

}
