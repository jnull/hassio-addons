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
rm -rf /etc/telegraf/telegraf.conf
touch /etc/telegraf/telegraf.conf
touch /config/telegraf/agent.conf
touch /config/telegraf/influxdb.conf
touch /config/telegraf/influxdbv2.conf
readonly GLOBAL_CONFIG="/etc/telegraf/telegraf.conf"
readonly AGENT_CONFIG="/config/telegraf/agent.conf"
readonly GLOBAL_INFLUXDB_CONFIG="/config/telegraf/influxdb.conf"
readonly GLOBAL_INFLUXDBV2_CONFIG="/config/telegraf/influxdbv2.conf"


HOSTNAME=$(bashio::config 'hostname')
INTERVAL_AGENT=$(bashio::config 'interval')
ROUND_INTERVAL_AGENT=$(bashio::config 'round_interval')
SKIP_PROCESSOR_AFTER_AGGREGATORS_AGENT=$(bashio::config 'skip_processor_after_aggregation')
METRIC_BATCH_SIZE_AGENT=$(bashio::config 'metric_batch_size')
METRIC_BUFFER_LIMIT_AGENT=$(bashio::config 'metric_buffer_limit')
COLLECTION_JITTER_AGENT=$(bashio::config 'collection_jitter')
FLUSH_INTERVAL_AGENT=$(bashio::config 'flush_interval')
FLUSH_JITTER_AGENT=$(bashio::config 'flush_jitter')
PRECISION_AGENT=$(bashio::config 'precision')
DEBUG_AGENT=$(bashio::config 'debug')

  

INFLUX_SERVER=$(bashio::config 'influxDB.url')
INFLUX_DB=$(bashio::config 'influxDB.db')
INFLUX_UN=$(bashio::config 'influxDB.username')
INFLUX_PW=$(bashio::config 'influxDB.password')

INFLUXDBV2_URL=$(bashio::config 'influxDBv2.url')
INFLUXDBV2_TOKEN=$(bashio::config 'influxDBv2.token')
INFLUXDBV2_ORG=$(bashio::config 'influxDBv2.organization')
INFLUXDBV2_BUCKET=$(bashio::config 'influxDBv2.bucket')
RETENTION=$(bashio::config 'influxDB.retention_policy')


bashio::log.info "Updating global config from Settings"


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

if bashio::var.false "${ROUND_INTERVAL_AGENT}"; then
  round_interval="round_interval = ${ROUND_INTERVAL_AGENT}"
else
  round_interval="round_interval = true"
fi

if bashio::var.false "${SKIP_PROCESSOR_AFTER_AGGREGATORS_AGENT}"; then
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

if bashio::var.true "${DEBUG_AGENT}"; then
  debug="debug = ${DEBUG_AGENT}"
else
  debug="debug = false"
fi

{
  echo -e "[global_tags]"
  echo -e "\t${flush_interval}"
  echo -e "\n"
  echo -e "[[inputs.internal]]"
} >> $GLOBAL_CONFIG

if [[ -f "/config/telegraf/agent.conf" ]]; then
    bashio::log.info "agent.conf found in /config/telegraf/, skipping setting values from configuration page"
else
  {
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
  } >> $AGENT_CONFIG

  sed -i "s,HOSTNAME,${HOSTNAME},g" $AGENT_CONFIG
fi

if bashio::config.true 'influxDB.enabled'; then
  if [[ -f "/config/telegraf/influxdb.conf" ]]; then
    bashio::log.info "influxdb.conf found in /config/telegraf/, skipping setting values from configuration page"
  else
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
    } >> $GLOBAL_INFLUXDB_CONFIG

    sed -i "s,http://a0d7b954-influxdb:8086,${INFLUX_SERVER},g" $GLOBAL_INFLUXDB_CONFIG

    sed -i "s,TELEGRAF_DB,${INFLUX_DB},g" $GLOBAL_INFLUXDB_CONFIG

    sed -i "s,INFLUX_UN,${INFLUX_UN},g" $GLOBAL_INFLUXDB_CONFIG

    sed -i "s,INFLUX_PW,${INFLUX_PW},g" $GLOBAL_INFLUXDB_CONFIG

    sed -i "s,RETENTION,${RETENTION},g" $GLOBAL_INFLUXDB_CONFIG

  fi
fi

if bashio::config.true 'influxDBv2.enabled'; then
  bashio::log.info "Updating config for influxdbv2"
  if [[ -f "/config/telegraf/influxdbv2.conf" ]]; then
    bashio::log.info "influxdbv2.conf found in /config/telegraf/, skipping setting values from configuration page"
  else
    {
      echo -e "[[outputs.influxdb_v2]]"
      echo -e "\turls = [\"INFLUXv2_URL\"]"
      echo -e "\ttoken = 'INFLUX_TOKEN'"
      echo -e "\torganization = 'INFLUX_ORG'"
      echo -e "\tbucket = 'INFLUX_BUCKET'"
    } >> $GLOBAL_INFLUXDBV2_CONFIG

    sed -i "s,INFLUXv2_URL,${INFLUXDBV2_URL},g" $GLOBAL_INFLUXDBV2_CONFIG
    sed -i "s,INFLUX_TOKEN,${INFLUXDBV2_TOKEN},g" $GLOBAL_INFLUXDBV2_CONFIG
    sed -i "s,INFLUX_ORG,${INFLUXDBV2_ORG},g" $GLOBAL_INFLUXDBV2_CONFIG
    sed -i "s,INFLUX_BUCKET,${INFLUXDBV2_BUCKET},g" $GLOBAL_INFLUXDBV2_CONFIG
  fi
fi

bashio::log.info "Finished updating config"
