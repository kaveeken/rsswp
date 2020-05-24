#!/bin/sh

newsboat -x reload

sqlite3 $HOME/.newsboat/cache.db > feed_tube <<EOF # don't know why this works exactly
SELECT author, strftime('%Y-%m-%d %H:%M', pubDate, 'unixepoch', 'localtime'), title FROM (
SELECT * FROM rss_item WHERE (guid LIKE '%yt%' OR url LIKE '%bitchute%') ORDER BY pubDate DESC LIMIT 30)
ORDER BY pubDate DESC;
EOF

sqlite3 $HOME/.newsboat/cache.db > feed_not <<EOF
SELECT author, strftime('%Y-%m-%d %H:%M', pubDate, 'unixepoch', 'localtime'), title FROM (
SELECT * FROM rss_item WHERE (guid NOT LIKE '%yt%' and url NOT LIKE '%bitchute%') ORDER BY pubDate DESC LIMIT 30)
ORDER BY pubDate DESC;
EOF

sed -i 's/|/ | /g' feed_tube;
sed -i 's/|/ | /g' feed_not;
sed -i 's/.*/\<p\>&\<\/p\>/' feed_tube;
sed -i 's/.*/\<p\>&\<\/p\>/' feed_not;

cat page_top feed_not page_middle feed_tube page_bottom > page.html
brave --headless --screenshot --window-size=1600,890 page.html
feh --bg-scale screenshot.png
