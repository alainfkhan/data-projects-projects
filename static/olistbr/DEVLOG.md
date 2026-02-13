# DEVLOG

## 2026/02/13: Add supplementary dataset
- download Brazilian CEP (postal codes) dataset: `TB_CEP_BR_2018.csv` from [link](https://data.mendeley.com/datasets/g97jb8fp57/1) to supplement analaysis
- saved to `data/external/TB_CEP_BR_2018.csv`
- add `TB_CEP_BR_2018.csv` to `.gitignore` since it's `99.3MB`
- decided not to clean user inputs from geolocaion dataset column geolocation_city
- if I wanted to find the city name from its region code, I'll use `TB_CEP_BR_2018.csv` to compare
