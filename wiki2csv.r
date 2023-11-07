import pandas as pd

def wiki_to_csv(wikiurl):
    tables = pd.read_html(wikiurl, header=0)
    for i in range(len(tables)):
        if not tables[i].empty:
            fname = "table_" + str(i) + ".csv"
            tables[i].to_csv(fname, sep=',')
