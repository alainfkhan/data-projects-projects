# Preamble

## Context

### Brazilian currency

Summary (for context):

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

### Recorded data vs actual

A distinction is made between reality, and what is recorded.

For example, a day displaying no sales could mean:

- no sales were truly made
- an incomplete/inaccurate recording of data

We depend on understanding the surrounding data as context to determine reality.

## Definitions

### Dataset core definitions

A **user** is the human placing an order.

A **customer** is an instance of a user placing an order.

- A single user can be a customer many times.
- A user (with a single `customer_unique_id`) who has ordered last month, and who has ordered again this month, has been a customer twice (generating two disinct `customer_id`'s).
- A customer is a user who places an order for a delivery to some location.
- The customer location is the delivery destination.
- A user who has ordered more than once is a **repeat user**.
- It is possible for a user to make an order to one delivery destination, and order again to another delivery destination.

Loosely, a user is a customer, but in this dataset these definitions are kept.

An **order** is a basket of items bought at checkout.

- A single order can contain more than one items (products).
- Products are from sellers.
- Sellers are from some location.
- The seller location is the delivery source.

A row added onto the `orders` table can be thought of as:

- an order transaction,
- an order,
- or (loosely) a sale.

A sale can be realised, or unrealised.

Order transactions have the possible `order_status` values:

- `approved`
- `canceled` [sic.]
- `created`
- `delivered`
- `invoiced`
- `processing`
- `shipped`
- `unavailable`

Define a **sale** to be a realised and price-measurable order.

- A sale is realised when the `order_status` is any of:
  - `approved`,
  - `delivered`,
  - `invoiced`,
  - `processing`,
  - `shipped`;
- and is unrealised at its complement, when the `order_status` is any of:
  - `canceled`,
  - `created`,
  - `unavailable`.
- An order is price-measurable when the listed `price` is available. (i.e. `WHERE price IS NOT NULL`.)

We are interested in sales that are realised, and measurable.
An unrealised sale is a sale that is yet to be realised.
It is perhaps possible to have a sale that cannot be measured monetarily.

For a better picture:

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

Significant dates:

| Type            | Explanation         | Column                       |
| --------------- | ------------------- | ---------------------------- |
| Marketing date  | Order placed date   | `order_purchase_timestamp` |
| Accounting date | Order approved date | `order_approved_at`        |

We use the marketing date to measure user activity, and the accounting date to measure realised sales.

A user who places an order that is later cancelled,
generates user activity, but does not contribute to a sale, and hence, neither also to revenue.

A new order placed (with some initial `order_status`) starts as an unrealised sale,
and becomes realised exactly when
the `order_status` changes to a value that classifies it as realised,
on the date of the financial transaction (at `order_approved_at`).

The **revenue** is interpreted to be the listed price of a realised sale in the `orders` table.

- **Product revenue** is calculated from `price`.
- **Freight revenue** is calculated form `freight_value`.
- **Total revenue** = product revenue + freight revenue.
- In a particular month of sales, the sum of the listed prices is the revenue generated for that month.
- An order, that is not a realised sale, with a price listed, does not contribute to revenue.

N.B.:

- In this particular dataset, `freight_value` always exists with `price`.
- I.e. if we have `price`, we also have `freight_value`.
- Any numerical aggregations on realised and price-measurable sales is valid since `price` always exists.


## Assumptions

### Practical project scope

The dataset provided by Olist shows a growth and decay of the captured data.

Choose,
from this dataset,
a realistic start and end date,
that best reflect a supposed snapshot taken of the database under normal business operations.

For any analysis that require practicality choose:

- Snapshot start date: `2017-01-09`
- Snapshot end date: `2018-08-21`

Then, for any practical analyses, suppose therefore, that today is the next day: `2018-08-22`,
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
- The first order was placed at `2016-09-04`.

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

- Orders placed continue to decay until it first reaches `0` at `2018-09-01`.
- Some orders placed spuriously between `2018-09-01` - `2018-10-17`.
- The last order is placed at `2018-10-17`.

</details>

Suppose we are given a snapshot of a complete database from `2017-01-09` to `2018-08-21`, and that today is `2018-08-22`.

The definitions defined hold.

Users who have made payments on orders that are not realised sales, are eligible for a **refund** on that order.
Assume all refunds are actualised.

Let the base periodic timeframe be monthly.

## View code

View the queries:
- [Views](queries/analysis/globals/views.sql)
- [Functions](queries/analysis/globals/functions.sql)
- [Scratch work](queries/analysis/report/_scratch/). Ordered in attempt order.

