# Olist

## Notable analysis projects

- [**Olist**](https://github.com/alainfkhan/data-projects-projects/blob/main/static/olistbr/README.md)
  - [rebuild-db](https://github.com/alainfkhan/data-projects-projects/blob/main/static/olistbr/rebuild-db/README.md)

<!-- - [Restaurant Business Online](https://github.com/alainfkhan/data-projects-projects/blob/main/macos/bogacz-res/README.md) -->

## Read more from this project

> - [Context](CONTEXT.md) (Business, Brazil)
> - [Preamble](PREAMBLE.md) (Code, Definitions, Assumptions)

<!-- > [Report](REPORT.md) (Fuller version) -->

---

## Executive summary

Olist - Entity Relationship Diagram (ERD):

![Combined project ERD](img/erd.png)

- Shows the relationships between tables.
- There are two dataset groups:
  - 'Brazilian e-commerce public dataset' (big blue background, left, contains 9 tables)
  - 'Marketing funnel by Olist' (smaller yellow background, bottom right, contains 2 tables)
- Solid lines between tables represent an active relation,
  while dashed lines represent an inactive relation.
- For example:
  - There is an active 1-many relation between `dim_sellers` and `fact_order_items`.
  - There is an inactive many-many relation between `dim_sellers` and `fact_geolocation`.
  - There is an inactive 1-1 relation between `fact_closed_deals` and `fact_marketing_qualified_leads`.

---

Month on month Average Order Values (AOV)

Revenue by product category and business segment

Product weight and freight cost correlation

Average delivery time by customer state

Seller concentration through time

---

## Navigation

- [Analysis projects](https://github.com/alainfkhan/data-projects-projects)
