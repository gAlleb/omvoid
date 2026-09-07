# Optional: build omvoid's own packages from srcpkgs/.
#
# Almost nobody installing omvoid needs this. The packages it would build are
# published already, and the machines that install them get them from the
# repository like any other. Building them takes a void-packages checkout, a
# build root and a long time -- that is work for the machine that publishes,
# not for every machine that installs.
#
# The step is left here, and left out of install.sh, so that machine has a
# starting point. The tool itself is omvoid-pkg-build.

echo "Building omvoid's own packages is optional and slow."
echo "If this machine is the one that publishes them:"
echo
echo "    omvoid-pkg-build      # build everything in srcpkgs/"
echo "    omvoid-pkg-publish    # sign and put into the repository"
echo
echo "Skipping."
