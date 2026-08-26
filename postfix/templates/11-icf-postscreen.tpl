
postscreen_bare_newline_enable = yes
postscreen_bare_newline_action = enforce

postscreen_greet_action = enforce

postscreen_non_smtp_command_enable = yes
postscreen_non_smtp_command_action = enforce

postscreen_pipelining_enable = yes

# Reputable senders (list.dnswl.org) get a negative score and skip the
# before-greeting tests + the mandatory first-contact retry entirely,
# instead of waiting out postscreen_greet_wait on every new source IP —
# this matters most for big providers (M365, Google, ...) that spread
# retries across a large, frequently-rotating outbound IP pool, since
# each such IP otherwise looks "new" to postscreen's own cache.
postscreen_dnsbl_sites =
  list.dnswl.org=127.0.[0..255].0*-2,
  list.dnswl.org=127.0.[0..255].1*-3,
  list.dnswl.org=127.0.[0..255].2*-4,
  list.dnswl.org=127.0.[0..255].3*-5
postscreen_dnsbl_threshold = 1
postscreen_dnsbl_action = enforce
