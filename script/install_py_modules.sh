#!/bin/sh


export MODULE_HOME=/modules

export PYTHON_INSTALL_HOME=/package/python

export PYTHON_HOME=/package/python

# install python
if [ ! -d "$PYTHON_INSTALL_HOME" ];then
    cd $PYTHON_INSTALL_HOME
    tar Jxvf Python-3.7.3.tar.xz
    cd Python-3.7.3
    chmod 755 -R *
    ./configure --prefix=$PYTHON_HOME
    make && make install
fi

 
export PYTHON=${PYTHON_HOME}/bin



cd $MODULE_HOME

#install setuptools-41.0.0
unzip setuptools-41.0.0.zip
cd setuptools-41.0.0
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..

#install mysql-connector-python-8.0.15
tar -zxvf mysql-connector-python-8.0.15.tar.gz
cd mysql-connector-python-8.0.15
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..


#install PyYAML-5.1
tar -zxvf PyYAML-5.1.tar.gz
cd PyYAML-5.1
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..

# install pyinotify-0.9.6
tar -zxvf pyinotify-0.9.6.tar.gz
cd pyinotify-0.9.6
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..

# install urllib3-1.24.1
tar -zxvf urllib3-1.24.1.tar.gz
cd urllib3-1.24.1
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..


#install idna-2.8
tar -zxvf idna-2.8.tar.gz
cd idna-2.8
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..

#install certifi-2019.3.9
tar -zxvf certifi-2019.3.9.tar.gz
cd certifi-2019.3.9
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..

#install chardet-3.0.4
tar -zxvf chardet-3.0.4.tar.gz
cd chardet-3.0.4
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..

#install avro-python3-1.8.2
tar -zxvf avro-python3-1.8.2.tar.gz
cd avro-python3-1.8.2
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..

# install requests-2.21.0
tar -zxvf requests-2.21.0.tar.gz
cd requests-2.21.0
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..

#install xmltodict-0.12.0.tar.gz
tar -zxvf xmltodict-0.12.0.tar.gz
cd xmltodict-0.12.0
$PYTHON/python3.7 setup.py build
$PYTHON/python3.7 setup.py install
cd ..

#install librdkafka-1.0.0-confluent5.2.1
tar -zxvf librdkafka-1.0.0-confluent5.2.1.tar.gz
cd librdkafka-1.0.0-confluent5.2.1
./configure --prefix=$MODULE_HOME/librdkafka
make 
make install 
cd ..


# install confluent-kafka-1.0.0

# sudo ldconfig # echo "/modules/librdkafka/lib" | sudo tee -a ld.so.conf


tar -zxvf confluent-kafka-1.0.0.tar.gz
cd confluent-kafka-1.0.0
C_INCLUDE_PATH=$MODULE_HOME/librdkafka/include LIBRARY_PATH=$MODULE_HOME/librdkafka/lib $PYTHON/python3.7 setup.python build
C_INCLUDE_PATH=$MODULE_HOME/librdkafka/include LIBRARY_PATH=$MODULE_HOME/librdkafka/lib $PYTHON/python3.7 setup.py install
cd ..
