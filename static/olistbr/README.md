# Olist

## Notable analysis projects

- [**Olist**](https://github.com/alainfkhan/data-projects-projects/blob/main/static/olistbr/README.md)
    - [rebuild-db](https://github.com/alainfkhan/data-projects-projects/blob/main/static/olistbr/rebuild-db/README.md)
- [Restaurant Business Online](https://github.com/alainfkhan/data-projects-projects/blob/main/macos/bogacz-res/README.md)

## Read more from this project

> [Context](CONTEXT.md) (Business, Brazil) 
> [Preamble](PREAMBLE.md) (Definitions, Assumptions)
<!-- > [Report](REPORT.md) (Fuller version) -->

---

## Executive summary

Olist - Entity Relationship Diagram (ERD):

![photo of erd](img/erd.png)

- Shows the relationships between the main tables in the database.
- There are two dataset groups:
    - 'Brazilian e-commerce public dataset' (big blue background, left, contains 9 tables)
    - 'Marketing funnel by Olist' (smaller yellow background, bottom right, contains 2 tables)
- Solid lines between the tables represent an active relation,
while dashed lines represent an inactive relation.
- There is an active 1-many relation between `dim_sellers` and `fact_order_items`.
- There is an inactive many-many relation between `dim_sellers` and `fact_geolocation`.

---

## Navigation
- [Analysis projects](https://github.com/alainfkhan/data-projects-projects)

