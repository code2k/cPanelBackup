cPanelBackup.sh
===============

A script for downloading a backup of your cPanel hosted website.

Requirements
------------

* [curl](http://curl.haxx.se/) >= 7.19.7
* [GNU sed](http://www.gnu.org/software/sed/) >= 4.2.1

Configuration
-------------

To setup the backup script create a configuration file named *.cpanelbackuprc*
in your home directory. You can create a skeleton by executing the following
command:

    ./cPanelBackup.sh | tail -n +6 > cpanelbackuprc && mv cpanelbackuprc ~/.cpanelbackuprc

Edit the created configuration and change the values according to your
environment.

### CPANEL_USER ###

Your cPanel username.

### CPANEL_PASSWD ###

Your cPanel password.

### CPANEL_HOST ###

URL of the cPanel site (e.g. http://domain.com:2082)

### BACKUP_DIR ###

Path to the backup location. If the directory does not exists it will be
created.

### BACKUP_BASENAME ###

prefix for your backup files (e.g. domainname).

### SED ###

Name of the GNU sed excecutable. This should be *sed* on the most systems. On
Mac homebrew change to *gsed*.

### REMOVE_OLDER_THAN ###

Number of days to keep old backups. 