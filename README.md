# nextcloud

## Module description

[Nextcloud](https://nextcloud.com/) is a content collaboration platform.

This Puppet module simplifies the installation and configuration of _Nextcloud_ in your infrastructure.

## Choices

* Let the Puppet administrator configure the web server he wants
* Use PostgreSQL database, only
* Provide tasks to help administrator to setup its instance and reduce the in-software administrator privileges

## Hardening features

* Set config file as read-only, to prevent from modification from the web UI
* Split additionnal apps from core apps, to track what comes from core and what is added
* Disable the upgrade from UI; Yes, its a big security breach to allow an application to rewrite itself
* Disable the app store; Again its a security breach to let user to install third party apps without a review
* Install without default administrator user

## Wishes

* Core install/upgrade task should check version (last minor to upgrade to next major)
* Allow to install apps using conformation (puppet agent) instead of orchestration (bolt/choria)
* Detect which post-upgrade steps are needed (e.g. `db:add-missing-indices`, `db:add-missing-primary-keys`, etc.) using CLI/orchestration
* Use different users to deploy and run the application¹
* Improve the scope of _Nextcloud_ configuration that can be made outside of the web UI (e.g. In web UI, _Sharing_ → _Share by mail_ → _Send password by mail_: _disable_)

[1] At time of writing, _Nextcloud_ does strange permissions check that prevent us to hardened this part
