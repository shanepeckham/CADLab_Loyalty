sudo apt-get -y update
echo "Install npm"
sudo apt-get -y install npm
echo "Installing node"
sudo apt-get -y install nodejs-legacy
sudo apt-get -y install -y nodejs
echo "Installing mysql-server"
sudo apt-get install -y debconf-utils
export DEBIAN_FRONTEND="noninteractive"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password MiniCAD123"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password MiniCAD123"
sudo apt-get install -y mysql-server
echo "Installing mysql client"
sudo apt-get -y install mysql-client
echo "Installing node mysql"  
npm install mysql
echo installing git
sudo apt-get -y install git
echo "MySQL load"
mysql -u root -pMiniCAD123 -e "use mysql; CREATE TABLE IF NOT EXISTS cases (
  caseId INT(11) NOT NULL AUTO_INCREMENT,
  contactId INT(11) DEFAULT NULL,
  last_feedback VARCHAR(200) DEFAULT NULL,
  PRIMARY KEY (caseId)
) ENGINE=InnoDB; INSERT INTO cases (caseId, contactId, last_feedback) VALUES('4', '1', 'I found the customer service to be appalling. I will not be back!'); INSERT INTO cases (caseId, contactId, last_feedback) VALUES('5', '2', 'I loved it, quick service and the quality was great'); INSERT INTO cases (caseId, contactId, last_feedback) VALUES('6', '3', 'I thought it was ok');"
echo "Data loaded successfully"
echo "Getting Code"
mkdir LegacyAPI
cd LegacyAPI
git clone https://github.com/shanepeckham/CADContacts.git
cd CADContacts
git checkout mysql
npm install forever -g
forever start server.js
npm install
echo "Starting LegacyAPI"
node server.js
