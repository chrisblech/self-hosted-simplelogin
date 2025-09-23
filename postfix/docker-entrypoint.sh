#!/bin/sh -eu

# Erwartete ENV-Variablen (vom Container übergeben)
: "${DOMAIN:?Need DOMAIN}"
SUBDOMAIN="${SUBDOMAIN:-app}"
PG_USERNAME="${POSTGRES_USER:?Need POSTGRES_USER}"
PG_PASSWORD="${POSTGRES_PASSWORD:?Need POSTGRES_PASSWORD}"

# Wo liegen Templates und wohin schreiben?
TEMPLATE_DIR="${TEMPLATE_DIR:-/templates}"
MAIL_CONFIG="${MAIL_CONFIG:-/etc/postfix/conf.d}"

# Regex-/Slash-Quoting für sed
ere_quote() {
  # escapet Regex-reservierte Zeichen inkl. /
  # shellcheck disable=SC1117
  printf '%s' "$1" | sed 's/[][\/\.|$(){}?+*^]/\\&/g'
}

# main.cf aus Template ableiten
sed \
  -e "s/app.domain.tld/${SUBDOMAIN}.${DOMAIN}/g" \
  -e "s/domain.tld/${DOMAIN}/g" \
  "$TEMPLATE_DIR/main.cf.tpl" > "$MAIL_CONFIG/main.cf"

# optionale Dateien nur erzeugen, wenn sie fehlen
[ -f "$MAIL_CONFIG/virtual" ] || \
  sed -e "s/domain.tld/${DOMAIN}/g" \
  "$TEMPLATE_DIR/virtual.tpl" > "$MAIL_CONFIG/virtual"

[ -f "$MAIL_CONFIG/virtual-regexp" ] || \
  sed -e "s/domain.tld/${DOMAIN}/g" \
  "$TEMPLATE_DIR/virtual-regexp.tpl" > "$MAIL_CONFIG/virtual-regexp"

# pgsql-*.cf aus Templates
PW_ESCAPED="$(ere_quote "$PG_PASSWORD")"

sed \
  -e "s/myuser/${PG_USERNAME}/g" \
  -e "s/mypassword/${PW_ESCAPED}/g" \
  -e "s/domain.tld/${DOMAIN}/g" \
  "$TEMPLATE_DIR/pgsql-relay-domains.cf.tpl" > "$MAIL_CONFIG/pgsql-relay-domains.cf"

sed \
  -e "s/myuser/${PG_USERNAME}/g" \
  -e "s/mypassword/${PW_ESCAPED}/g" \
  -e "s/domain.tld/${DOMAIN}/g" \
  "$TEMPLATE_DIR/pgsql-transport-maps.cf.tpl" > "$MAIL_CONFIG/pgsql-transport-maps.cf"

[ -f "$MAIL_CONFIG/aliases" ] && postalias $MAIL_CONFIG/aliases
[ -f "$MAIL_CONFIG/virtual" ] && postmap $MAIL_CONFIG/virtual

# Übergib an das eigentliche CMD des Containers (z.B. postfix start-fg)
exec "$@"
