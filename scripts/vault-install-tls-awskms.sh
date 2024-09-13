#!/bin/bash

##############################################################################################################################################
# Variables
##############################################################################################################################################

######### Local Addr (Private IP) ##############
LOCAL_IPV4=$(hostname -I | awk '{print $1}')

######### Version of Vault to deploy ##############
VAULT_VERSION="1.17.3+ent"

######### Node ID in Raft HCL Config File ##############
NODE_ID="vault1"

######### License File ##############
LIC="/etc/vault.d/vault.hclic"

######### Environment File ##############
ENV="/etc/vault.d/.vault.env"

######### Vault File and Path ##############
VAULT_HCL="/etc/vault.d/vault.hcl"
PATH_HCL="/etc/vault.d"

######### TLS Certs (CA and Client) and Client Key #############
CA_CERT="/etc/vault.d/vaultca.crt"
CLIENT_CERT="/etc/vault.d/vaultclient.crt"
CLIENT_KEY="/etc/vault.d/vaultclient.key"

######### Systemd File #############
SYSTEMD_FILE="/etc/systemd/system/vault.service"

######### Raft Base Dir #############
PATH_RAFT="/etc/vault.d/data"

######### File and Base Dir #############
BIN_VAULT="/usr/local/bin/vault"
BIN_PATH="/usr/local/bin/"

######### TLS SAN of Client Certificates #############
TLS_SERVER1="vault1"
TLS_SERVER2="vault2"
TLS_SERVER3="vault3"

######### Vault Internal IPs #############
IP_VAULT1="10.0.1.10"
IP_VAULT2="10.0.2.10"
IP_VAULT3="10.0.3.10"


######### Source Certs to move to new path #############
SOURCE_CACERT="/home/ec2-user/vaultca.crt"
SOURCE_CLIENTCERT="/home/ec2-user/vaultclient.crt"
SOURCE_KEY="/home/ec2-user/vaultclient.key"

##############################################################################################################################################
# OPTIONAL: Manually add records to /etc/hosts for DNS resolution / Just comment if don`t use
##############################################################################################################################################

cat << EOF >> /etc/hosts
$IP_VAULT1 $TLS_SERVER1
$IP_VAULT2 $TLS_SERVER2
$IP_VAULT3 $TLS_SERVER3

EOF


##############################################################################################################################################
# Copy Certs and move to new dir
##############################################################################################################################################
mkdir --parents $PATH_RAFT
cp $SOURCE_CACERT $PATH_HCL
cp $SOURCE_CLIENTCERT $PATH_HCL
cp $SOURCE_KEY $PATH_HCL


##############################################################################################################################################
# Download Precompiled Vault binaries 
##############################################################################################################################################
curl --silent --remote-name https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip


##############################################################################################################################################
# Unzip the downloaded package and move the vault binary to /usr/local/bin/. 
##############################################################################################################################################
unzip vault_${VAULT_VERSION}_linux_amd64.zip
chown root:root vault
mv vault $BIN_PATH


##############################################################################################################################################
# The vault command features opt-in autocompletion for flags, subcommands, and arguments (where supported).
##############################################################################################################################################
vault -autocomplete-install


##############################################################################################################################################
# Give Vault the ability to use the mlock syscall without running the process as root. The mlock syscall prevents memory from being swapped to disk.
##############################################################################################################################################
setcap cap_ipc_lock=+ep $BIN_VAULT


##############################################################################################################################################
# Create a unique, non-privileged system user to run Vault.
##############################################################################################################################################
useradd --system --home $PATH_HCL --shell /bin/false vault


##############################################################################################################################################
# Configure systemd - Create a Vault service file at /etc/systemd/system/vault.service.
##############################################################################################################################################
cat << EOF > $SYSTEMD_FILE
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=$VAULT_HCL

[Service]
User=vault
Group=vault
EnvironmentFile=$ENV
ExecStart=$BIN_VAULT server -config=$VAULT_HCL
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
##############################################################################################################################################
# Configure Vault - Service Config .HCL and License .HCLIC
##############################################################################################################################################

cat << EOF > $VAULT_HCL
ui = true
disable_mlock = true
cluster_addr  = "https://$LOCAL_IPV4:8201"
api_addr      = "https://$LOCAL_IPV4:8200"

listener "tcp" {
  tls_disable = false
  address            = "0.0.0.0:8200"
  tls_cert_file      = "$CLIENT_CERT"
  tls_key_file       = "$CLIENT_KEY"
  tls_client_ca_file = "$CA_CERT"
}

seal "awskms" {
  region     = "us-east-1"
  kms_key_id = "INPUT KMS ID HERE"
}

storage "raft" {
  path = "$PATH_RAFT"
  node_id = "$NODE_ID"

  retry_join {
    leader_tls_servername   = "$TLS_SERVER1"
    leader_api_addr         = "https://$IP_VAULT1:8200"
    leader_ca_cert_file     = "$CA_CERT"
    leader_client_cert_file = "$CLIENT_CERT"
    leader_client_key_file  = "$CLIENT_KEY"
  }
  retry_join {
    leader_tls_servername   = "$TLS_SERVER2"
    leader_api_addr         = "https://$IP_VAULT2:8200"
    leader_ca_cert_file     = "$CA_CERT"
    leader_client_cert_file = "$CLIENT_CERT"
    leader_client_key_file  = "$CLIENT_KEY"
  }
  retry_join {
    leader_tls_servername   = "$TLS_SERVER3"
    leader_api_addr         = "https://$IP_VAULT3:8200"
    leader_ca_cert_file     = "$CA_CERT"
    leader_client_cert_file = "$CLIENT_CERT"
    leader_client_key_file  = "$CLIENT_KEY"
  }
}

license_path = "$LIC"

EOF

cat << 'EOF' > $LIC
INPUT TEXT HERE
EOF

cat << EOF > $ENV
AWS_ACCESS_KEY_ID="INPUT HERE"
AWS_SECRET_ACCESS_KEY="INPUT HERE"

EOF


chmod 640 $VAULT_HCL
chmod 640 $LIC
chown --recursive vault:vault $PATH_HCL


##############################################################################################################################################
# Start Vault - Enable and Start
##############################################################################################################################################
systemctl enable vault
systemctl start vault
systemctl status vault

##############################################################################################################################################
# Starting Vault Cluster - Execute next steps only on first node
##############################################################################################################################################
#export VAULT_CLIENT_TIMEOUT=500s
#export VAULT_ADDR='https://vault1:8200'
#export VAULT_SKIP_VERIFY="true"
#vault operator init -format=json

