#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: InfluxDB
# Configures telegraf.conf
# ==============================================================================


declare influx_un
declare influx_pw
declare influx_ret
declare hostname
#bashio::require.unprotected

mkdir -p /config/telegraf
touch /config/telegraf/influxdb.conf
touch /config/telegraf/influxdbv2.conf
touch /etc/telegraf/telegraf.conf
readonly GLOBAL_CONFIG="/etc/telegraf/telegraf.conf"
readonly INFLUXDB_CONFIG="/config/telegraf/influxdb.conf"
readonly INFLUXDBV2_CONFIG="/config/telegraf/influxdbv2.conf"

HOSTNAME=$(bashio::config 'hostname')
INTERVAL_AGENT=$(bashio::config 'influxDB.url')
ROUND_INTERVAL_AGENT=$(bashio::config 'influxDB.url')
SKIP_PROCESSOR_AFTER_AGGREGATORS_AGENT=$(bashio::config 'influxDB.url')
METRIC_BATCH_SIZE_AGENT=$(bashio::config 'influxDB.url')
METRIC_BUFFER_LIMIT_AGENT=$(bashio::config 'influxDB.url')
COLLECTION_JITTER_AGENT=$(bashio::config 'influxDB.url')
FLUSH_INTERVAL_AGENT=$(bashio::config 'influxDB.url')
FLUSH_JITTER_AGENT=$(bashio::config 'influxDB.url')
PRECISION_AGENT=$(bashio::config 'influxDB.url')
DEBUG_AGENT=$(bashio::config 'influxDB.url')

  

INFLUX_SERVER=$(bashio::config 'influxDB.url')
INFLUX_DB=$(bashio::config 'influxDB.db')
INFLUX_UN=$(bashio::config 'influxDB.username')
INFLUX_PW=$(bashio::config 'influxDB.password')

INFLUXDBV2_URL=$(bashio::config 'influxDBv2.url')
INFLUXDBV2_TOKEN=$(bashio::config 'influxDBv2.token')
INFLUXDBV2_ORG=$(bashio::config 'influxDBv2.organization')
INFLUXDBV2_BUCKET=$(bashio::config 'influxDBv2.bucket')
RETENTION=$(bashio::config 'influxDB.retention_policy')



bashio::log.info "Updating global config"

if bashio::var.has_value "${HOSTNAME}"; then
  hostname="hostname = 'HOSTNAME'"
else
  hostname="hostname = ''"
fi

if bashio::var.has_value "${FLUSH_INTERVAL_AGENT}"; then
  flush_interval="flush_interval = '${FLUSH_INTERVAL_AGENT}'"
else
  flush_interval="flush_interval = '10s'"
fi

if bashio::var.has_value "${INTERVAL_AGENT}"; then
  interval="interval = '${INTERVAL_AGENT}'"
else
  interval="interval = '10s'"
fi

if bashio::var.has_value "${ROUND_INTERVAL_AGENT}"; then
  round_interval="round_interval = ${ROUND_INTERVAL_AGENT}"
else
  round_interval="round_interval = true"
fi

if bashio::var.has_value "${SKIP_PROCESSOR_AFTER_AGGREGATORS_AGENT}"; then
  skip_processors_after_aggregators="skip_processors_after_aggregators = ${SKIP_PROCESSOR_AFTER_AGGREGATORS_AGENT}"
else
  skip_processors_after_aggregators="skip_processors_after_aggregators = true"
fi

if bashio::var.has_value "${METRIC_BATCH_SIZE_AGENT}"; then
  metric_batch_size="metric_batch_size = ${METRIC_BATCH_SIZE_AGENT}"
else
  metric_batch_size="metric_batch_size = 1000"
fi

if bashio::var.has_value "${METRIC_BUFFER_LIMIT_AGENT}"; then
  metric_buffer_limit="metric_buffer_limit = ${METRIC_BUFFER_LIMIT_AGENT}"
else
  metric_buffer_limit="metric_buffer_limit = 10000"
fi

if bashio::var.has_value "${FLUSH_JITTER_AGENT}"; then
  flush_jitter="flush_jitter = '${FLUSH_JITTER_AGENT}'"
else
  flush_jitter="flush_jitter = '0s'"
fi

if bashio::var.has_value "${COLLECTION_JITTER_AGENT}"; then
  collection_jitter="collection_jitter = '${COLLECTION_JITTER_AGENT}'"
else
  collection_jitter="collection_jitter = '0s'"
fi

if bashio::var.has_value "${PRECISION_AGENT}"; then
  precision="precision = '${PRECISION_AGENT}'"
else
  precision="precision = ''"
fi

if bashio::var.has_value "${DEBUG_AGENT}"; then
  debug="debug = ${DEBUG_AGENT}"
else
  debug="debug = false"
fi

{
  echo -e "[global_tags]"
  echo -e "\t${flush_interval}"
  echo -e "\n"
  echo -e "[agent]"
  echo -e "\t${interval}"
  echo -e "\t${round_interval}"
  echo -e "\t${skip_processors_after_aggregators}"
  echo -e "\t${metric_batch_size}"
  echo -e "\t${metric_buffer_limit}"
  echo -e "\t${collection_jitter}"
  echo -e "\t${flush_interval}"
  echo -e "\t${flush_jitter}"
  echo -e "\t${precision}"
  echo -e "\t${debug}"
  echo -e "\t${hostname}"
  echo -e "\tomit_hostname = false"
} >> $GLOBAL_CONFIG

sed -i "s,HOSTNAME,${HOSTNAME},g" $GLOBAL_CONFIG

if bashio::config.true 'influxDB.enabled'; then
  if bashio::var.has_value "${INFLUX_UN}"; then
    influx_un="username='INFLUX_UN'"
  else
    influx_un="# INFLUX_UN"
  fi

  if bashio::var.has_value "${INFLUX_PW}"; then
    influx_pw="password='INFLUX_PW'"
  else
    influx_pw="# INFLUX_PW"
  fi

  if bashio::var.has_value "${RETENTION}"; then
    influx_ret="retention_policy='RETENTION'"
  else
    influx_ret="# RETENTION"
  fi

  {
    echo -e "[[outputs.influxdb]]"
    echo -e "\turls = ['http://a0d7b954-influxdb:8086']"
    echo -e "\tdatabase = \"TELEGRAF_DB\""
    echo -e "\t${influx_ret}"
    echo -e "\ttimeout = '5s'"
    echo -e "\t${influx_un}"
    echo -e "\t${influx_pw}"
  } >> $INFLUXDB_CONFIG

  sed -i "s,http://a0d7b954-influxdb:8086,${INFLUX_SERVER},g" $INFLUXDB_CONFIG

  sed -i "s,TELEGRAF_DB,${INFLUX_DB},g" $INFLUXDB_CONFIG

  sed -i "s,INFLUX_UN,${INFLUX_UN},g" $INFLUXDB_CONFIG

  sed -i "s,INFLUX_PW,${INFLUX_PW},g" $INFLUXDB_CONFIG

  sed -i "s,RETENTION,${RETENTION},g" $INFLUXDB_CONFIG

fi

if bashio::config.true 'influxDBv2.enabled'; then
  bashio::log.info "Updating config for influxdbv2"
  {
    echo -e "[[outputs.influxdb_v2]]"
    echo -e "\turls = [\"INFLUXv2_URL\"]"
    echo -e "\ttoken = 'INFLUX_TOKEN'"
    echo -e "\torganization = 'INFLUX_ORG'"
    echo -e "\tbucket = 'INFLUX_BUCKET'"
  } >> $INFLUXDBV2_CONFIG

  sed -i "s,INFLUXv2_URL,${INFLUXDBV2_URL},g" $INFLUXDBV2_CONFIG
  sed -i "s,INFLUX_TOKEN,${INFLUXDBV2_TOKEN},g" $INFLUXDBV2_CONFIG
  sed -i "s,INFLUX_ORG,${INFLUXDBV2_ORG},g" $INFLUXDBV2_CONFIG
  sed -i "s,INFLUX_BUCKET,${INFLUXDBV2_BUCKET},g" $INFLUXDBV2_CONFIG
fi

bashio::log.info "Finished updating config"
