# Providers
#
# GMail:
# Official documentation: https://support.google.com/mail/bin/answer.py?hl=fr&answer=78799
#   Domain name:  gmail.com
#   IMAP address: imap.gmail.com
#   IMAP port:    993
#   IMAP use ssl: true
Provider.create(name: 'gmail.com', imap_address: 'imap.gmail.com', imap_port: 993, imap_ssl: true)
