# DKIM signing for postfix-internal/outgoing mail (e.g. MAILER-DAEMON bounces)
# ============================================================================
#
# Only enable DKIM for **non-SMTP originated** messages. SMTP-ingested mail
# is handled by the SimpleLogin email component and should not be double-signed.

non_smtpd_milters = inet:opendkim:8891
milter_default_action = accept
milter_protocol = 6

