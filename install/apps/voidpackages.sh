#!/bin/bash

# --- CONFIGURATION ---
packages=(
    "nwg-dock-hyprland"  
    "kbdlightmac"   
    "nwg-drawer"
    "nwg-hello"
    "nwg-look"
    "gImageReader-gtk"
    "gImageReader-qt5"
    "discord"
    "brave-browser"
  )

read -p "INITIAL setup of 'void-packages' repo. Would you like to clone void-packages repo and setup additional packages? Beware, it may take a while, like a really while :-). You can always return to this step later by doing everything on your own (cause you're a big boy/girl) or by running './.local/share/omvoid/install/apps/voidpackages.sh' from $HOME directory. So? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ ! -d ~/.local/pkgs/void-packages ]; then
          (
            git clone https://github.com/void-linux/void-packages.git ~/.local/pkgs/void-packages
            echo "Entering ~/.local/pkgs/void-packages"
            cd ~/.local/pkgs/void-packages || exit 1

            # 1. Prepare void repo
            echo "-> Preparing xbps-src environment..."
            ./xbps-src binary-bootstrap
            echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf

            # 2. Copy templates to srcpkgs
            cp -r ~/.local/share/omvoid/srcpkgs/* ~/.local/pkgs/void-packages/srcpkgs/ 
          )  
    else

        read -p "Directory ~/.local/pkgs/void-packages already exists. Would you like to recreate it from scratch or continue with the existing one? (Y - recreate it / N - continue with existing one) " -n 1 -r 

        if [[ $REPLY =~ ^[Yy]$ ]]; then
          (
            echo "\nRecreating ~/.local/pkgs/void-packages"
            sudo rm -r ~/.local/pkgs/void-packages
            git clone https://github.com/void-linux/void-packages.git ~/.local/pkgs/void-packages
            echo "Entering ~/.local/pkgs/void-packages"
            cd ~/.local/pkgs/void-packages || exit 1

            # 1. Prepare void repo
            echo "-> Preparing xbps-src environment..."
            ./xbps-src binary-bootstrap
            echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf

            # 2. Copy templates to srcpkgs
            cp -r ~/.local/share/omvoid/srcpkgs/* ~/.local/pkgs/void-packages/srcpkgs/ 
          )
        else
          
            echo "\nProceeding with existing ~/.local/pkgs/void-packages"

        fi

    fi

        (
            echo "Entering ~/.local/pkgs/void-packages"
            cd ~/.local/pkgs/void-packages || exit 1

            # --- Start of new dynamic selection logic ---
            echo
            echo "Please choose which packages to install:"
            
            # Dynamically generate the menu from the 'packages' array
            for i in "${!packages[@]}"; do
                printf "  %s) %s\n" "$((i+1))" "${packages[$i]}"
            done
            
            echo "  (e.g., '1 3', '2,4', or just press Enter to install all)"
            read -p "Your choice: " user_choice

            # Function to build and install a package
            # It takes the package name as an argument
            install_package() {

                local pkg_name="$1"

                # Special pre-installation steps for specific packages here
                if [[ "${pkg_name}" == "gImageReader-gtk" ]]; then
                    echo "-> Performing pre-install steps for gImageReader..."
                    ./xbps-src pkg gtkspellmm
                    sudo xbps-install -y --repository hostdir/binpkgs gtkspellmm
                fi

                echo "-> Building and installing ${pkg_name}..."
                ./xbps-src pkg "${pkg_name}"
                if [[ "${pkg_name}" == "discord" ]]; then
                   sudo xbps-install -y --repository hostdir/binpkgs/nonfree "${pkg_name}"
                else
                   sudo xbps-install -y --repository hostdir/binpkgs "${pkg_name}"
                fi
                
            }

            packages_to_install=()
            # If pressed Enter, select all packages
            if [[ -z "$user_choice" ]]; then
                echo "-> No specific choice made. Installing all packages."
                packages_to_install=("${packages[@]}")
            else
                # Sanitize input: replace commas with spaces
                sanitized_choice=$(echo "$user_choice" | tr ',' ' ')
                # Read the numbers into an array
                read -ra choices <<< "$sanitized_choice"

                for choice in "${choices[@]}"; do
                    # Validate that the choice is a number and within range
                    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#packages[@]}" ]; then
                        # Convert 1-based choice to 0-based array index
                        index=$((choice - 1))
                        packages_to_install+=("${packages[$index]}")
                    else
                        echo "Warning: Invalid selection '${choice}' ignored."
                    fi
                done
            fi

            # Now, loop through the final list of packages and install them
            if [ ${#packages_to_install[@]} -gt 0 ]; then
                # Using sort -u to remove any duplicate selections
                for pkg in $(printf "%s\n" "${packages_to_install[@]}" | sort -u); do
                    install_package "$pkg"
                done
            else
                echo "No valid packages selected for installation."
            fi

            echo "Leaving subshell."
        )

fi
echo "Almost done..."
