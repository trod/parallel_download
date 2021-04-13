import Config

config :pd, PD.Spider, timeout: 5000
config :pd, PD.Spider, batch_size: 50

import_config "#{config_env()}.exs"
