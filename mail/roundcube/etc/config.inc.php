<?php

$config = [];

$config['db_dsnw'] = 'pgsql://roundcube:' . rawurlencode(getenv('ROUNDCUBE_DB_PASSWORD')) . '@postgres/roundcube';

$config['imap_host']        = 'dovecot:1143';
$config['smtp_host']        = 'postfix:10025';
$config['smtp_user']        = '%u';
$config['smtp_pass']        = '%p';
$config['managesieve_host'] = 'dovecot:4190';

$config['support_url']  = '';
$config['product_name'] = 'mx.nercone.dev';
$config['des_key']      = getenv('ROUNDCUBE_DES_KEY');

$config['username_domain'] = 'nercone.dev';
$config['mail_domain']     = '%d';

$config['skin']     = 'elastic';
$config['language'] = 'ja_JP';
$config['timezone'] = 'Asia/Tokyo';

$config['log_driver']      = 'stdout';
$config['temp_dir']        = '/var/lib/roundcube/temp';
$config['session_lifetime'] = 60;

$config['use_https']       = true;
$config['session_samesite'] = 'Strict';

$config['plugins'] = [
    'archive',
    'attachment_reminder',
    'emoticons',
    'enigma',
    'managesieve',
    'markasjunk',
    'newmail_notifier',
    'password',
    'vcard_attachments',
    'zipdownload',
];

$config['drafts_mbox'] = 'Drafts';
$config['junk_mbox']   = 'Junk';
$config['sent_mbox']   = 'Sent';
$config['trash_mbox']  = 'Trash';

$config['enigma_pgp_homedir']  = '/var/lib/roundcube/enigma';
$config['enigma_pgp_binary']   = '/usr/bin/gpg';
$config['enigma_passwordless'] = false;
$config['enigma_signatures']   = true;
$config['enigma_encryption']   = true;
$config['enigma_multihost']    = false;
$config['enigma_woext']        = false;
$config['enigma_keyserver']    = 'https://keys.openpgp.org';
$config['enigma_debug']        = false;

$config['mailvelope_main_keyring'] = true;

$config['managesieve_script_name'] = 'roundcube';
$config['managesieve_kolab_master'] = false;

$config['password_driver']           = 'sql';
$config['password_db_dsn']           = 'pgsql://mail:' . rawurlencode(getenv('MAIL_DB_PASSWORD')) . '@postgres/mail';
$config['password_query']            = "UPDATE accounts SET password = %P WHERE username = %l AND domain = %d";
$config['password_algorithm']        = 'hash-argon2id';
$config['password_algorithm_prefix'] = '{ARGON2ID}';
$config['password_confirm_current']  = true;
$config['password_minimum_length']   = 12;

$config['markasjunk_learning_driver'] = null;
