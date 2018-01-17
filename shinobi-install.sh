#! /bin/sh
echo "$EUID"
if [ "$OSTYPE" = "darwin"* ] && [ ! -x "$(command -v git)" ]; then
    if [ ! -x "$(command -v brew)" ]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew doctor
    fi
    brew install git
else
    if [ "$(id -u)" != 0 ]; then
        echo "*--------------------**---------------------*"
        echo "*Shinobi requires being run as root."
        echo "*Do you want to continue without being root?"
        echo "(Y)es or (n)o"
        echo "*--------------------**---------------------*"
        read nonRootUser
        if [  "$nonRootUser" = "N" ] || [  "$nonRootUser" = "n" ]; then
            echo "Stopping..."
            exit 1
        fi
    fi
    if [ ! -x "$(command -v git)" ]; then
        if [ -x "$(command -v apt)" ]; then
            sudo apt update
            sudo apt install git -y
        fi
        if [ -x "$(command -v yum)" ]; then
            sudo yum update
            sudo yum install git -y
        fi
    fi
fi
cd /home
echo "*--------------------**---------------------*"
echo "---------------------------------------------"
echo "Install Shinobi CE or Shinobi Pro?"
echo "---------------------------------------------"
echo "*Note : Shinobi Pro is free for personal use."
echo "*Learn more at http://shinobi.video/pro"
echo "---------------------------------------------"
echo "(C)E or (P)ro? Default : Pro"
read theRepoChoice
if [ "$theRepoChoice" = "C" ] || [ "$theRepoChoice" = "c" ] || [ "$theRepoChoice" = "CE" ] || [ "$theRepoChoice" = "ce" ]; then
    productName="Shinobi Community Editon (CE)"
    echo "-------------------------------------"
    theRepo='moeiscool'
    theBranch='master'
else
    theRepo='ShinobiCCTV'
    productName="Shinobi Professional (Pro)"
    echo "-------------------------------------"
    echo "Install the Development branch?"
    echo "(y)es or (N)o"
    read theBranchChoice
    if [ "$theBranchChoice" = "Y" ] || [ "$theBranchChoice" = "y" ]; then
        echo "Getting the Development Branch"
        theBranch='dev'
    else
        echo "Getting the Master Branch"
        theBranch='master'
    fi
fi
# Download from Git repository
gitURL="https://github.com/$theRepo/Shinobi"
sudo git clone $gitURL.git -b $theBranch
# Enter Shinobi folder "/home/Shinobi"
cd Shinobi
# write version number
function getGitVersionNumber() {
  git rev-parse --short HEAD 2> /dev/null | sed "s/\(.*\)/@\1/"
}
gitVersionNumber=$(getGitVersionNumber)
theDateRightNow=$(date)
cat <<EOF > version.json
{"Product" : "$productName" , "Branch" : "$theBranch" , "Version" : "$gitVersionNumber" , "Date" : "$theDateRightNow" , "Repository" : "$gitURL"}
EOF
echo "-------------------------------------"
echo "---------- Shinobi Systems ----------"
echo "Repository : $gitURL"
echo "Product : $productName"
echo "Branch : $theBranch"
echo "Version : $gitVersionNumber"
echo "Date : $theDateRightNow"
echo "-------------------------------------"
echo "-------------------------------------"
sudo chmod +x INSTALL/start.sh
sudo INSTALL/start.sh