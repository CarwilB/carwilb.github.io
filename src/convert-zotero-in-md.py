#!/usr/bin/env python3
import sqlite3
import re
import json
import argparse

def convert(db, filename):
    con = sqlite3.connect(db)
    cur = con.cursor()
    with open(filename, "r") as f:
        md = f.read()
        raw_match = re.findall('\[ITEM CSL_CITATION .*?\]\(.*?\)', md)
        citeid_match = [re.findall(r'\\"id\\":(\d*?),\\"uris', i) for i in raw_match]
        for i in range(len(raw_match)):
            s = "["
            for j in citeid_match[i]:
                s += "@" + list(cur.execute('SELECT * FROM citekeys WHERE itemID={}'.format(j)))[0][3] + "; "
            s = s.strip("; ")
            s += "]"
            print(s)
            md = md.replace(raw_match[i], s)
    with open(filename, "w") as f:
    	f.write(md)


# parser = argparse.ArgumentParser(description='Convert markdown in Zotero-style citations format (e.g., convert MS Word to Markdown via pandoc) to cite-key format. Requires better-bibtex.')
# parser.add_argument('db', metavar='db', type=str,
#                     help='Your better-bibtex-search.sqlite path.')
# parser.add_argument('filename', metavar='filename', type=str,
#                     help='The markdown file you converted with pandoc. Note that you will need to use pandoc option --wrap=none when converting it to markdown.')
# args = parser.parse_args()
# convert(args.db, args.filename)
