# Home Assistant Add-on: Telegraf add-on

## How to setup the telegraf add-on

Create a `telegraf` directory under config, e.g. `config/telegraf` and put your telegraf input/output plugin configs here. 

On first start the telegraf directory will be created, if it does not exist. Then It will put what ever is configured into a `agent.conf` and a `influxdb.conf`. **If a `agent.conf` or `influxdb.conf` already exists the setting from the config page will be ignored.**

Configs witch will open another port for listening will do this with no additional configuration as the add-on runs in the host network.
