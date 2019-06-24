# Install the base software
# Note: PWD will change to ~/steem-docker after running
function deploy_base() {
    install_ntp
    install_docker
    install_steembox
}