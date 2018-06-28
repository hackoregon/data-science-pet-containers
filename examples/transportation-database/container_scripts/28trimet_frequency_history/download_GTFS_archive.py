import argparse
import os
import sys
import time
from pathlib import Path

import requests

from bs4 import BeautifulSoup


def get_command_line_args():
    # Create command line parser.
    parser = argparse.ArgumentParser(prog="Download GTFS Archives")

    # Init the group of required arguments.
    group = parser.add_argument_group()

    # Add required arguments.
    # -l with file path to just download the list of URLS
    # -d with folder path to download all data folders.
    group.add_argument(
        "-l",
        dest='list_file_path',
        help="Export list of URLs to this given file path.")
    group.add_argument(
        "-d",
        dest='download_folder_path',
        help="Download all archive folders to this given folder path.")

    return parser


if __name__ == '__main__':
    # Grab command line arguments.
    parser = get_command_line_args()

    # Make sure we got something.
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit()
    else:
        args = parser.parse_args()

    # Set output based on which argument is given.
    if args.download_folder_path:
        export_folder_path = Path(args.download_folder_path)
        if not export_folder_path.exists():
            print(f"Export folder {export_folder_path} does not exist. "
                  "Creating.")
            os.mkdir(export_folder_path)
        do_download = True
    else:
        do_download = False

    if args.list_file_path:
        url_file_path = Path(args.list_file_path)
        do_file = True
    else:
        do_file = False

    # Define a megabyte.
    MBYTE = 1024 * 1024

    # First source URL.
    url = 'http://www.gtfs-data-exchange.com/agency/trimet/?page='

    # I cheated and knew there were 34 pages.
    for page in [str(i+1) for i in range(34)]:
        # Add the page number into the url.
        this_url = url + page

        # Get the html for this url.
        r = requests.get(this_url)
        if r.status_code == requests.codes['OK']:
            html = r.text

        # Parse it with bs4.
        soup = BeautifulSoup(html, 'html.parser')
        print(f'\nProcessing: {this_url}')

        # Search for 'href' tag.
        for name in soup.findAll('a', href=True):
            if (name['href'].endswith('.zip') and
                    ('trimet_' in name['href'] or
                     'trimet-archiver' in name['href'])):
                # Store the link specific to a desired zip file.
                zipurl = name['href']
                print(f"\n\tZIPURL: {zipurl}")

                # Make another request for that zip file
                r = requests.get(zipurl, stream=True, timeout=5)

                # If the request is ok.
                if r.status_code == requests.codes['OK']:
                    # Get an idea of file size.
                    fsize = int(r.headers['content-length'])

                    # Download the file.
                    if do_download:
                        # Create filename from the .zip portion of the URL.
                        outfname = export_folder_path / zipurl.split('/')[-1]
                        print(f'\tSaving: {outfname} \t'
                              f'{fsize/MBYTE:0.1f} Mb ...', flush=True)

                        with open(outfname, 'wb') as fd:
                            # Downloads in chunks. Adjust as neeeded.
                            for chunk in r.iter_content(chunk_size=1024):
                                # Write the chunk to a file.
                                if chunk:
                                    fd.write(chunk)

                    # Add url to the list.
                    if do_file:
                        print(f'\tAppending: {zipurl} to {url_file_path}.')
                        with open(url_file_path, 'a') as fobj:
                            fobj.write(f"{zipurl}\n")
                    print('\tDone.')
                else:
                    print(f"Unable to download from: {zipurl}")

            # This might help if you're just making a file and not downloading.
            # Sometimes the script would bonk if it went too fast.
            time.sleep(0.1)

    # Second source URL.
    url = 'http://transitfeeds.com/p/trimet/43?p='

    # I cheated and knew there were 21 pages.
    for page in [str(i+1) for i in range(21)]:
        # Add the page number into the url
        this_url = url + page

        # Get the html for this url.
        r = requests.get(this_url)
        if r.status_code == requests.codes['OK']:
            html = r.text

        # Parse it with bs4.
        soup = BeautifulSoup(html, 'html.parser')
        print(f'\nProcessing: {this_url}')

        # Search for 'href' tag.
        for name in soup.findAll('a', href=True):
            if 'download' in name['href'] and 'latest' not in name['href']:
                # Store the link specific to a desired zip file.
                zipurl = name['href']

                # We need to prepend the beginning of the source URL for this
                # one.
                zipurl = f"http://transitfeeds.com{zipurl}"
                print(f"\n\tZIPURL: {zipurl}")

                # Make another request for that zip file
                r = requests.get(zipurl, stream=True, timeout=5)

                # If the request is okay.
                if r.status_code == requests.codes['OK']:
                    # Get an idea of file size.
                    fsize = int(r.headers['content-length'])

                    # Download the file.
                    if do_download:
                        # Create a filename using the date from the zipurl.
                        outfname = (export_folder_path /
                                    (zipurl.split('/')[-2] + '.zip'))
                        print(f'\tSaving: {outfname} \t'
                              f'{fsize/MBYTE:0.1f} Mb ...', flush=True)

                        with open(outfname, 'wb') as fd:
                            # Downloads in chunks. Adjust as neeeded.
                            for chunk in r.iter_content(chunk_size=1024):
                                # Write the chunk to a file.
                                if chunk:
                                    fd.write(chunk)

                    # Add url to the list.
                    if do_file:
                        print(f'\tAppending: {zipurl} to {url_file_path}.')
                        with open(url_file_path, 'a') as fobj:
                            fobj.write(f"{zipurl}\n")
                    print('Done.')
                else:
                    print(f"Unable to download from: {zipurl}")

            # May or may not help with timeouts.
            time.sleep(0.1)
