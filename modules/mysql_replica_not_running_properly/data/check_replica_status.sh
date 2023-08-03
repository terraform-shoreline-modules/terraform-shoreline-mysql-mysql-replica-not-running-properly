if mysql -e "SHOW SLAVE STATUS\G" | grep -q "Slave_IO_Running: Yes" && mysql -e "SHOW SLAVE STATUS\G" | grep -q "Slave_SQL_Running: Yes"; then

    echo "Replica_IO_Running and replica_SQL_Running are running."

else

    echo "Replica_IO_Running and/or replica_SQL_Running is not running on the replica."

fi