#avi-puppet

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with avi-puppet](#setup)
    * [What avi-puppet affects](#what-puppetlabs-avi-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with avi-puppet](#beginning-with-avi)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

Avi puppet module allows you to create and manage configurations of objects in Avi Controller. Puppet agent which runs on controller uses REST APIs to communicate with controller.

##Module Description

This module consist of a wrapper around Avi CLI. It uses current user's credentails to register with controller and update objects using underlaying REST API.

Avi module uses config_import script in controller (located at /opt/avi/python/bin/utils). Given a valid JSON config export file, it imports everything in file to controller configs. If any existing object is changed, the script will update the configuration of existing object.


##Setup

###Setup Requirements

   * Avi Controller services are up and running
   * Puppet agent is running on the master node

You will manually need to point puppet agent running on controller to puppet-server.

###What Avi module affects
   * Avi Controller services
   * Virtual services running on service engines

###Beginning with Avi

The simplest way to get started with Avi is to create a VS config JSON file
/root/configs/lb.json and import to Avi Controller as -

    node 'hostname.example.com' {
        include avi
    }

Sample lb.json file -

    {
        "VirtualService": [
            {
                "description": "",
                "name": "My Application",
                "address": "10.10.1.10",
                "ip_address": {
                    "addr": "10.10.1.10",
                    "type": "V4"
                },
                "enabled": true,
                "services": [
                    {
                        "port": 80,
                        "enable_ssl": false
                    }
                ],
                "application_profile_ref": "admin:System-HTTP",
                "network_profile_ref": "admin:System-TCP-Proxy",
                "pool_ref": "admin:NginxPool",
                "ssl_key_and_certificate_refs": [],
                "analytics_policy": {
                    "full_client_logs": {
                        "enabled": true,
                        "duration": 30
                    },
                    "client_log_filters": [],
                    "client_insights": "ACTIVE",
                    "metrics_realtime_update": {
                        "enabled": true,
                        "duration": 60
                    }
                },
                "enable_autogw": false,
                "tenant_ref": "admin",
            }
        ],
        "Pool": [
            {
                "description": "",
                "name": "p1",
                "default_server_port": 80,
                "graceful_disable_timeout": 1,
                "connection_ramp_duration": 299,
                "max_concurrent_connections_per_server": 10000,
                "health_monitor_refs": [
                    "admin:System-Ping",
                    "admin:System-TCP"
                ],
                "servers": [
                    {
                        "ip": {
                            "addr": "10.40.21.62",
                            "type": "V4"
                        },
                        "hostname": "nginx-1.avi.local",
                        "enabled": true,
                        "ratio": 1
                    },
                    {
                        "ip": {
                            "addr": "10.40.21.61",
                            "type": "V4"
                        },
                        "hostname": "nginx-2.avi.local",
                        "enabled": true,
                        "ratio": 12
                    }
                ],
                "lb_algorithm": "LB_ALGORITHM_LEAST_CONNECTIONS",
                "use_service_port": false,
                "inline_health_monitor": false,
                "networks": [],
                "tenant_ref": "admin",
                "certificate": []
            }
        ],
    }

In Puppet module, change VS config file path to actual path on controller node -

    exec { 'python /opt/avi/python/bin/utils/config_import.py --command "import configuration file <PATH_TO_LB_JSON>"':
            path           => "/bin:/usr/bin:/usr/sbin/sbin",
            require        => File['PATH_TO_LB_JSON',
                                   '/opt/avi/python/bin/utils/config_import.py']
    }


##Usage

The config file (/root/configs/lb.json) is used to maintain and update all
configurations on the Avi Controller.

###Add new service to Virtual Service

Updates to Virtual Service can be made by modifying contents of a JSON config file. To add another service port (443) on virtual server, add following lines at top of services list in lb.json file -

                {
                    "port": 80,
                    "enable_ssl": false
                },

The new object will look like -

    "services": [
                {
                    "port": 80,
                    "enable_ssl": false
                },
                {
                    "port": 443,
                    "enable_ssl": true
                }
        ],

The next run of puppet agent on controller will add new service port to virtual service. Removing services or any other config can be done with remove the corresponding configuration from JSON file.

###Add SSL certificate to Virtual Service
To add SSL certificate, add following lines to lb.json file.

    ssl_profile_ref: "admin:Standard",
    ssl_key_and_certificate_refs: ["admin:System-Default-Cert"]

This will use System-Default-Cert while serving requests coming on SSL port.

##Reference

The documentation about available objects and attributes is available at - [Avi Controller API Guide] (http://avinetworks.com/customerportal)

##Limitations

* Puppet module allows to import and update existing configurations to controller but, doesn't allow any deletes.

Addressing limitations is planned for upcoming release of avi-puppet module.

##Development

Avi module can be customized to run all commands supported by our CLI. This can be done by adding multiple lines of -

    exec { 'python /opt/avi/python/bin/utils/config_import.py --command "COMMAND TO EXECUTE"':
            path           => "/bin:/usr/bin:/usr/sbin/sbin",
            require        => File['/opt/avi/python/bin/utils/config_import.py']
        }

in init.pp of avi module.


##License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
