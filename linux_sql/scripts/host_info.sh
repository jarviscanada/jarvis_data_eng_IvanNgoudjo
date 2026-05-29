#!/bin/bash

# Setup and validate arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check # of args
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# Save machine statistics to variables
lscpu_out=$(lscpu)
hostname=$(hostname -f)

# Retrieve hardware specification variables
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | awk '{$1=$2=""; print $0}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}' | xargs | sed 's/K//')
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}' | xargs)

# Fix cpu_mhz — essai 1 : CPU MHz direct
cpu_mhz=$(echo "$lscpu_out" | egrep "^CPU MHz:" | awk '{print $3}' | xargs)

# Essai 2 - CPU max MHz
if [ -z "$cpu_mhz" ]; then
    cpu_mhz=$(echo "$lscpu_out" | egrep "^CPU max MHz:" | awk '{print $4}' | xargs)
fi

# Essai 3 - Extraire depuis le model name (ex: @ 2.20GHz)
if [ -z "$cpu_mhz" ]; then
    cpu_mhz=$(echo "$lscpu_out" | egrep "^Model name:" | awk '{print $NF}' | sed 's/GHz//' | awk '{printf "%.0f\n", $1 * 1000}')
fi

# Essai 4 - Valeur par défaut
if [ -z "$cpu_mhz" ]; then
    cpu_mhz=0.0
fi

# Current time in UTC format
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

# PSQL command: Insert server hardware info into host_info table
insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem)
VALUES('$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$timestamp', '$total_mem')"

# Set up env var for psql cmd
export PGPASSWORD=$psql_password

# Insert data into database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?
