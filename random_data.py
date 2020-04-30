#!/bin/python
from bs4 import BeautifulSoup
import csv
import json
import random
import re
import requests


arr = []
n = int(input('How many names do you want? (multiples of 10): ')) // 10
for i in range(n):
    page = requests.get('https://www.name-generator.org.uk/quick/')
    soup = BeautifulSoup(page.content, 'html.parser')
    target = str(soup.find_all('div', class_='name_heading'))
    name_search = (re.findall(r'(?:>)([a-zA-Z]* [a-zA-Z]*)', target))
    arr.append(name_search)

ans = input('Do you want to save as JSON or csv? (json/csv): ')

if ans.lower() == 'json':
    json_array = []
    for names in arr:
        for name in names:
            data = dict()
            print(name)
            fname = name.split()[0]
            lname = name.split()[1]
            data['first_name'] = fname
            data['middle_name'] = ''
            data['last_name'] = lname
            data['phone_number'] = random.randint(100000000, 999999999)
            data['email'] = fname + '@test-domain.com'
            json_array.append(data)
    with open('random_data.json', 'w') as outfile:
            json.dump(json_array, outfile)
    print('File was saved in the current working directory as random_data.json')

elif ans.lower() == 'csv':
    csv_array = []
    for names in arr:
        for name in names:
            arr = []
            arr.append(name.split()[0])
            arr.append(name.split()[1])
            arr.append(random.randint(100000000, 999999999))
            arr.append(name.split()[0] + '@test-domain.com')
            csv_array.append(arr)
    with open('random_data.csv', 'w', newline='') as file:
        writer = csv.writer(file)
        for row in csv_array:
            writer.writerow(row)
    print('File was saved in the current working directory as random_data.csv')

