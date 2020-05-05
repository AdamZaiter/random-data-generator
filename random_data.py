#!/bin/python
from bs4 import BeautifulSoup
import csv
import json
import random
import re
import requests
import argparse


parser = argparse.ArgumentParser(
    description='Random data generator')
parser.add_argument('outfile', 
                    help='Provide an output file (.json or .csv)')
parser.add_argument('-u', '--users', action='store_true',
                    help='Generate data for users')
parser.add_argument('-s', '--students', action='store_true',
                    help='Generate data for students')
parser.add_argument('-t', '--teachers', action='store_true',
                    help='Generate data for teachers')
parser.add_argument('-c', '--classes', action='store_true',
                    help='Generate data for classes')
args = parser.parse_args()

outfile = args.outfile
file_type = outfile.split('.')[1]

arr = []
n = int(input('How many names do you want?: ')) // 10

if args.users:
    for i in range(n):
        page = requests.get('https://www.name-generator.org.uk/quick/')
        soup = BeautifulSoup(page.content, 'html.parser')
        target = str(soup.find_all('div', class_='name_heading'))
        name_search = (re.findall(r'(?:>)([a-zA-Z]* [a-zA-Z]*)', target))
        arr.append(name_search)

if file_type.lower() == 'json':
    json_array = []
    for names in arr:
        for name in names:
            data = dict()
            fname = name.split()[0]
            lname = name.split()[1]
            data['first_name'] = fname
            data['middle_name'] = ''
            data['last_name'] = lname
            data['phone_number'] = random.randint(100000000, 999999999)
            data['email'] = fname + '@test-domain.com'
            json_array.append(data)
    with open(outfile, 'a') as outfile:
            json.dump(json_array, outfile)
    print('File was saved as', args.outfile)

elif file_type.lower() == 'csv':
    csv_array = []
    for names in arr:
        for name in names:
            a = []
            a.append(name.split()[0])
            a.append(name.split()[1])
            a.append(random.randint(100000000, 999999999))
            a.append(name.split()[0] + '@test-domain.com')
            csv_array.append(a)
    with open(outfile, 'a', newline='') as file:
        writer = csv.writer(file)
        for row in csv_array:
            writer.writerow(row)
    print('File was saved as', outfile)
          
