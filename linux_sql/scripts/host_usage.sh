#!/bin/bash

# 1. Setup arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# 2. Validate arguments
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# 3. Parse server CPU and memory usage data
# On récupère les stats de vmstat sur une seule ligne pour l'analyser proprement
vmstat_mb=$(vmstat --unit M | tail -n1)

memory_free=$(echo "$vmstat_mb" | awk '{print $4}' | xargs)
cpu_idle=$(echo "$vmstat_mb" | awk '{print $15}' | xargs)
cpu_kernel=$(echo "$vmstat_mb" | awk '{print $14}' | xargs)

# Extraction des entrées/sorties du disque (Disk IO)
disk_io=$(vmstat -d | tail -n1 | awk '{print $10}' | xargs)

# Extraction de l'espace disponible sur la racine '/' en mégaoctets (sans la lettre M)
disk_available=$(df -BM / | tail -n1 | awk '{print $4}' | sed 's/M//' | xargs)

# Récupération du hostname pour la sous-requête
hostname=$(hostname -f)

# Timestamp actuel au format UTC 'YYYY-MM-DD HH:MM:SS'
timestamp=$(date -u "+%Y-%m-%d %H:%M:%S")

# 4. Construct the INSERT statement with a subquery
# La sous-requête (SELECT id FROM host_info...) remplace la valeur de host_id
insert_stmt="INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) VALUES ('$timestamp', (SELECT id FROM host_info WHERE hostname='$hostname'), $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

# 5. Execute the INSERT statement through psql CLI
export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"

exit $?
