# Get dependencies
yum -y update
yum -y groupinstall "Development Tools"
yum -y install openssl openssl-devel wget

# Get and unpack clamav source
wget https://www.clamav.net/downloads/production/clamav-0.101.1.tar.gz
tar -xvf clamav-0.101.1.tar.gz
cd clamav-0.101.1

# Configure and build
./configure --enable-static=yes --enable-shared=no --disable-unrar --prefix=/var/task
make
make install
cd ..

# Package everything up into a zip
mkdir bin
cp /var/task/bin/clamscan ./bin
chmod 777 ./bin/clamscan
cp /var/task/bin/freshclam ./bin
chmod 777 ./bin/freshclam

mkdir lib64
cp -r /var/task/lib64/* ./lib64