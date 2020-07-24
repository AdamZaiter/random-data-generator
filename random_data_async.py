import argparse
from bs4 import BeautifulSoup
import csv
import json
import random
import re
import requests
import asyncio
from concurrent.futures import ThreadPoolExecutor


def get_name(session):
    url = 'https://www.behindthename.com/random/'\
        'random.php?number=2&sets=5&gender=both&surname=&randomsurname='\
        'yes&norare=yes&usage_eng=1%27'
    with session.get(url) as res:
        soup = str(BeautifulSoup(res.content, 'html.parser'))
        name_search = re.findall(r'(/name/\w*">)(\w*)', soup)
        a = [x[1] for x in name_search]
        for i in range(0, len(a), 3):
            if i + 2 < len(a):
                yield a[i] + ' ' + a[i+1] + ' ' + a[i+2]


async def get_async_names(n):
    global arr
    print("Downloading names...")
    with ThreadPoolExecutor(max_workers=10) as executor:
        with requests.Session() as session:
            loop = asyncio.get_event_loop()
            tasks = [
                loop.run_in_executor(
                    executor,
                    get_name,
                    session
                )
                for i in range(n)
            ]
            for res in await asyncio.gather(*tasks):
                arr.append(res)

def make_json(arr, outfile):
    json_array = []
    print_chars = ["|", "/", "-", "\\"]
    for i, names in enumerate(arr):
        print(f"\rGenerating file {print_chars[i%4]}", end="", flush=True)
        for name in names:
            data = dict()
            fname = name.split()[0]
            mname = name.split()[1]
            lname = name.split()[2]
            data['first_name'] = fname
            data['middle_name'] = mname
            data['last_name'] = lname
            data['phone_number'] = random.randint(100000000, 999999999)
            data['email'] = fname + '@testdomain.com'
            json_array.append(data)
    print()
    with open(outfile, 'a') as o:
            json.dump(json_array, o)
    print('File was saved as', outfile)


def make_csv(arr, outfile):
    csv_array = []
    print_chars = ["|", "/", "-", "\\"]
    for i, names in enumerate(arr):
        for name in names:
            print(f"\rGenerating file {print_chars[i%4]}", end="", flush=True)
            a = []
            a.append(name.split()[0])
            a.append(name.split()[1])
            a.append(name.split()[2])
            a.append(random.randint(100000000, 999999999))
            a.append(name.split()[0] + '@test-domain.com')
            csv_array.append(a)
    print()
    with open(outfile, 'a', newline='') as file:
        writer = csv.writer(file)
        for row in csv_array:
            writer.writerow(row)
    print('File was saved as', outfile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Random data generator')
    parser.add_argument('outfile',
                        help='Provide an output file (.json or .csv)')
    parser.add_argument('-n', '--number',
                        help='number of entries to be generated')

    args = parser.parse_args()
    outfile = args.outfile
    file_type = outfile.split('.')[1]
    n = int(args.number) // 5

    arr = []
    loop = asyncio.get_event_loop()
    future = asyncio.ensure_future(get_async_names(n))
    loop.run_until_complete(future)

    if file_type.lower() == 'json':
        make_json(arr, outfile)
    elif file_type.lower() == 'csv':
        make_csv(arr, outfile)
    else:
        print('Wrong file type')
