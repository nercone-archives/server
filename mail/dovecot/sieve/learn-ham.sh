#!/bin/sh
exec curl -s -o /dev/null -H @/etc/dovecot/rspamd-password --data-binary @- http://rspamd:11334/learnham
