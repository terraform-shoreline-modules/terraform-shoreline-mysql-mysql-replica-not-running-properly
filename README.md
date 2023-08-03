
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# MySQL Replica Not Running Properly
---

This incident type refers to a problem with the MySQL database replica, where it is not functioning correctly and may be preventing full data replication. This issue needs to be investigated and resolved promptly to ensure data integrity and prevent any potential data loss.

### Parameters
```shell
# Environment Variables

export MASTER_DB_PASSWORD="PLACEHOLDER"

export MASTER_DB_HOST="PLACEHOLDER"

export REPLICA_DB_HOST="PLACEHOLDER"

export MASTER_DB_USERNAME="PLACEHOLDER"

export MIN_FREE_SPACE="PLACEHOLDER"

export MAX_LOAD_AVERAGE="PLACEHOLDER"
```

## Debug

### Check if MySQL is running
```shell
systemctl status mysql
```

### Check if the MySQL replica is running
```shell
mysql -u${MASTER_DB_USERNAME} -p${MASTER_DB_PASSWORD} -e "SHOW SLAVE STATUS\G"
```

### Check the MySQL error log for any relevant errors
```shell
tail -n 100 /var/log/mysql/error.log
```

### Check for any network connectivity issues
```shell
ping ${REPLICA_IP_ADDRESS}
```

### Check the MySQL configuration file for any relevant settings
```shell
cat /etc/mysql/my.cnf
```

### Check the disk usage and available space on the replica server
```shell
df -h
```

### Check the system logs for any relevant errors
```shell
tail -n 100 /var/log/syslog
```

### Network issues preventing replication between primary and replica servers.
```shell


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


```

## Repair

### Check if replica_IO_running and replica_SQL_running are running
```shell
if mysql -e "SHOW SLAVE STATUS\G" | grep -q "Slave_IO_Running: Yes" && mysql -e "SHOW SLAVE STATUS\G" | grep -q "Slave_SQL_Running: Yes"; then

    echo "Replica_IO_Running and replica_SQL_Running are running."

else

    echo "Replica_IO_Running and/or replica_SQL_Running is not running on the replica."

fi
```

### Determine whether there are any database schema changes that have been made on the master MySQL server that have not been replicated on the replica server.
```shell
bash

#!/bin/bash



# Set the necessary variables


MASTER_DB_HOST=${MASTER_DB_HOST}

REPLICA_DB_HOST=${REPLICA_DB_HOST}

MASTER_DB_USER=${MASTER_DB_USERNAME}

MASTER_DB_PASSWORD=${MASTER_DB_PASSWORD}



# Check for any unreplicated schema changes

MASTER_SCHEMA=`mysql -h $MASTER_DB_HOST -u $MASTER_DB_USER -p$MASTER_DB_PASSWORD -e "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'mysql', 'performance_schema')"`

REPLICA_SCHEMA=`mysql -h $REPLICA_DB_HOST -u $MASTER_DB_USER -p$MASTER_DB_PASSWORD -e "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'mysql', 'performance_schema')"`

UNREPLICATED_SCHEMA=(`echo ${MASTER_SCHEMA[@]} ${REPLICA_SCHEMA[@]} | tr ' ' '\n' | sort | uniq -u`)



# If there are unreplicated schema changes, replicate them on the replica server

if [ ${#UNREPLICATED_SCHEMA[@]} -gt 0 ]; then

  for schema in "${UNREPLICATED_SCHEMA[@]}"

  do

    mysqldump -h $MASTER_DB_HOST -u $MASTER_DB_USER -p$MASTER_DB_PASSWORD --single-transaction --routines --triggers --add-drop-database $schema | mysql -h $REPLICA_DB_HOST -u $MASTER_DB_USER -p$MASTER_DB_PASSWORD $schema

  done

  echo "Unreplicated schema changes have been replicated on the replica server."

else

  echo "There are no unreplicated schema changes on the master MySQL server."

fi


```

### Ensure that the replica is not overloaded and has sufficient resources to perform the replication task.
```shell
bash

#!/bin/bash

# Set the maximum load average that the replica server can handle

MAX_LOAD=${MAX_LOAD_AVERAGE}



# Set the minimum free disk space required on the replica server

MIN_FREE_SPACE=${MIN_FREE_SPACE}



# Check the current system load average

LOAD=$(uptime | awk '{print $10}' | cut -d. -f1)



# Check the free disk space on the replica server

FREE_SPACE=$(df -h | grep /dev/ | awk '{ print $4 }' | sort -n | head -n 1 | cut -d'G' -f1)



# Check if the replica server is overloaded

if [ $LOAD -gt $MAX_LOAD ]; then

    echo "Replica server is overloaded with load average of $LOAD. Please reduce the load on the server."

    exit 1

fi



# Check if there is enough free disk space on the replica server

if [ $FREE_SPACE -lt $MIN_FREE_SPACE ]; then

    echo "Replica server does not have sufficient free disk space. Please free up some space."

    exit 1

fi



echo "Replica server is not overloaded and has sufficient resources to perform the replication task."


```