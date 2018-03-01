#!/usr/bin/env bash

URL="http://169.254.169.254/latest/meta-data/public-ipv4"

ipv4=$(curl ${URL})

echo "
loglevel: 4
log_rotate_size: 10485760
log_rotate_date: \"\"
log_rotate_count: 1
log_rate_limit: 100

hosts:
  - \"shiyang-ws.chat.eveonline.com\"
  - \"$ipv4\"

listen:
  -
    port: 5222
    ip: \"::\"
    module: ejabberd_c2s
    ##
    ## If TLS is compiled in and you installed a SSL
    ## certificate, specify the full path to the
    ## file and uncomment these lines:
    ##
    starttls: false
    certfile: \"/var/lib/ejabberd/wildcard_chat.eveonline.com_chain.pem\"
    ## protocol_options: 'TLSOPTS'
    ## dhfile: 'DHFILE'
    ## ciphers: 'CIPHERS'
    ##
    ## To enforce TLS encryption for client connections,
    ## use this instead of the "starttls" option:
    ##
    ## starttls_required: true
    ##
    ## Stream compression
    ##
    ## zlib: true
    ##
    max_stanza_size: 65536
    shaper: c2s_shaper
    access: c2s
  -
    port: 5269
    ip: \"::\"
    module: ejabberd_s2s_in
  -
    port: 5280
    ip: \"::\"
    module: ejabberd_http
    request_handlers:
      \"/websocket\": ejabberd_http_ws
      \"/api\": mod_http_api
    ##  "/pub/archive": mod_http_fileserver
    web_admin: true
    http_bind: true
    ## register: true
    captcha: true

host_config:
  \"shiyang-ws.chat.eveonline.com\":
    auth_method:
      - internal
      - anonymous
    allow_multiple_connections: false
    anonymous_protocol: both
  \"$ipv4\":
    auth_method:
      - internal
      - anonymous
    allow_multiple_connections: false
    anonymous_protocol: both	

shaper:
  ##
  ## The "normal" shaper limits traffic speed to 1000 B/s
  ##
  normal: 1000

  ##
  ## The "fast" shaper limits traffic speed to 50000 B/s
  ##
  fast: 50000

max_fsm_queue: 1000

###.   ====================
###'   ACCESS CONTROL LISTS
acl:
  ##
  ## The 'admin' ACL grants administrative privileges to XMPP accounts.
  ## You can put here as many accounts as you want.
  ##
  admin:
    user:
      - \"admin@entropy.internal.chat.eveonline.com\"
      - \"admin@bjorgvin-ws.internal.chat.eveonline.com\"

  ## Local users: don't modify this.
  ##
  local:
    user_regexp: \"\"

  ##
  ## Loopback network
  ##
  loopback:
    ip:
      - \"127.0.0.0/8\"
      - \"::1/128\"
      - \"::FFFF:127.0.0.1/128\"

shaper_rules:
  max_user_sessions: 10
  max_user_offline_messages:
    - 5000: admin
    - 100
  c2s_shaper:
    - none: admin
    - normal
  s2s_shaper: fast

access_rules:
  local:
    - allow: local
  c2s:
    - deny: blocked
    - allow
  announce:
    - allow: admin
  configure:
    - allow: admin
  ## Only admin accounts can create rooms:
  muc_create:
    - allow: admin
  pubsub_createnode:
    - allow: local
  register:
    - allow
  trusted_network:
    - allow: loopback

api_permissions:
  \"console commands\":
    from:
      - ejabberd_ctl
    who: all
    what: \"*\"
  \"admin access\":
    who:
      - access:
          - allow:
            - acl: loopback
            - acl: admin
      - oauth:
        - scope: \"ejabberd:admin\"
        - access:
          - allow:
            - acl: loopback
            - acl: admin
    what:
      - \"*\"
      - \"!stop\"
      - \"!start\"
  \"public commands\":
    who:
      - ip: \"127.0.0.1/8\"
    what:
      - \"status\"
      - \"connected_users_number\"

language: \"en\"

modules:
  mod_adhoc: {}
  mod_admin_extra: {}
  mod_announce: # recommends mod_adhoc
    access: announce
  mod_blocking: {} # requires mod_privacy
  mod_caps: {}
  mod_carboncopy: {}
  mod_client_state: {}
  mod_configure: {} # requires mod_adhoc
  ## mod_delegation: {} # for xep0356
  mod_disco: {}
  mod_echo: {}
  mod_irc: {}
  mod_bosh: {}
  mod_last: {}
  mod_muc:
    access:
      - allow
    access_admin:
      - allow: admin
    access_create: muc_create
    access_persistent: muc_create
    max_users: 5000
    history_size: 0
    default_room_options:
      allow_visitor_nickchange: false
      public_list: false
  mod_mam:
    iqdisc: one_queue
    db_type: sql
    default: always
    request_activates_archiving: false
    assume_mam_usage: false
    cache_size: 1000
    cache_life_time: 3600
  mod_muc_admin: {}
  mod_offline:
    access_max_user_messages: max_user_offline_messages
  mod_ping:
    send_pings: true
    ping_interval: 300
    timeout_action: none
  mod_privacy: {}
  mod_private: {}
  mod_pubsub:
    access_createnode: pubsub_createnode
    ## reduces resource comsumption, but XEP incompliant
    ignore_pep_from_offline: true
    ## XEP compliant, but increases resource comsumption
    ## ignore_pep_from_offline: false
    last_item_cache: false
    plugins:
      - \"flat\"
      - \"hometree\"
      - \"pep\" # pep requires mod_caps
  mod_roster: {}
  mod_shared_roster: {}
  mod_stats: {}
  mod_time: {}
  mod_vcard:
    search: false
  mod_version: {}
  mod_stream_mgmt: {}
  mod_s2s_dialback: {}
  mod_http_api: {}
  mod_expiring_records: {}
  mod_associations: {}
  mod_pi: {}

host_config:
  \"shiyang-ws.chat.eveonline.com\":
    ssoauth_allow_any: true
    bannedwords_regex_endpoint: \"http://172.31.22.161:8000/banned_words/regexes/\"
    bannedwords_replace_endpoint: \"http://172.31.22.161:8000/banned_words/replaceword/\"
  \"$ipv4\":
    ssoauth_allow_any: true
    bannedwords_regex_endpoint: \"http://172.31.22.161:8000/banned_words/regexes/\"
    bannedwords_replace_endpoint: \"http://172.31.22.161:8000/banned_words/replaceword/\"" > ejabberd.yml

echo "File Created!"

sudo mv -f ejabberd.yml /usr/local/etc/ejabberd/ejabberd.yml
