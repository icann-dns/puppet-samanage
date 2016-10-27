[![Build Status](https://travis-ci.org/icann-dns/puppet-samanage.svg?branch=master)](https://travis-ci.org/icann-dns/puppet-samanage)
[![Puppet Forge](https://img.shields.io/puppetforge/v/icann/samanage.svg?maxAge=2592000)](https://forge.puppet.com/icann/samanage)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/icann/samanage.svg?maxAge=2592000)](https://forge.puppet.com/icann/samanage)
# samanage

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with samanage](#setup)
    * [What samanage affects](#what-samanage-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with samanage](#beginning-with-samanage)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Manage client and server](#manage-client-and-server)
    * [Ansible client](#samanage-client)
    * [Ansible Server](#samanage-server)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module installs samanage and can also manage the custom scripts, host script and custom modules directories

## Setup

### What samanage affects

* installs samanage 

### Setup Requirements 

* puppetlabs-stdlib 4.12.0
* icann-tea 0.2.5

### Beginning with samanage


```puppet
class {'::samanage': }
```

## Reference

### Classes

#### Public Classes

* [`samanage`](#class-samanage)

#### Private Classes

* [`samanage::params`](#class-samanageparams)

#### Class: `samanage`

Main class

##### Parameters 

* `conf_file` (Tea::Absolutepath, Default: OS specific): Location of the config file
* `module_file` (Tea::Absolutepath, Default: OS specific): Location of the modules file
* `basevardir` (Tea::Absolutepath, Default: OS specific): Location to stopre state data
* `ssl` (Boolean, Default: true): Use SSL
* `debug` (Boolean, Default: false): Enable Debugging 
* `server` (Tea::HTTPUrl, Default: 'https://inventory.samanage.com/ocsinventory'): URL to submit data
* `ca_path` (Tea::Absolutepath, Default: OS specific): The location of the system CA data
* `logfile` (Tea::Absolutepath, Default: OS specific): Location of the logfile
* `packages` (Array[String], Default: OS Specific): array of packages to install
* `enable_cron` (Boolean, Default: true): Enable a cron job to periodicly send data
* `use_fqdn` (Boolean, Default: true): Use the FQDN instead of hostname
* `fdqn_file` (Tea::Absolutepath, Default: OS specific): The perl file to patch to use the FQDN
* `ocs_tag` (Optional[String], Default: undef): Set agent setting TAG value

## Limitations

This module is tested on FreeBSD 10 and ubunto 14.04 

