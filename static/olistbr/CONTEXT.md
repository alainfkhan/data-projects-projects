# Context

## Olist

### Business

### Kaggle Dataset

Project dataset links:

- [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (1)
- [Marketing Funnel by Olist](https://www.kaggle.com/datasets/olistbr/marketing-funnel-olist) (2)

Provided ERDs:

![Dataset 1 ERD](references/img/HRhd2Y0%20-%20Imgur.png)

![Dataset 2 ERD](references/img/Jory0O3%20-%20Imgur.png)

<!-- Combined dataset ERDs:

![Datasets 1 and 2 combined ERD](img/erd.png) -->

## Brazil

### Currency

Summary:

|                     |                  |
| ------------------- | ---------------- |
| Symbol              | `R$`           |
| ISO Code            | `BRL`          |
| Thousands separator | Period `.`     |
| Decimal separator   | Comma `,`      |
| Example             | `R$ 10.000,00` |

Exchange rate [BRL to GBP](https://www.exchangerates.org.uk/BRL-GBP-spot-exchange-rates-history-2018.html):

| Significance         | Date           | BRL         | GBP          |
| -------------------- | -------------- | ----------- | ------------ |
| First order placed   | `2016-09-04` | `R$ 1,00` | `£0.1964` |
| Start of 'this year' | `2018-01-01` | `R$ 1,00` | `£0.2234` |
| Defined as 'today'   | `2018-08-22` | `R$ 1,00` | `£0.1916` |
| Last order placed    | `2018-10-17` | `R$ 1,00` | `£0.2069` |

- Banknotes: `R$ 2`, `R$ 5`, `R$ 10`, `R$ 20`, `R$ 50`, `R$ 100`, `R$ 200`
- Coins (centavos): `R$ 0,01`, `R$ 0,05`, `R$ 0,10`, `R$ 0,25`, `R$ 0,50`, `R$ 1,00`

### Time

In Brazil, the Financial Year (FY) follows the Calendar Year (CY).

- Q1 CY26 = Q1 FY26
- Q2 CY26 = Q2 FY26
- ...

The first quarter of the financial year is the first quarter of the calendar year.

Time zones currently being used in Brazil ([link](https://www.timeanddate.com/time/zone/brazil)):

| Offset   | Abb. | Name                     | Example city        |
| -------- | ---- | ------------------------ | ------------------- |
| UTC-5:00 | ACT  | Acre Time                | Rio Branco          |
| UTC-4:00 | AMT  | Amazon Time              | Manaus              |
| UTC-3:00 | BRT  | Brasília Time           | São Paulo          |
| UTC-2:00 | FNT  | Fernando de Noronha Time | Fernando de Noronha |

The official time used in Brazil is BRT.
