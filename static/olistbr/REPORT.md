# Report

## Assumptions

## Definitions

### Brazilian currency

Summary:

|                     |                  |
| ------------------- | ---------------- |
| Symbol              | `R$`           |
| ISO Code            | `BRL`          |
| Decimal Separator   | Comma `,`      |
| Thousands Separator | Period `.`     |
| Example             | `R$ 10.000,00` |

Exchange rate at time of project:

| `2018-01-01` [BRL to GBP](https://www.exchangerates.org.uk/BRL-GBP-spot-exchange-rates-history-2018.html) |
| :------------------------------------------------------------------------------------------------------: |
|                                        `1 BRL` = `0.2234 GBP`                                        |

Common values:

| BRL        | GBP        |
| ---------- | ---------- |
| `50,00`  | `11.17`  |
| `100,00` | `22.34`  |
| `150,00` | `33.51`  |
| `200,00` | `44.68`  |
| `250,00` | `55.85`  |
| `500,00` | `111.70` |

- Banknotes: `R$ 2`, `R$ 5`, `R$ 10`, `R$ 20`, `R$ 50`, `R$ 100`, `R$ 200`
- Coins (centavos): `R$ 0.01`, `R$ 0.05`, `R$ 0.10`, `R$ 0.25`, `R$ 0.50`, `R$ 1.00`

### Practical project scope

The dataset provided by Olist shows a growth and decay of captured data.

Choose,
from this dataset,
a reaslistic start and end date,
that best reflect a supposed snapshot taken of the database under normal business operations.

For any analysis that require practicality choose:

- Snapshot start date: `2017-01-09`
- Snapshot end date: `2018-08-21`

For any practical analyses, suppose then, that today is `2018-08-22`,
and we have no knowledge of data beyond that dated.

<details>

<summary>Reasoning</summary>

#### Growth of data capture

```txt
full_date   orders_placed
2017-01-04	0
2017-01-05	32
2017-01-06	4
2017-01-07	4
2017-01-08	6
2017-01-09	5       <--
2017-01-10	6
2017-01-11	12
2017-01-12	13
2017-01-13	12
2017-01-14	18
```

Before `2017-01-04`:

- Orders placed consistently stay `0`.
- Some orders placed spuriously between `2016-09-04` - `2016-10-22`.

#### Decay of data capture

```txt
full_date   orders_placed
2018-08-16	320
2018-08-17	257
2018-08-18	198
2018-08-19	204
2018-08-20	256
2018-08-21	243     <--
2018-08-22	187
2018-08-23	144
2018-08-24	99
2018-08-25	69
2018-08-26	73
```

After `2018-08-26`:

- Orders placed continue to decay until it first reaches `0` at `2018-08-01`.
- The last order is placed at `2018-10-17`.
- Some orders placed spuriously between `2018-08-01` - `2018-08-17`.

</details>

### Recorded data vs actual

A distinction is made between reality, and what is recorded.

A day displaying no sales could mean:

- no sales were truly made
- an incomplete/inaccurate recording of data

We depend on parsing the available data as context, to determine reality.

## sales

## customers

## sellers

## funnel

## logistics
