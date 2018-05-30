from bs4 import BeautifulSoup
from pathlib import Path
import requests
import argparse

parser = argparse.ArgumentParser()
required = parser.add_argument_group('Required Arguments')
# Add required arguments.
required.add_argument(
    "-d",
    dest='export_folder_path',
    help="Where do you want to store the data.")

args = parser.parse_args()

# point to output directory
# outpath = Path(r'/Users/jbeyer/Documents/Hack Oregon/GTFS_archive_data/scraped_zip_folders')
outpath = args.export_folder_path

url = 'http://www.gtfs-data-exchange.com/agency/trimet/?page='
mbyte=1024*1024

for page in [str(i+1) for i in range(34)]:
    this_url = url + page
    print(f'Reading: {this_url}')
    html = requests.get(this_url).text
    soup = BeautifulSoup(html, 'html5lib')
    print(f'Processing: {this_url}')
    for name in soup.findAll('a', href=True):
        zipurl = name['href']
        if zipurl.endswith('.zip') and 'archiver' in zipurl:
            outfname = outpath / Path(zipurl.split('/')[-1])
            r = requests.get(zipurl, stream=True)
            if r.status_code == requests.codes.ok:
                fsize = int(r.headers['content-length'])
                print(f'\tDownloading {outfname.name} {fsize/mbyte:0.1f} Mb ... ', end='', flush=True)
                with open(outfname, 'wb') as fd:
                    for chunk in r.iter_content(chunk_size=1024): # chuck size can be larger
                        if chunk: # ignore keep-alive requests
                            fd.write(chunk)
                print('Done.')

# point to output directory
url = 'http://transitfeeds.com/p/trimet/43?p='
mbyte=1024*1024

for page in [str(i+1) for i in range(21)]:
    this_url = url + page
    print(f'Reading: {this_url}')
    html = requests.get(this_url).text
    soup = BeautifulSoup(html, 'html5lib')
    print(f'Processing: {this_url}')
    for name in soup.findAll('a', href=True):
        zipurl = name['href']
        if 'download' in zipurl and 'latest' not in zipurl:
            outfname = outpath / Path(zipurl.split('/')[-2] + '.zip')
            r = requests.get('http://transitfeeds.com/' + zipurl, stream=True)
            if r.status_code == requests.codes.ok:
                fsize = int(r.headers['content-length'])
                print(f'\tDownloading {outfname.name} {fsize/mbyte:0.1f} Mb ... ', end='', flush=True)
                with open(outfname, 'wb') as fd:
                    for chunk in r.iter_content(chunk_size=1024): # chuck size can be larger
                        if chunk: # ignore keep-alive requests
                            fd.write(chunk)
                print('Done.')