#!

cd /home/cjg/Projects/Grinder
curl -s 'https://spreadsheets.google.com/pub?key=0AqodCQwjuWZXdEJ2clBveW45VnkyVTR4YzRsVGlSaUE&hl=en&output=xls' > var/dev8d2011.xls
bin/grinder.pl --config etc/programme.cfg  > ~/public_html/dev8d.rdf

