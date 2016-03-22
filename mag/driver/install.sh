:

sudo apt-get update 
#sudo apt-get -y upgrade 
sudo apt-get install i2c-tools
sudo apt-get install python-smbus
sudo apt-get install python3
sudo apt-get install git

# Get the libraries. Among the libraries we will be needing is "quick2wire" and "i2clibraries" for python from Think-Bowl. Make a folder for your project, lets say the folder's name is "project", type in the following commands. (everything after "#" symbol is just comments for you to read)
mkdir libs
cd libs

git clone https://github.com/quick2wire/quick2wire-python-api.git

#mv ./quick2wire-python-api ./code #renaming the quick2wire library folder to code for tidiness, you can skip this if you prefer keeping it original

export QUICK2WIRE_API_HOME=`pwd`/quick2wire-python-api
export PYTHONPATH=$PYTHONPATH:$QUICK2WIRE_API_HOME

cd $QUICK2WIRE_API_HOME

git clone https://bitbucket.org/thinkbowl/i2clibraries.git #getting library files containing functions for i2c devices such as HMC5883L, ITG-3205, ADXL345 and LCD
