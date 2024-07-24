## Table of contents

- [Purpose](#purpose)
- [Assumptions](#assumptions)
- [Workflow](#workflow)
- [Data](#data)
- [Scope](#scope)
- [Web Links](#web)
- [Glossary](#glossary)

## Applications

[![Autodesk](https://img.shields.io/badge/License-Autodesk-green.svg)](https://www.autodesk.com/nz)

## Purpose

This repository contains script and supporting files to assist in the conversion of an InfoAsset network to 
Infoworks ICM (InfoWorks network).

Currently the main Ruby script file "_infoasset2icm.rb" can be run on the active network ie the one open in the Geoplan.

On completion of the code a new network will be updated into:
- database: snumbat://10.0.29.43:40000/wastewater ongoing/system_performance
- network: name='i2i network', location='other..networks' and id=4765

## Assumptions

order | assumption | notes
--- | --- | ---
'1' | access to ICM Ultimate and ICM Exchange.exe | **version used: ICM 2024.5**
'2' | access to ICM Ultimate and iexchange.exe | **version used: InfoAsset 2021.8.1**
'3' | understanding on InfoAsset SQL | **good**
'4' | understanding on ICM | **good**
'5' | understading on Ruby Script | **good**

## Workflow

```mermaid
flowchart TD
    A[InfoAsset] -->|open network in geoplan| B(select: network>run ruby script>_infoasset2icm.rb)
    B --> C{wait a little}
    C -->|SQL| D[selects network in geoplan]
    C -->|_infoasset2icm.rb| E[exports network as CSV files]
    C -->|_csv2icm.rb| F[upodates CSV files into ICM network]
```

## Code

#### Get all items

```http
  GET /api/items
```

| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `api_key` | `string` | **Required**. Your API key |

#### Get item

```http
  GET /api/items/${id}
```

| Parameter | Type     | Description                       |
| :-------- | :------- | :-------------------------------- |
| `id`      | `string` | **Required**. Id of item to fetch |

#### add(num1, num2)

Takes two numbers and returns the sum.

## Web Links

- [my github front page]: https://github.com/hrlewis1974
- [example of similar workflow]: https://www.linkedin.com/pulse/converting-infosewer-model-icm-infoworks-network-using-dickinson/
- [InfoAsset and ICM Exchange language]: https://help.autodesk.com/lessons/IWICMS_2024_ENU/files/Exchange.pdf

## Contacts

council | contact | email | contact details
--- | --- | --- | ---
WWL | Hywel Lewis | hywel.lewis@wellingtonwater.co.nz | Snr Hydraulic Modeller

## Glossary

term | meaning
--- | ---
Ruby | Coding language