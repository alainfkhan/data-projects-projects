# Report

## Context

### Brazilian currency

Summary:

|                     |                  |
| ------------------- | ---------------- |
| Symbol              | `R$`           |
| ISO Code            | `BRL`          |
| Decimal Separator   | Comma `,`      |
| Thousands Separator | Period `.`     |
| Example             | `R$ 10.000,00` |

Exchange rate [BRL to GBP](https://www.exchangerates.org.uk/BRL-GBP-spot-exchange-rates-history-2018.html):

| Date           | BRL      | GBP          |
| -------------- | -------- | ------------ |
| `2018-01-01` | `R$ 1` | `£0.2234` |
| `2018-08-22` | `R$ 1` | `£0.1916` |
| `2018-10-17` | `R$ 1` | `£0.2069` |

- Banknotes: `R$ 2`, `R$ 5`, `R$ 10`, `R$ 20`, `R$ 50`, `R$ 100`, `R$ 200`
- Coins (centavos): `R$ 0.01`, `R$ 0.05`, `R$ 0.10`, `R$ 0.25`, `R$ 0.50`, `R$ 1.00`

### Recorded data vs actual

A distinction is made between reality, and what is recorded.

A day displaying no sales could mean:

- no sales were truly made
- an incomplete/inaccurate recording of data

We depend on parsing the available data as context, to determine reality.

## Definitions

### Practical project scope

The dataset provided by Olist shows a growth and decay of the captured data.

Choose,
from this dataset,
a reaslistic start and end date,
that best reflect a supposed snapshot taken of the database under normal business operations.

For any analysis that require practicality choose:

- Snapshot start date: `2017-01-09`
- Snapshot end date: `2018-08-21`

Then, for any practical analyses, suppose therefore, that today is `2018-08-22`,
and we have no knowledge of data beyond this date.

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

### Dataset core definitions

A **user** is the human placing an order.

A **customer** is an instance of a user placing an order.

- A single user can be a customer many times.
- A user (with a single `customer_unique_id`) who has ordered last month, and who has ordered again this month, has been a customer twice (generating two disinct `customer_id`'s).
- A customer is a user who places an order from some location.
- The customer location is the delivery destination.
- A user who has made more than one orders, with more than one customer locations, has had more than one delivery destinations, and is a **repeat user**.

Loosely, a user is a customer. But in this dataset these definitions are kept.

An **order** is a basket of items bought at checkout.

- A single order can contain more than one items (products).
- Products are from sellers.
- Sellers are from some location.

A row added onto the `orders` table is an order transaction (or simply, an order).

Order transactions have the possible `order_status`'s:

- `approved`
- `canceled` [sic.]
- `created`
- `delivered`
- `invoiced`
- `processing`
- `shipped`
- `unavailable`

Define a **sale** to be a realised and price-measurable order.

- An order is realised when the `order_status` is any of:
  - `approved`,
  - `delivered`,
  - `invoiced`,
  - `processing`,
  - `shipped`,
- and is unrealised at its complement, when the `order_status` is any of:
  - `canceled`,
  - `created`,
  - `unavailable`.
- An order is price-measurable when the `price` is available.

| `order_status` | Realised sale | Unrealised sale |
| ---------------- | ------------- | --------------- |
| `approved`     | Y             | -               |
| `canceled`     | -             | Y               |
| `created`      | -             | Y               |
| `delivered`    | Y             | -               |
| `invoiced`     | Y             | -               |
| `processing`   | Y             | -               |
| `shipped`      | Y             | -               |
| `unavailable`  | -             | Y               |

Define the **accounting date** to be the date the order is approved: the date of `order_approved_at`.

Define the **marketing date** to be the date the order is placed: the date of `order_purchase_timestamp`.

## Assumptions

## Sales

## Customers

## Sellers

## Funnel

## Logistics
