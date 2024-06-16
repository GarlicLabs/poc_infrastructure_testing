# Garlic Infrastructure Testing

## Introduction

This repository contains example tests written in the Robot Framework. The tests are for testing our infrastructure in an automated way.  
The tests are part of our [Automated Update PoC](https://github.com/GarlicLabs/poc_automated_updating). With these tests we try to validate our assumption of stable updating, supported by tests.
Currently our tests cover the following infrastructure parts:
    - Node Exporter
    - Grafana
        - The connection between them
    - Some basic Kubernetes services 

## Prerequirements

- Python
- Robot Framework and Libraries

You can find the Libraries and python packages in the pip_requirements.txt file.

## Setup

To install Robot Framework and Libraries, run:
```bash
python3 -m venv ./venv
venv/bin/pip install -r pip_requirements.txt
venv/bin/rfbrowser init
```

## How to run tests

To run the tests, run: 
```bash
cp kubernetes/config.default.yml kubernetes/config.yml
# Adjust config 
venv/bin/robot kubernetes/kubernetes.robot
```
