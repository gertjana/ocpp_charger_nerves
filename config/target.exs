use Mix.Config

# Authorize the device to receive firmware using your public key.
# See https://hexdocs.pm/nerves_firmware_ssh/readme.html for more information
# on configuring nerves_firmware_ssh.

keys = [Path.join([System.user_home!(), ".ssh", "id_rsa.pub"])
  ]

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config/target.exs for this error message.
    """)

config :nerves_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)


# Setting the node_name will enable Erlang Distribution.
# Only enable this for prod if you understand the risks.
node_name = if Mix.env() != :prod, do: "ocpp_charger_nerves"

config :mdns_lite,
  host: [:hostname, "ocpp_charger_nerves"],
  ttl: 120,

  services: [
    %{
      name: "SSH Remote Login Protocol",
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      name: "Secure File Transfer Protocol over SSH",
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      name: "Erlang Port Mapper Daemon",
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]

config :vintage_net,
  regulatory_domain: "EU",
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"wlan0", %{
      type: VintageNetWiFi,
      vintage_net_wifi: %{
        networks: [
          %{
            key_mgmt: :wpa_psk,
            ssid: System.get_env("NET_SSID"),
            psk: System.get_env("NET_PSK"),
          }
        ]
      },
      ipv4: %{method: :dhcp},
    }}
  ]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

import_config "#{Mix.target()}.exs"
