

#!/bin/bash



# Set the IP addresses of the primary and replica servers

PRIMARY_IP="PLACEHOLDER"

REPLICA_IP="PLACEHOLDER"x



# Check if the primary server is reachable from the replica server

ping -c 4 $PRIMARY_IP > /dev/null 2>&1

if [ $? -ne 0 ]; then

    echo "ERROR: Could not reach primary server from replica server"

    exit 1

fi



# Check if the replica server is reachable from the primary server

ssh $REPLICA_IP exit > /dev/null 2>&1

if [ $? -ne 0 ]; then

    echo "ERROR: Could not reach replica server from primary server"

    exit 1

fi



# Check if the MySQL replication process is running on the primary server

ssh $PRIMARY_IP "pgrep mysqld > /dev/null 2>&1"

if [ $? -ne 0 ]; then

    echo "ERROR: MySQL replication process is not running on primary server"

    exit 1

fi



# Check if the MySQL replication process is running on the replica server

ssh $REPLICA_IP "pgrep mysqld > /dev/null 2>&1"

if [ $? -ne 0 ]; then

    echo "ERROR: MySQL replication process is not running on replica server"

    exit 1

fi



# Check if the replica server is replicating data from the primary server

ssh $REPLICA_IP "mysql -u ${USERNAME} -p${PASSWORD} -e 'SHOW SLAVE STATUS\G' | grep -E 'Slave_IO_Running|Slave_SQL_Running'"

if [ $? -ne 0 ]; then

    echo "ERROR: Replica server is not replicating data from primary server"

    exit 1

fi



echo "SUCCESS: Replication is working properly"

exit 0