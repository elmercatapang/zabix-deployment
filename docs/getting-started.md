# Zabbix Post-Deployment Guide

This guide covers everything needed after the Zabbix server is up: securing the server, installing agents on hosts, adding hosts to monitoring, applying templates, and setting up alerting.

---

## Table of Contents

1. [First Login & Security](#1-first-login--security)
2. [Install Zabbix Agent 2 on Windows Hosts](#2-install-zabbix-agent-2-on-windows-hosts)
3. [Install Zabbix Agent 2 on Linux Hosts](#3-install-zabbix-agent-2-on-linux-hosts)
4. [Add a Host in Zabbix](#4-add-a-host-in-zabbix)
5. [Apply Monitoring Templates](#5-apply-monitoring-templates)
6. [Verify the Host is Being Monitored](#6-verify-the-host-is-being-monitored)
7. [Configure Email Alerting](#7-configure-email-alerting)
8. [Recommended Global Settings](#8-recommended-global-settings)
9. [Host Reference — BEL Infrastructure](#9-host-reference--bel-infrastructure)

---

## 1. First Login & Security

### Change the Default Admin Password
1. Log in at `http://<zabbix-ip>/` with **Admin / zabbix**
2. Click the user icon (top right) → **Profile**
3. Click **Change password**
4. Set a strong password and save

### Rename the Default Admin User (Optional but Recommended)
1. Go to **Users → Users**
2. Click **Admin**
3. Change the **Alias** to something non-obvious (e.g., `zbxadmin`)
4. Save

---

## 2. Install Zabbix Agent 2 on Windows Hosts

Zabbix Agent 2 must be installed on every Windows server you want to monitor.

### Download

Download the latest **Zabbix Agent 2** MSI for Windows from:
```
https://www.zabbix.com/download_agents
```
Select: **Version 7.0 LTS → Windows → 64-bit → MSI**

### Install via PowerShell (run as Administrator)

```powershell
# Replace values in angle brackets
$ZabbixServer = "<ZABBIX_SERVER_IP>"   # e.g. 54.83.1.183
$HostName     = "<THIS_SERVER_NAME>"   # e.g. srv-webapps-01

msiexec /i "zabbix_agent2-7.0.0-windows-amd64.msi" /qn `
  SERVER=$ZabbixServer `
  SERVERACTIVE=$ZabbixServer `
  HOSTNAME=$HostName
```

### Verify the Service is Running

```powershell
Get-Service "Zabbix Agent 2"
```

Expected output: `Status: Running`

### Firewall Rule (if Windows Firewall is enabled)

```powershell
New-NetFirewallRule -DisplayName "Zabbix Agent" `
  -Direction Inbound -Protocol TCP -LocalPort 10050 `
  -Action Allow
```

### Config File Location

```
C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf
```

Key settings to verify:
```ini
Server=<ZABBIX_SERVER_IP>
ServerActive=<ZABBIX_SERVER_IP>
Hostname=<THIS_SERVER_NAME>
```

After any config change, restart the service:
```powershell
Restart-Service "Zabbix Agent 2"
```

---

## 3. Install Zabbix Agent 2 on Linux Hosts

```bash
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu22.04_all.deb
dpkg -i zabbix-release_latest+ubuntu22.04_all.deb
apt-get update
apt-get install -y zabbix-agent2

# Set server IP and hostname
ZABBIX_SERVER="<ZABBIX_SERVER_IP>"
HOST_NAME="<THIS_SERVER_NAME>"

sed -i "s/^Server=.*/Server=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agent2.conf
sed -i "s/^ServerActive=.*/ServerActive=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agent2.conf
sed -i "s/^Hostname=.*/Hostname=$HOST_NAME/" /etc/zabbix/zabbix_agent2.conf

systemctl enable zabbix-agent2
systemctl start zabbix-agent2
```

---

## 4. Add a Host in Zabbix

### Steps

1. Go to **Monitoring → Hosts** (or **Configuration → Hosts** in older UI)
2. Click **Create host** (top right)
3. Fill in the **Host** tab:

| Field | Value |
|---|---|
| Host name | Must match the `Hostname=` in the agent config exactly |
| Visible name | Friendly name (e.g. `Web Server 01`) |
| Templates | Add templates here (see Section 5) |
| Host groups | Select or create a group (e.g. `Windows Servers`, `SQL Servers`) |

4. Click **Add** under **Interfaces** and choose **Agent**:

| Field | Value |
|---|---|
| IP address | The host's IP address |
| DNS | Leave blank unless using DNS |
| Connect to | IP |
| Port | `10050` |

5. Click **Add** to save the host

### Active vs Passive Agent Mode

| Mode | How it works | When to use |
|---|---|---|
| **Passive** (default) | Zabbix server connects to agent on port 10050 | Host is directly reachable from Zabbix server |
| **Active** | Agent connects to Zabbix server on port 10051 | Host is behind NAT/firewall (e.g. on-prem servers reaching Zabbix in AWS) |

For on-prem servers connecting to Zabbix in AWS, use **Active** mode:
- Set `ServerActive=<ZABBIX_SERVER_IP>` in the agent config
- In the host interface, set the port to `10051` and select **Active checks only**

---

## 5. Apply Monitoring Templates

Templates define what gets monitored. Apply them on the **Host** tab when creating or editing a host.

### Recommended Templates by Host Type

#### Windows Servers (IIS, general)

| Template | Monitors |
|---|---|
| `Windows by Zabbix agent` | CPU, memory, disk, network, services, uptime |
| `Windows services by Zabbix agent` | Specific Windows services (configurable) |
| `IIS by Zabbix agent` | IIS worker processes, request queue, connections |

#### SQL Server

| Template | Monitors |
|---|---|
| `Microsoft SQL Server by Zabbix agent` | Connections, blocked processes, deadlocks, buffer cache hit ratio, query times |

#### Linux Servers

| Template | Monitors |
|---|---|
| `Linux by Zabbix agent` | CPU, memory, disk, network, load average |

#### Network Devices (SNMP)

| Template | Monitors |
|---|---|
| `Network generic device by SNMP` | Interfaces, bandwidth, errors |
| `Cisco IOS by SNMP` | For Cisco routers/switches |

### How to Apply a Template

1. Edit the host → **Templates** tab
2. Start typing the template name in the search box
3. Select and click **Add**
4. Click **Update**

---

## 6. Verify the Host is Being Monitored

### Check Host Status

1. Go to **Monitoring → Hosts**
2. The **Availability** column shows green (ZBX) when the agent is reachable
3. If red — the Zabbix server cannot reach the agent (check firewall/IP)

### Check Latest Data

1. Click the host name → **Latest data**
2. You should see metrics populating within 1–2 minutes of adding the host

### Test Agent Connectivity from the Zabbix Server

SSH into the Zabbix server and run:

```bash
zabbix_get -s <HOST_IP> -p 10050 -k agent.ping
```

Expected response: `1`

If it times out — the agent is unreachable. Check:
- Agent is running on the host
- Port 10050 is open on the host's firewall
- Security group / network ACL allows traffic from the Zabbix server IP

---

## 7. Configure Email Alerting

### Step 1 — Create a Media Type (SMTP)

1. Go to **Alerts → Media types**
2. Click **Email** (built-in)
3. Configure:

| Field | Value |
|---|---|
| SMTP server | `email-smtp.us-east-1.amazonaws.com` (AWS SES) |
| SMTP port | `587` |
| SMTP helo | Your domain |
| SMTP email | Verified SES sender address |
| Connection security | STARTTLS |
| Authentication | Username and password |
| Username | SES SMTP username |
| Password | SES SMTP password |

4. Click **Update**

### Step 2 — Add Email to Your User

1. Go to **Users → Users** → click your admin user
2. Click **Media** tab → **Add**
3. Select **Email**, enter your email address
4. Set severity levels (check all: Disaster, High, Average, Warning, Information, Not classified)
5. Save

### Step 3 — Create an Action

1. Go to **Alerts → Actions → Trigger actions**
2. Click **Create action**
3. Name it (e.g. `Notify Admin`)
4. Under **Operations**, click **Add**:
   - Operation type: `Send message`
   - Send to users: your admin user
   - Send only to: `Email`
5. Save

---

## 8. Recommended Global Settings

Go to **Administration → General** and review:

| Setting | Recommended Value |
|---|---|
| Working time | `1-7,00:00-24:00` (24/7) |
| Default severity | Adjust trigger colors to your preference |
| History storage period | `90d` |
| Trend storage period | `365d` |

### Create Host Groups (Organization)

Go to **Configuration → Host groups** and create groups before adding hosts:

- `Windows Servers`
- `SQL Servers`
- `Linux Servers`
- `Network Devices`
- `AWS`

---

## 9. Host Reference — BEL Infrastructure

Hosts to onboard based on current BEL infrastructure:

| Hostname | IP | OS | Template(s) | Group |
|---|---|---|---|---|
| `srv-webapps-01` | TBD | Windows Server | Windows by Zabbix agent, IIS by Zabbix agent | Windows Servers |
| `srv-webapps` | TBD | Windows Server | Windows by Zabbix agent, IIS by Zabbix agent | Windows Servers |
| `BEL-API1` | TBD | Windows Server | Windows by Zabbix agent, IIS by Zabbix agent | Windows Servers |
| `srv-sql01` | TBD | Windows Server | Windows by Zabbix agent, Microsoft SQL Server by Zabbix agent | SQL Servers |
| `SRV-Attunity02` | TBD | Windows Server | Windows by Zabbix agent | Windows Servers |
| `SRV-UTIL` | `192.168.1.61` | Windows 2012 R2 | Windows by Zabbix agent | Windows Servers |

> **Note:** On-prem servers connect to Zabbix in AWS via VPN. Use **Active** agent mode so agents initiate the connection outbound to the Zabbix server — no inbound firewall changes needed on-prem.

### Agent Config for On-Prem Servers (Active Mode)

```ini
# C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf
Server=54.83.1.183
ServerActive=54.83.1.183
Hostname=srv-webapps-01        # change per host
```

---

## Quick Reference

| Task | Location in UI |
|---|---|
| Add a host | Monitoring → Hosts → Create host |
| Apply a template | Host editor → Templates tab |
| Check agent status | Monitoring → Hosts → Availability column |
| View latest metrics | Monitoring → Hosts → Latest data |
| Configure email | Alerts → Media types → Email |
| Create alert action | Alerts → Actions → Trigger actions |
| View active problems | Monitoring → Problems |
| View dashboards | Monitoring → Dashboard |
